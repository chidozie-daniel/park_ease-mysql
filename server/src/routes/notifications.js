const express = require('express');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { wrap } = require('../utils/helpers');

const router = express.Router();

const NOTIFICATION_FIELDS = `
  id, user_id, type, title, body, is_read, data, created_at
`;

router.get(
  '/',
  requireAuth,
  wrap(async (req, res) => {
    const [rows] = await db.query(
      `SELECT ${NOTIFICATION_FIELDS} FROM notifications
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [req.user.id]
    );
    res.json({ data: camelizeKeys(rows) });
  })
);

router.put(
  '/read-all',
  requireAuth,
  wrap(async (req, res) => {
    await db.query(
      `UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0`,
      [req.user.id]
    );
    res.json({ message: 'All notifications marked as read' });
  })
);

router.post(
  '/push-token',
  requireAuth,
  wrap(async (req, res) => {
    const { token } = req.body || {};
    if (!token) {
      throw new HttpError(400, 'Push token is required');
    }
    await db.query(`UPDATE users SET push_token = ? WHERE id = ?`, [String(token), req.user.id]);
    res.json({ message: 'Push token saved' });
  })
);

router.put(
  '/:id/read',
  requireAuth,
  wrap(async (req, res) => {
    const [result] = await db.query(
      `UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );
    if (!result.affectedRows) {
      throw new HttpError(404, 'Notification not found');
    }
    res.json({ message: 'Notification marked as read' });
  })
);

router.delete(
  '/:id',
  requireAuth,
  wrap(async (req, res) => {
    const [result] = await db.query(
      `DELETE FROM notifications WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );
    if (!result.affectedRows) {
      throw new HttpError(404, 'Notification not found');
    }
    res.json({ message: 'Notification deleted' });
  })
);

module.exports = router;