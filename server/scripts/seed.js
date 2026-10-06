require('dotenv').config();

const bcrypt = require('bcryptjs');

const db = require('../src/db');
const { uuid } = require('../src/utils/helpers');
const { camelizeKeys } = require('../src/utils/camelize');

async function seed() {
  const adminId = uuid();
  const userId = uuid();

  const [adminHash] = await db.query(`SELECT id FROM users WHERE email = ?`, [
    'admin@parkease.com',
  ]);
  const [userHash] = await db.query(`SELECT id FROM users WHERE email = ?`, [
    'user@parkease.com',
  ]);
  if (adminHash.length || userHash.length) {
    throw new Error('Seed already run. Delete the rows (or re-run db:setup) to reseed.');
  }

  const passwordHash = await bcrypt.hash('Password@123', 10);

  await db.query(
    `INSERT INTO users (id, name, email, phone, password_hash, role, is_active)
     VALUES (?, ?, ?, ?, ?, ?, 1)`,
    [adminId, 'Admin User', 'admin@parkease.com', '08000000001', passwordHash, 'admin']
  );
  await db.query(
    `INSERT INTO users (id, name, email, phone, password_hash, role, is_active)
     VALUES (?, ?, ?, ?, ?, 'user', 1)`,
    [userId, 'Demo User', 'user@parkease.com', '08000000002', passwordHash]
  );

  await db.query(
    `INSERT INTO notifications (id, user_id, type, title, body)
     VALUES (?, ?, 'system', 'Welcome to Park Ease!',
       'Explore parking spots near you and book instantly.')`,
    [uuid(), userId]
  );

  const lots = [
    {
      name: 'Downtown Mall Parking',
      address: '12 Marina Drive, Lagos Island',
      latitude: 6.4474,
      longitude: 3.3866,
      type: 'indoor',
      totalSlots: 40,
      hourlyRate: 3.5,
      dailyRate: 25,
      amenities: ['EV Charging', 'CCTV', 'Covered'],
    },
    {
      name: 'Victoria Island Garage',
      address: '5 Akin Adesola St, Victoria Island',
      latitude: 6.4281,
      longitude: 3.4219,
      type: 'underground',
      totalSlots: 30,
      hourlyRate: 4.0,
      dailyRate: 28,
      amenities: ['CCTV', 'Security', 'Handicap Access'],
    },
    {
      name: 'Airport Express Parking',
      address: 'International Airport Road',
      latitude: 6.5774,
      longitude: 3.3211,
      type: 'outdoor',
      totalSlots: 80,
      hourlyRate: 2.5,
      dailyRate: 18,
      amenities: ['24/7', 'Shuttle', 'Outdoor'],
    },
    {
      name: 'Central Business District Lot',
      address: 'Marina, Lagos Island',
      latitude: 6.4531,
      longitude: 3.3958,
      type: 'covered',
      totalSlots: 25,
      hourlyRate: 3.0,
      dailyRate: 22,
      amenities: ['CCTV', 'Covered', 'EV Charging'],
    },
  ];

  for (const lot of lots) {
    const lotId = uuid();
    await db.query(
      `INSERT INTO parking_lots
         (id, name, address, latitude, longitude, type, total_slots, available_slots,
          hourly_rate, daily_rate, amenities, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'available')`,
      [
        lotId,
        lot.name,
        lot.address,
        lot.latitude,
        lot.longitude,
        lot.type,
        lot.totalSlots,
        lot.totalSlots,
        lot.hourlyRate,
        lot.dailyRate,
        JSON.stringify(lot.amenities),
      ]
    );

    for (let i = 1; i <= lot.totalSlots; i++) {
      const slotType = i % 10 === 0 ? 'ev' : i % 7 === 0 ? 'handicap' : 'regular';
      await db.query(
        `INSERT INTO parking_slots (id, parking_lot_id, slot_number, type, status, price_multiplier)
         VALUES (?, ?, ?, ?, 'available', ?)`,
        [uuid(), lotId, String(i).padStart(2, '0'), slotType, slotType === 'ev' ? 1.2 : null]
      );
    }
  }

  const vehicleId = uuid();
  await db.query(
    `INSERT INTO vehicles (id, user_id, type, brand, model, color, license_plate, is_default)
     VALUES (?, ?, 'car', 'Toyota', 'Camry', 'Black', 'LND-1234', 1)`,
    [vehicleId, userId]
  );

  await db.end();
  console.log('Seed complete.');
  console.log('  Admin: admin@parkease.com / Password@123');
  console.log('  User : user@parkease.com / Password@123');
}

seed().catch(async (err) => {
  console.error('Seeding failed:', err.message);
  await db.end().catch(() => {});
  process.exit(1);
});