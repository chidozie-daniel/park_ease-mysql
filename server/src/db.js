const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  dateStrings: true,
});

/**
 * Runs `fn` inside a transaction on a dedicated connection, committing on
 * success and rolling back on any throw. Use this whenever a read must be
 * paired with a write that depends on it (check-then-reserve, decrement-then-
 * insert), otherwise concurrent requests can interleave and both pass the
 * check.
 */
async function withTransaction(fn) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const result = await fn(connection);
    await connection.commit();
    return result;
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

// Note: only attach names that do not already exist on the pool object.
// mysql2's PromisePool keeps its core pool on an internal `.pool` property,
// so overwriting that breaks query resolution.
module.exports = pool;
module.exports.withTransaction = withTransaction;