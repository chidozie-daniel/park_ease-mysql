const express = require('express');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { wrap } = require('../utils/helpers');

const router = express.Router();

router.put(
  '/profile',
  requireAuth,
  wrap(async (req, res) => {
    const { name, phone, profileImage } = req.body || {};

    const fields = [];
    const values = [];
    if (name !== undefined) {
      if (!String(name).trim()) throw new HttpError(400, 'Name cannot be empty');
      fields.push('name = ?');
      values.push(String(name).trim());
    }
    if (phone !== undefined) {
      fields.push('phone = ?');
      values.push(phone ? String(phone).trim() : null);
    }
    if (profileImage !== undefined) {
      fields.push('profile_image = ?');
      values.push(profileImage ? String(profileImage) : null);
    }

    if (!fields.length) {
      throw new HttpError(400, 'Nothing to update');
    }

    values.push(req.user.id);
    await db.query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, values);

    const [rows] = await db.query(
      `SELECT id, name, email, phone, profile_image, role, is_active, created_at, updated_at
       FROM users WHERE id = ?`,
      [req.user.id]
    );

    res.json({ user: camelizeKeys(rows[0]) });
  })
);

module.exports = router;