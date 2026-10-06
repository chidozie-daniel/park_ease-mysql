const express = require('express');
const crypto = require('crypto');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { uuid, wrap } = require('../utils/helpers');

const router = express.Router();

const BOOKING_FIELDS = `
  id, user_id, parking_lot_id, parking_slot_id, vehicle_id,
  start_time, end_time, total_amount, discount_amount, status,
  qr_code, created_at, updated_at
`;

function generateQrCode(bookingId) {
  return `parkease:booking:${bookingId}:${crypto.randomBytes(16).toString('hex')}`;
}

async function getOwnedBooking(id, userId) {
  const [rows] = await db.query(
    `SELECT ${BOOKING_FIELDS} FROM bookings WHERE id = ? AND user_id = ?`,
    [id, userId]
  );
  return rows[0] || null;
}

router.post(
  '/',
  requireAuth,
  wrap(async (req, res) => {
    const { parkingLotId, parkingSlotId, vehicleId, startTime, endTime } = req.body || {};
    const parkingSlot = parkingSlotId ? String(parkingSlotId) : null;

    if (!parkingLotId || !startTime || !endTime) {
      throw new HttpError(400, 'parkingLotId, startTime and endTime are required');
    }
    if (!vehicleId) {
      throw new HttpError(400, 'vehicleId is required');
    }

    const start = new Date(startTime);
    const end = new Date(endTime);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new HttpError(400, 'Invalid start or end time');
    }
    if (end <= start) {
      throw new HttpError(400, 'End time must be after start time');
    }

    const id = uuid();
    const qrCode = generateQrCode(id);

    // Slot availability is checked and claimed under a row lock so two
    // concurrent requests cannot both reserve the last slot.
    await db.withTransaction(async (conn) => {
      const [lotRows] = await conn.query(
        `SELECT name, hourly_rate, daily_rate
         FROM parking_lots
         WHERE id = ? AND is_active = 1 AND status != 'closed'
         FOR UPDATE`,
        [parkingLotId]
      );
      if (!lotRows.length) {
        throw new HttpError(404, 'Parking lot not found');
      }
      const lot = lotRows[0];

      if (parkingSlot) {
        const [slotRows] = await conn.query(
          `SELECT id FROM parking_slots
           WHERE id = ? AND parking_lot_id = ? AND status = 'available'
           FOR UPDATE`,
          [parkingSlot, parkingLotId]
        );
        if (!slotRows.length) {
          throw new HttpError(409, 'Selected parking slot is no longer available');
        }

        const [slotUpdate] = await conn.query(
          `UPDATE parking_slots SET status = 'reserved' WHERE id = ? AND status = 'available'`,
          [parkingSlot]
        );
        if (!slotUpdate.affectedRows) {
          throw new HttpError(409, 'Selected parking slot is no longer available');
        }
      }

      const hours = (end - start) / (1000 * 60 * 60);
      const hourlyRate = Number(lot.hourly_rate) || 0;
      const dailyRate = lot.daily_rate ? Number(lot.daily_rate) : null;
      let totalAmount = hours * hourlyRate;
      if (dailyRate && hours >= 24) {
        totalAmount = Math.ceil(hours / 24) * dailyRate;
      }
      totalAmount = Math.round(totalAmount * 100) / 100;

      await conn.query(
        `INSERT INTO bookings
           (id, user_id, parking_lot_id, parking_slot_id, vehicle_id,
            start_time, end_time, total_amount, status, qr_code)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'confirmed', ?)`,
        [
          id,
          req.user.id,
          parkingLotId,
          parkingSlot,
          vehicleId,
          start.toISOString().slice(0, 19).replace('T', ' '),
          end.toISOString().slice(0, 19).replace('T', ' '),
          totalAmount,
          qrCode,
        ]
      );

      await conn.query(
        `UPDATE parking_lots
         SET available_slots = GREATEST(available_slots - 1, 0)
         WHERE id = ?`,
        [parkingLotId]
      );

      await conn.query(
        `INSERT INTO notifications (id, user_id, type, title, body)
         VALUES (?, ?, 'booking', 'Booking confirmed', ?)`,
        [uuid(), req.user.id, `Your booking at ${lot.name} is confirmed.`]
      );
    });

    const [created] = await db.query(
      `SELECT ${BOOKING_FIELDS} FROM bookings WHERE id = ?`,
      [id]
    );
    res.status(201).json({ data: camelizeKeys(created[0]) });
  })
);

router.get(
  '/history',
  requireAuth,
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT ${BOOKING_FIELDS} FROM bookings
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
    const booking = await getOwnedBooking(req.params.id, req.user.id);
    if (!booking) {
      throw new HttpError(404, 'Booking not found');
    }
    res.json({ data: camelizeKeys(booking) });
  })
);

router.put(
  '/:id/cancel',
  requireAuth,
  wrap(async (req, res) => {
    const booking = await getOwnedBooking(req.params.id, req.user.id);
    if (!booking) {
      throw new HttpError(404, 'Booking not found');
    }
    // 'checked_out' means the slot was already returned to the pool by
    // checkout, so re-incrementing here would double-count it.
    if (!['pending', 'confirmed', 'checked_in'].includes(booking.status)) {
      throw new HttpError(409, 'Booking cannot be cancelled in its current state');
    }

    await db.withTransaction(async (conn) => {
      const [result] = await conn.query(
        `UPDATE bookings SET status = 'cancelled'
         WHERE id = ? AND status IN ('pending', 'confirmed', 'checked_in')`,
        [booking.id]
      );
      if (!result.affectedRows) {
        throw new HttpError(409, 'Booking cannot be cancelled in its current state');
      }

      if (booking.parking_slot_id) {
        await conn.query(
          `UPDATE parking_slots SET status = 'available' WHERE id = ?`,
          [booking.parking_slot_id]
        );
      }
      await conn.query(
        `UPDATE parking_lots
         SET available_slots = LEAST(available_slots + 1, total_slots)
         WHERE id = ?`,
        [booking.parking_lot_id]
      );
    });

    const [updated] = await db.query(
      `SELECT ${BOOKING_FIELDS} FROM bookings WHERE id = ?`,
      [booking.id]
    );
    res.json({ data: camelizeKeys(updated[0]) });
  })
);

router.post(
  '/:id/checkin',
  requireAuth,
  wrap(async (req, res) => {
    const { qrCode } = req.body || {};

    const booking = await getOwnedBooking(req.params.id, req.user.id);
    if (!booking) {
      throw new HttpError(404, 'Booking not found');
    }
    if (booking.status !== 'confirmed') {
      throw new HttpError(409, 'Booking must be confirmed before check-in');
    }
    if (!qrCode || qrCode !== booking.qr_code) {
      throw new HttpError(400, 'Invalid QR code');
    }

    await db.withTransaction(async (conn) => {
      const [result] = await conn.query(
        `UPDATE bookings SET status = 'checked_in' WHERE id = ? AND status = 'confirmed'`,
        [booking.id]
      );
      if (!result.affectedRows) {
        throw new HttpError(409, 'Booking must be confirmed before check-in');
      }
      if (booking.parking_slot_id) {
        await conn.query(
          `UPDATE parking_slots SET status = 'occupied' WHERE id = ?`,
          [booking.parking_slot_id]
        );
      }
    });

    const [updated] = await db.query(
      `SELECT ${BOOKING_FIELDS} FROM bookings WHERE id = ?`,
      [booking.id]
    );
    res.json({ data: camelizeKeys(updated[0]) });
  })
);

router.post(
  '/:id/checkout',
  requireAuth,
  wrap(async (req, res) => {
    const booking = await getOwnedBooking(req.params.id, req.user.id);
    if (!booking) {
      throw new HttpError(404, 'Booking not found');
    }
    if (booking.status !== 'checked_in') {
      throw new HttpError(409, 'Booking must be checked in before checkout');
    }

    await db.withTransaction(async (conn) => {
      const [result] = await conn.query(
        `UPDATE bookings SET status = 'checked_out' WHERE id = ? AND status = 'checked_in'`,
        [booking.id]
      );
      if (!result.affectedRows) {
        throw new HttpError(409, 'Booking must be checked in before checkout');
      }

      if (booking.parking_slot_id) {
        await conn.query(
          `UPDATE parking_slots SET status = 'available' WHERE id = ?`,
          [booking.parking_slot_id]
        );
      }

      // Release the lot capacity this booking was holding. Cancellation
      // already does this; without it here, available_slots drifts
      // permanently downward with every completed booking.
      await conn.query(
        `UPDATE parking_lots
         SET available_slots = LEAST(available_slots + 1, total_slots)
         WHERE id = ?`,
        [booking.parking_lot_id]
      );
    });

    const [updated] = await db.query(
      `SELECT ${BOOKING_FIELDS} FROM bookings WHERE id = ?`,
      [booking.id]
    );
    res.json({ data: camelizeKeys(updated[0]) });
  })
);

module.exports = router;