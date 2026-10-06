const express = require('express');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { uuid, wrap } = require('../utils/helpers');

const router = express.Router();

const VEHICLE_FIELDS = `
  id, user_id, type, brand, model, color, license_plate, is_default, created_at
`;

const VALID_TYPES = ['car', 'bike', 'scooter', 'truck'];

router.get(
  '/',
  requireAuth,
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT ${VEHICLE_FIELDS} FROM vehicles
       WHERE user_id = ?
       ORDER BY is_default DESC, created_at DESC`,
      [req.user.id]
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

router.post(
  '/',
  requireAuth,
  wrap(async (req, res) => {
    const { type, brand, model, color, licensePlate, isDefault } = req.body || {};
    if (!type || !licensePlate) {
      throw new HttpError(400, 'Vehicle type and license plate are required');
    }
    if (!VALID_TYPES.includes(type)) {
      throw new HttpError(400, `Invalid vehicle type. Allowed: ${VALID_TYPES.join(', ')}`);
    }

    const id = uuid();

    // Clearing the old default and inserting the new one must be atomic,
    // otherwise a failure between them leaves the user with no default.
    await db.withTransaction(async (conn) => {
      const [existing] = await conn.query(
        `SELECT COUNT(*) AS count FROM vehicles WHERE user_id = ?`,
        [req.user.id]
      );
      const isFirstVehicle = Number(existing[0].count) === 0;
      const makeDefault = isDefault === true || isFirstVehicle;

      if (makeDefault) {
        await conn.query(`UPDATE vehicles SET is_default = 0 WHERE user_id = ?`, [
          req.user.id,
        ]);
      }

      await conn.query(
        `INSERT INTO vehicles (id, user_id, type, brand, model, color, license_plate, is_default)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          id,
          req.user.id,
          type,
          brand || null,
          model || null,
          color || null,
          String(licensePlate).trim(),
          makeDefault ? 1 : 0,
        ]
      );
    });

    const [created] = await db.query(
      `SELECT ${VEHICLE_FIELDS} FROM vehicles WHERE id = ?`,
      [id]
    );
    res.status(201).json({ data: camelizeKeys(created[0]) });
  })
);

// Declared before '/:id' so the literal segment is not swallowed by the
// wildcard route. Express matches in registration order.
router.put(
  '/:id/default',
  requireAuth,
  wrap(async (req, res) => {
    const [existing] = await db.query(
      `SELECT id FROM vehicles WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );
    if (!existing.length) {
      throw new HttpError(404, 'Vehicle not found');
    }

    await db.withTransaction(async (conn) => {
      await conn.query(`UPDATE vehicles SET is_default = 0 WHERE user_id = ?`, [
        req.user.id,
      ]);
      await conn.query(`UPDATE vehicles SET is_default = 1 WHERE id = ?`, [
        req.params.id,
      ]);
    });

    res.json({ message: 'Default vehicle updated' });
  })
);

router.put(
  '/:id',
  requireAuth,
  wrap(async (req, res) => {
    const { type, brand, model, color, licensePlate, isDefault } = req.body || {};

    const [existing] = await db.query(
      `SELECT id FROM vehicles WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );
    if (!existing.length) {
      throw new HttpError(404, 'Vehicle not found');
    }

    const fields = [];
    const values = [];
    if (type !== undefined) {
      if (!VALID_TYPES.includes(type)) {
        throw new HttpError(400, `Invalid vehicle type. Allowed: ${VALID_TYPES.join(', ')}`);
      }
      fields.push('type = ?');
      values.push(type);
    }
    if (brand !== undefined) {
      fields.push('brand = ?');
      values.push(brand || null);
    }
    if (model !== undefined) {
      fields.push('model = ?');
      values.push(model || null);
    }
    if (color !== undefined) {
      fields.push('color = ?');
      values.push(color || null);
    }
    if (licensePlate !== undefined) {
      if (!String(licensePlate).trim()) {
        throw new HttpError(400, 'License plate cannot be empty');
      }
      fields.push('license_plate = ?');
      values.push(String(licensePlate).trim());
    }
    // Promoting to default must clear the previous default atomically,
    // otherwise the user ends up with two defaults or none.
    await db.withTransaction(async (conn) => {
      if (isDefault === true) {
        await conn.query(
          `UPDATE vehicles SET is_default = 0 WHERE user_id = ?`,
          [req.user.id]
        );
        fields.push('is_default = ?');
        values.push(1);
      } else if (isDefault === false) {
        fields.push('is_default = ?');
        values.push(0);
      }

      if (fields.length) {
        values.push(req.params.id);
        await conn.query(
          `UPDATE vehicles SET ${fields.join(', ')} WHERE id = ?`,
          values
        );
      }
    });

    const [rows] = await db.query(
      `SELECT ${VEHICLE_FIELDS} FROM vehicles WHERE id = ?`,
      [req.params.id]
    );
    res.json({ data: camelizeKeys(rows[0]) });
  })
);

router.delete(
  '/:id',
  requireAuth,
  wrap(async (req, res) => {
    const [result] = await db.query(
      `DELETE FROM vehicles WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );
    if (!result.affectedRows) {
      throw new HttpError(404, 'Vehicle not found');
    }
    res.json({ message: 'Vehicle deleted' });
  })
);

module.exports = router;