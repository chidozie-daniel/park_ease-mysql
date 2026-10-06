const express = require('express');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { wrap } = require('../utils/helpers');

const router = express.Router();

const LOT_FIELDS = `
  id, name, address, latitude, longitude, type, total_slots, available_slots,
  hourly_rate, daily_rate, description, amenities, status, image_url,
  is_active, created_at, updated_at
`;

const KM_PER_DEGREE = 111.045;

router.get(
  '/search',
  requireAuth,
  wrap(async (req, res) => {
    const { lat, lng, radius, q } = req.query;

    let rows;
    if (lat !== undefined && lng !== undefined) {
      const latitude = parseFloat(lat);
      const longitude = parseFloat(lng);
      const radiusKm = parseFloat(radius) || 10;

      if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
        throw new HttpError(400, 'Invalid latitude or longitude');
      }

      const [result] = await db.query(
        `SELECT ${LOT_FIELDS},
          (${KM_PER_DEGREE} * 1000 *
            (ACOS(
              LEAST(1.0, COS(RADIANS(?)) * COS(RADIANS(latitude)) *
                COS(RADIANS(longitude) - RADIANS(?)) +
                SIN(RADIANS(?)) * SIN(RADIANS(latitude)))
            )) / 1000) AS distance_km
         FROM parking_lots
         WHERE is_active = 1 AND status != 'closed'
           AND (${KM_PER_DEGREE} * 1000 *
            (ACOS(
              LEAST(1.0, COS(RADIANS(?)) * COS(RADIANS(latitude)) *
                COS(RADIANS(longitude) - RADIANS(?)) +
                SIN(RADIANS(?)) * SIN(RADIANS(latitude)))
            )) / 1000) <= ?
         ORDER BY distance_km ASC`,
        [latitude, longitude, latitude, latitude, longitude, latitude, radiusKm]
      );

      const lots = result.map((lot) => {
        const { distance_km: distanceKm, ...rest } = lot;
        return { ...camelizeKeys(rest), distanceKm: Math.round(distanceKm * 100) / 100 };
      });
      return res.json({ data: lots });
    }

    if (q !== undefined) {
      const term = `%${String(q).trim()}%`;
      const [result] = await db.query(
        `SELECT ${LOT_FIELDS} FROM parking_lots
         WHERE is_active = 1 AND status != 'closed'
           AND (name LIKE ? OR address LIKE ?)
         ORDER BY name ASC`,
        [term, term]
      );
      return res.json({ data: camelizeKeys(result) });
    }

    const [result] = await db.query(
      `SELECT ${LOT_FIELDS} FROM parking_lots
       WHERE is_active = 1 AND status != 'closed'
       ORDER BY name ASC`
    );
    res.json({ data: camelizeKeys(result) });
  })
);

router.get(
  '/lots/:id',
  requireAuth,
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT ${LOT_FIELDS} FROM parking_lots WHERE id = ?`,
      [req.params.id]
    );
    if (!rows.length) {
      throw new HttpError(404, 'Parking lot not found');
    }
    res.json({ data: camelizeKeys(rows[0]) });
  })
);

router.get(
  '/slots',
  requireAuth,
  wrap(async (req, res) => {
    const { parkingLotId } = req.query;
    if (!parkingLotId) {
      throw new HttpError(400, 'parkingLotId is required');
    }

    const [rows] = await db.query(
      `SELECT id, parking_lot_id, slot_number, type, status, price_multiplier, created_at
       FROM parking_slots
       WHERE parking_lot_id = ?
       ORDER BY slot_number ASC`,
      [parkingLotId]
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

module.exports = router;