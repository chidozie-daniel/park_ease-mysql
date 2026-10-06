const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const db = require('../db');
const { HttpError } = require('../errors');
const { requireAuth } = require('../middleware/auth');
const { camelizeKeys } = require('../utils/camelize');
const { sendEmail } = require('../utils/email');
const { uuid, generateOtp, wrap } = require('../utils/helpers');

const router = express.Router();

const USER_FIELDS = `
  id, name, email, phone, profile_image, role, is_active, created_at, updated_at
`;

function signToken(user) {
  return jwt.sign(
    { sub: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
  );
}

async function findUserByEmail(email) {
  const [rows] = await db.query(`SELECT ${USER_FIELDS} FROM users WHERE email = ?`, [email]);
  return rows[0] || null;
}

async function createOtp(email, purpose, code) {
  await db.query(
    `INSERT INTO otps (id, email, purpose, code, expires_at)
     VALUES (?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))`,
    [uuid(), email, purpose, code]
  );
}

async function isValidOtp(email, purpose, code) {
  const [rows] = await db.query(
    `SELECT id FROM otps
     WHERE email = ? AND purpose = ? AND code = ? AND used = 0 AND expires_at > NOW()
     ORDER BY created_at DESC LIMIT 1`,
    [email, purpose, code]
  );
  if (!rows.length) return null;
  const id = rows[0].id;
  await db.query(`UPDATE otps SET used = 1 WHERE id = ?`, [id]);
  return id;
}

router.post(
  '/register',
  wrap(async (req, res) => {
    const { name, email, phone, password } = req.body || {};

    if (!name || !email || !password) {
      throw new HttpError(400, 'Name, email and password are required');
    }
    if (String(password).length < 6) {
      throw new HttpError(400, 'Password must be at least 6 characters');
    }
    const normalizedEmail = String(email).toLowerCase().trim();

    const existing = await findUserByEmail(normalizedEmail);
    if (existing) {
      throw new HttpError(409, 'An account with this email already exists');
    }

    const passwordHash = await bcrypt.hash(String(password), 10);
    const userRow = {
      id: uuid(),
      name: String(name).trim(),
      email: normalizedEmail,
      phone: phone ? String(phone).trim() : null,
      password_hash: passwordHash,
    };

    await db.query(
      `INSERT INTO users (id, name, email, phone, password_hash)
       VALUES (?, ?, ?, ?, ?)`,
      [userRow.id, userRow.name, userRow.email, userRow.phone, userRow.password_hash]
    );

    await db.query(
      `INSERT INTO notifications (id, user_id, type, title, body)
       VALUES (?, ?, 'system', 'Welcome to Park Ease!', ?)`,
      [uuid(), userRow.id, 'Explore parking spots near you and book instantly.']
    );

    const [created] = await db.query(
      `SELECT ${USER_FIELDS} FROM users WHERE id = ?`,
      [userRow.id]
    );
    const user = camelizeKeys(created[0]);

    res.status(201).json({ token: signToken(created[0]), user });
  })
);

router.post(
  '/login',
  wrap(async (req, res) => {
    const { email, password } = req.body || {};
    if (!email || !password) {
      throw new HttpError(400, 'Email and password are required');
    }

    const [rows] = await db.query(
      `SELECT ${USER_FIELDS} FROM users WHERE email = ?`,
      [String(email).toLowerCase().trim()]
    );
    const row = rows[0];
    if (!row || row.is_active !== 1) {
      throw new HttpError(401, 'Invalid email or password');
    }

    const [hashRows] = await db.query(
      `SELECT password_hash FROM users WHERE id = ?`,
      [row.id]
    );
    const valid = await bcrypt.compare(String(password), hashRows[0].password_hash);
    if (!valid) {
      throw new HttpError(401, 'Invalid email or password');
    }

    res.json({ token: signToken(row), user: camelizeKeys(row) });
  })
);

router.post(
  '/logout',
  requireAuth,
  wrap(async (req, res) => {
    res.json({ message: 'Logged out successfully' });
  })
);

router.post(
  '/otp',
  wrap(async (req, res) => {
    const { email, otp } = req.body || {};
    if (!email) {
      throw new HttpError(400, 'Email is required');
    }

    if (!otp) {
      const code = generateOtp();
      await createOtp(String(email).toLowerCase().trim(), 'register', code);
      await sendEmail(
        email,
        'Your Park Ease verification code',
        `<p>Your verification code is <b>${code}</b>. It expires in 15 minutes.</p>`
      );
      return res.json({ message: 'OTP sent successfully' });
    }

    const valid = await isValidOtp(String(email).toLowerCase().trim(), 'register', otp);
    if (!valid) {
      throw new HttpError(400, 'Invalid or expired OTP');
    }
    res.json({ message: 'OTP verified successfully' });
  })
);

router.post(
  '/forgot-password',
  wrap(async (req, res) => {
    const { email } = req.body || {};
    if (!email) {
      throw new HttpError(400, 'Email is required');
    }

    const normalizedEmail = String(email).toLowerCase().trim();
    const user = await findUserByEmail(normalizedEmail);
    if (!user) {
      throw new HttpError(404, 'No account found with this email');
    }

    const code = generateOtp();
    await createOtp(normalizedEmail, 'password_reset', code);
    await sendEmail(
      normalizedEmail,
      'Your Park Ease password reset code',
      `<p>Your password reset code is <b>${code}</b>. It expires in 15 minutes.</p>`
    );

    res.json({ message: 'Password reset code sent to your email' });
  })
);

router.post(
  '/reset-password',
  wrap(async (req, res) => {
    const { email, otp, newPassword } = req.body || {};
    if (!email || !otp || !newPassword) {
      throw new HttpError(400, 'Email, OTP and new password are required');
    }
    if (String(newPassword).length < 6) {
      throw new HttpError(400, 'Password must be at least 6 characters');
    }

    const normalizedEmail = String(email).toLowerCase().trim();
    const valid = await isValidOtp(normalizedEmail, 'password_reset', otp);
    if (!valid) {
      throw new HttpError(400, 'Invalid or expired OTP');
    }

    const passwordHash = await bcrypt.hash(String(newPassword), 10);
    const [result] = await db.query(
      `UPDATE users SET password_hash = ? WHERE email = ?`,
      [passwordHash, normalizedEmail]
    );
    if (!result.affectedRows) {
      throw new HttpError(404, 'No account found with this email');
    }

    res.json({ message: 'Password reset successfully' });
  })
);

module.exports = router;