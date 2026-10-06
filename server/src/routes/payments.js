const express = require('express');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { uuid, wrap } = require('../utils/helpers');
const stripe = require('../config/stripe');

const router = express.Router();

const PAYMENT_FIELDS = `
  id, booking_id, user_id, amount, method, status,
  transaction_id, paid_at, gateway_response, created_at
`;

const STRIPE_CURRENCY = process.env.CURRENCY_CODE || 'ngn';

const METHOD_MAP = {
  credit_card: 'credit_card',
  debit_card: 'debit_card',
  upi: 'upi',
  wallet: 'wallet',
  net_banking: 'net_banking',
  cash: 'cash',
};

function toDbMethod(method) {
  const key = String(method || '');
  return METHOD_MAP[key] || null;
}

async function getOwnedPayment(id, userId) {
  const [rows] = await db.query(
    `SELECT ${PAYMENT_FIELDS} FROM payments WHERE id = ? AND user_id = ?`,
    [id, userId]
  );
  return rows[0] || null;
}

router.post(
  '/',
  requireAuth,
  wrap(async (req, res) => {
    const { bookingId, method, gatewayToken } = req.body || {};

    // The amount is always derived from the booking, never from the request
    // body. Trusting a client-supplied amount lets anyone pay 0.01 for a
    // 200.00 booking.
    if (!bookingId || !method) {
      throw new HttpError(400, 'bookingId and method are required');
    }
    const dbMethod = toDbMethod(method);
    if (!dbMethod) {
      throw new HttpError(400, 'Invalid payment method');
    }

    const [bookingRows] = await db.query(
      `SELECT id, user_id, total_amount, status FROM bookings WHERE id = ?`,
      [bookingId]
    );
    const booking = bookingRows[0];
    if (!booking) {
      throw new HttpError(404, 'Booking not found');
    }
    if (booking.user_id !== req.user.id) {
      throw new HttpError(403, 'You can only pay for your own bookings');
    }
    if (booking.status === 'cancelled') {
      throw new HttpError(409, 'Cannot pay for a cancelled booking');
    }

    const amount = Number(booking.total_amount);
    if (!Number.isFinite(amount) || amount < 0) {
      throw new HttpError(409, 'This booking has no payable amount');
    }

    const paymentId = uuid();
    let status = 'completed';
    let transactionId = null;
    let gatewayResponse = null;

    if (gatewayToken && stripe) {
      try {
        const intent = await stripe.paymentIntents.create({
          amount: Math.round(amount * 100),
          currency: STRIPE_CURRENCY,
          payment_method: gatewayToken,
          confirm: true,
          metadata: { bookingId, paymentId },
        });
        transactionId = intent.id;
        gatewayResponse = { status: intent.status, paymentMethod: intent.payment_method };
        status = intent.status === 'succeeded' ? 'completed' : 'pending';
      } catch (e) {
        status = 'failed';
        gatewayResponse = { error: e.message, bookingId, paymentId };
      }
    } else if (gatewayToken) {
      transactionId = `mock_${paymentId}`;
      gatewayResponse = { mock: true };
    } else if (dbMethod === 'cash') {
      transactionId = `cash_${paymentId}`;
      gatewayResponse = { method: 'cash' };
    } else {
      transactionId = `pending_${paymentId}`;
      status = 'pending';
    }

    await db.query(
      `INSERT INTO payments
         (id, booking_id, user_id, amount, method, status, transaction_id, paid_at, gateway_response)
       VALUES (?, ?, ?, ?, ?, ?, ?, CASE WHEN ? = 'completed' THEN NOW() ELSE NULL END, ?)`,
      [
        paymentId,
        bookingId,
        req.user.id,
        amount,
        dbMethod,
        status,
        transactionId,
        status,
        gatewayResponse ? JSON.stringify(gatewayResponse) : null,
      ]
    );

    await db.query(
      `INSERT INTO notifications (id, user_id, type, title, body)
       VALUES (?, ?, 'payment', 'Payment ${status}', ?)`,
      [uuid(), req.user.id, `Your payment of ${amount.toFixed(2)} was ${status}.`]
    );

    const [created] = await db.query(
      `SELECT ${PAYMENT_FIELDS} FROM payments WHERE id = ?`,
      [paymentId]
    );
    res.status(201).json({ data: camelizeKeys(created[0]) });
  })
);

router.get(
  '/history',
  requireAuth,
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT ${PAYMENT_FIELDS} FROM payments
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [req.user.id]
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

router.get(
  '/:id',
  requireAuth,
  wrap(async (req, res) => {
    const payment = await getOwnedPayment(req.params.id, req.user.id);
    if (!payment) {
      throw new HttpError(404, 'Payment not found');
    }
    res.json({ data: camelizeKeys(payment) });
  })
);

module.exports = router;