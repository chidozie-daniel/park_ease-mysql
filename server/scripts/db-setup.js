require('dotenv').config();

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

async function main() {
  const schema = fs.readFileSync(path.join(__dirname, '..', 'schema.sql'), 'utf8');

  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    multipleStatements: true,
  });

  console.log(`Connecting to MySQL at ${process.env.DB_HOST}:${process.env.DB_PORT}...`);
  await connection.query(schema);
  console.log('Schema created. Tables are ready.');
  await connection.end();
}

main().catch((err) => {
  console.error('Database setup failed:', err.message);
  process.exit(1);
});