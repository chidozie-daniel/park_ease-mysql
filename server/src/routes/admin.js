const express = require('express');
const bcrypt = require('bcryptjs');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { requireAdmin } = require('../middleware/admin');
const { camelizeKeys } = require('../utils/camelize');
const { uuid, wrap } = require('../utils/helpers');

const router = express.Router();

router.use(requireAuth, requireAdmin);

router.get(
  '/dashboard',
  wrap(async (req, res) => {
    const [[users]] = await db.query(
      `SELECT COUNT(*) AS totalUsers,
              SUM(CASE WHEN role = 'admin' THEN 1 ELSE 0 END) AS totalAdmins
       FROM users`
    );
    const [[lots]] = await db.query(
      `SELECT COUNT(*) AS totalLots,
              SUM(available_slots) AS availableSlots,
              SUM(total_slots) AS totalSlots
       FROM parking_lots`
    );
    const [[bookings]] = await db.query(
      `SELECT COUNT(*) AS totalBookings,
              SUM(CASE WHEN status IN ('confirmed','checked_in') THEN 1 ELSE 0 END) AS activeBookings,
              SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pendingBookings,
              SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelledBookings
       FROM bookings`
    );
    const [[revenue]] = await db.query(
      `SELECT COALESCE(SUM(amount), 0) AS totalRevenue,
              COUNT(*) AS totalTransactions
       FROM payments WHERE status = 'completed'`
    );

    res.json({
      data: {
        totalUsers: Number(users.totalUsers) || 0,
        totalAdmins: Number(users.totalAdmins) || 0,
        totalLots: Number(lots.totalLots) || 0,
        availableSlots: Number(lots.availableSlots) || 0,
        totalSlots: Number(lots.totalSlots) || 0,
        totalBookings: Number(bookings.totalBookings) || 0,
        activeBookings: Number(bookings.activeBookings) || 0,
        pendingBookings: Number(bookings.pendingBookings) || 0,
        cancelledBookings: Number(bookings.cancelledBookings) || 0,
        totalRevenue: Number(revenue.totalRevenue) || 0,
        totalTransactions: Number(revenue.totalTransactions) || 0,
      },
    });
  })
);

router.get(
  '/users',
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT id, name, email, phone, profile_image, role, is_active, created_at, updated_at
       FROM users ORDER BY created_at DESC`
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

router.put(
  '/users/:id',
  wrap(async (req, res) => {
    const { role, isActive, name, phone } = req.body || {};

    const [existing] = await db.query(`SELECT id FROM users WHERE id = ?`, [req.params.id]);
    if (!existing.length) {
      throw new HttpError(404, 'User not found');
    }

    const fields = [];
    const values = [];
    if (role !== undefined) {
      if (!['user', 'admin'].includes(role)) {
        throw new HttpError(400, 'Invalid role');
      }
      fields.push('role = ?');
      values.push(role);
    }
    if (isActive !== undefined) {
      fields.push('is_active = ?');
      values.push(isActive ? 1 : 0);
    }
    if (name !== undefined) {
      fields.push('name = ?');
      values.push(String(name).trim());
    }
    if (phone !== undefined) {
      fields.push('phone = ?');
      values.push(phone ? String(phone).trim() : null);
    }

    if (fields.length) {
      values.push(req.params.id);
      await db.query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, values);
    }

    const [rows] = await db.query(
      `SELECT id, name, email, phone, profile_image, role, is_active, created_at, updated_at
       FROM users WHERE id = ?`,
      [req.params.id]
    );
    res.json({ data: camelizeKeys(rows[0]) });
  })
);

router.delete(
  '/users/:id',
  wrap(async (req, res) => {
    if (req.params.id === req.user.id) {
      throw new HttpError(400, 'You cannot delete your own account');
    }
    const [result] = await db.query(`DELETE FROM users WHERE id = ?`, [req.params.id]);
    if (!result.affectedRows) {
      throw new HttpError(404, 'User not found');
    }
    res.json({ message: 'User deleted' });
  })
);

router.get(
  '/parking-lots',
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT id, name, address, latitude, longitude, type, total_slots, available_slots,
              hourly_rate, daily_rate, description, amenities, status, image_url,
              is_active, created_at, updated_at
       FROM parking_lots ORDER BY created_at DESC`
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

router.post(
  '/parking-lots',
  wrap(async (req, res) => {
    const {
      name, address, latitude, longitude, type, totalSlots, hourlyRate,
      dailyRate, description, amenities, status,
    } = req.body || {};

    if (!name || !address || latitude === undefined || longitude === undefined) {
      throw new HttpError(400, 'name, address, latitude and longitude are required');
    }

    const id = uuid();
    await db.query(
      `INSERT INTO parking_lots
         (id, name, address, latitude, longitude, type, total_slots, available_slots,
          hourly_rate, daily_rate, description, amenities, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id,
        String(name).trim(),
        String(address).trim(),
        latitude,
        longitude,
        type || 'indoor',
        Number(totalSlots) || 0,
        Number(totalSlots) || 0,
        Number(hourlyRate) || 0,
        dailyRate !== undefined && dailyRate !== null ? Number(dailyRate) : null,
        description || null,
        Array.isArray(amenities) ? JSON.stringify(amenities) : null,
        status || 'available',
      ]
    );

    for (let i = 1; i <= (Number(totalSlots) || 0); i++) {
      await db.query(
        `INSERT INTO parking_slots (id, parking_lot_id, slot_number, type, status)
         VALUES (?, ?, ?, 'regular', 'available')`,
        [uuid(), id, String(i).padStart(2, '0')]
      );
    }

    const [created] = await db.query(
      `SELECT id, name, address, latitude, longitude, type, total_slots, available_slots,
              hourly_rate, daily_rate, description, amenities, status, image_url,
              is_active, created_at, updated_at
       FROM parking_lots WHERE id = ?`,
      [id]
    );
    res.status(201).json({ data: camelizeKeys(created[0]) });
  })
);

router.put(
  '/parking-lots/:id',
  wrap(async (req, res) => {
    const [existing] = await db.query(`SELECT id FROM parking_lots WHERE id = ?`, [req.params.id]);
    if (!existing.length) {
      throw new HttpError(404, 'Parking lot not found');
    }

    const fields = [];
    const values = [];
    const { name, address, latitude, longitude, type, totalSlots, hourlyRate, dailyRate, description, amenities, status, availableSlots } =
      req.body || {};

    const push = (col, val) => {
      fields.push(`${col} = ?`);
      values.push(val);
    };

    if (name !== undefined) push('name', String(name).trim());
    if (address !== undefined) push('address', String(address).trim());
    if (latitude !== undefined) push('latitude', latitude);
    if (longitude !== undefined) push('longitude', longitude);
    if (type !== undefined) push('type', type);
    if (totalSlots !== undefined) push('total_slots', Number(totalSlots) || 0);
    if (availableSlots !== undefined) push('available_slots', Number(availableSlots) || 0);
    if (hourlyRate !== undefined) push('hourly_rate', Number(hourlyRate) || 0);
    if (dailyRate !== undefined) push('daily_rate', dailyRate ? Number(dailyRate) : null);
    if (description !== undefined) push('description', description || null);
    if (amenities !== undefined) push('amenities', Array.isArray(amenities) ? JSON.stringify(amenities) : null);
    if (status !== undefined) push('status', status);

    if (fields.length) {
      values.push(req.params.id);
      await db.query(`UPDATE parking_lots SET ${fields.join(', ')} WHERE id = ?`, values);
    }

    const [rows] = await db.query(
      `SELECT id, name, address, latitude, longitude, type, total_slots, available_slots,
              hourly_rate, daily_rate, description, amenities, status, image_url,
              is_active, created_at, updated_at
       FROM parking_lots WHERE id = ?`,
      [req.params.id]
    );
    res.json({ data: camelizeKeys(rows[0]) });
  })
);

router.delete(
  '/parking-lots/:id',
  wrap(async (req, res) => {
    const [result] = await db.query(`DELETE FROM parking_lots WHERE id = ?`, [req.params.id]);
    if (!result.affectedRows) {
      throw new HttpError(404, 'Parking lot not found');
    }
    res.json({ message: 'Parking lot deleted' });
  })
);

router.get(
  '/bookings',
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT b.id, b.user_id, b.parking_lot_id, b.parking_slot_id, b.vehicle_id,
              b.start_time, b.end_time, b.total_amount, b.discount_amount, b.status,
              b.qr_code, b.created_at, b.updated_at,
              u.name AS user_name, u.email AS user_email,
              l.name AS lot_name,
              s.type AS slot_type
       FROM bookings b
       LEFT JOIN users u ON u.id = b.user_id
       LEFT JOIN parking_lots l ON l.id = b.parking_lot_id
       LEFT JOIN parking_slots s ON s.id = b.parking_slot_id
       ORDER BY b.created_at DESC`
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

router.get(
  '/reports',
  wrap(async (req, res) => {
    const [revenueByDay] = await db.query(
      `SELECT DATE(paid_at) AS date, SUM(amount) AS revenue, COUNT(*) AS transactions
       FROM payments WHERE status = 'completed'
       GROUP BY DATE(paid_at) ORDER BY date ASC`
    );
    const [bookingsByLot] = await db.query(
      `SELECT l.name AS lotName, COUNT(b.id) AS bookings
       FROM parking_lots l
       LEFT JOIN bookings b ON b.parking_lot_id = l.id
       GROUP BY l.id ORDER BY bookings DESC`
    );
    const [[summary]] = await db.query(
      `SELECT COALESCE(SUM(amount), 0) AS totalRevenue,
              COUNT(*) AS totalBookings,
              COUNT(DISTINCT user_id) AS activeUsers
       FROM payments WHERE status = 'completed'`
    );

    res.json({
      data: {
        summary: {
          totalRevenue: Number(summary.totalRevenue) || 0,
          totalBookings: Number(summary.totalBookings) || 0,
          activeUsers: Number(summary.activeUsers) || 0,
        },
        revenueByDay: revenueByDay.map((r) => ({
          date: r.date,
          revenue: Number(r.revenue) || 0,
          transactions: Number(r.transactions) || 0,
        })),
        bookingsByLot: bookingsByLot.map((r) => ({
          lotName: r.lotName,
          bookings: Number(r.bookings) || 0,
        })),
      },
    });
  })
);

router.post(
  '/users',
  wrap(async (req, res) => {
    const { name, email, phone, password, role } = req.body || {};
    if (!name || !email || !password) {
      throw new HttpError(400, 'Name, email and password are required');
    }
    const normalizedEmail = String(email).toLowerCase().trim();

    const [existing] = await db.query(`SELECT id FROM users WHERE email = ?`, [normalizedEmail]);
    if (existing.length) {
      throw new HttpError(409, 'An account with this email already exists');
    }

    const passwordHash = await bcrypt.hash(String(password), 10);
    const id = uuid();
    await db.query(
      `INSERT INTO users (id, name, email, phone, password_hash, role)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id, String(name).trim(), normalizedEmail, phone || null, passwordHash, role || 'user']
    );

    const [rows] = await db.query(
      `SELECT id, name, email, phone, profile_image, role, is_active, created_at, updated_at
       FROM users WHERE id = ?`,
      [id]
    );
    res.status(201).json({ data: camelizeKeys(rows[0]) });
  })
);

module.exports = router;