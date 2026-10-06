-- Park Ease database schema
-- Run via: npm run db:setup
-- Requires MySQL running locally with the DB_USER/DB_PASSWORD from .env

CREATE DATABASE IF NOT EXISTS park_ease
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE park_ease;

CREATE TABLE IF NOT EXISTS users (
  id            CHAR(36) PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  email         VARCHAR(190) NOT NULL UNIQUE,
  phone         VARCHAR(20) NULL,
  password_hash VARCHAR(255) NOT NULL,
  profile_image VARCHAR(500) NULL,
  role          ENUM('user','admin') NOT NULL DEFAULT 'user',
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  push_token    VARCHAR(500) NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS parking_lots (
  id              CHAR(36) PRIMARY KEY,
  name            VARCHAR(150) NOT NULL,
  address         VARCHAR(300) NOT NULL,
  latitude        DECIMAL(10,7) NOT NULL,
  longitude       DECIMAL(10,7) NOT NULL,
  type            ENUM('indoor','outdoor','covered','underground') NOT NULL DEFAULT 'indoor',
  total_slots     INT NOT NULL DEFAULT 0,
  available_slots INT NOT NULL DEFAULT 0,
  hourly_rate     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  daily_rate      DECIMAL(10,2) NULL,
  description     TEXT NULL,
  amenities       JSON NULL,
  status          ENUM('available','full','closed') NOT NULL DEFAULT 'available',
  image_url       VARCHAR(500) NULL,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_lots_status (is_active, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS parking_slots (
  id              CHAR(36) PRIMARY KEY,
  parking_lot_id  CHAR(36) NOT NULL,
  slot_number     VARCHAR(20) NOT NULL,
  type            ENUM('regular','ev','handicap','premium','motorcycle') NOT NULL DEFAULT 'regular',
  status          ENUM('available','occupied','reserved','maintenance') NOT NULL DEFAULT 'available',
  price_multiplier DECIMAL(3,2) NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_slot_lot_number (parking_lot_id, slot_number),
  CONSTRAINT fk_slots_lot FOREIGN KEY (parking_lot_id)
    REFERENCES parking_lots (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehicles (
  id             CHAR(36) PRIMARY KEY,
  user_id        CHAR(36) NOT NULL,
  type           ENUM('car','bike','scooter','truck') NOT NULL,
  brand          VARCHAR(80) NULL,
  model          VARCHAR(80) NULL,
  color          VARCHAR(50) NULL,
  license_plate  VARCHAR(20) NOT NULL,
  is_default     TINYINT(1) NOT NULL DEFAULT 0,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_vehicles_user (user_id),
  CONSTRAINT fk_vehicles_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bookings (
  id              CHAR(36) PRIMARY KEY,
  user_id         CHAR(36) NOT NULL,
  parking_lot_id  CHAR(36) NOT NULL,
  parking_slot_id CHAR(36) NULL,
  vehicle_id      CHAR(36) NULL,
  start_time      DATETIME NOT NULL,
  end_time        DATETIME NOT NULL,
  total_amount    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  discount_amount DECIMAL(10,2) NULL,
  status          ENUM('pending','confirmed','checked_in','checked_out','cancelled','no_show') NOT NULL DEFAULT 'pending',
  qr_code         VARCHAR(255) NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_bookings_user (user_id),
  INDEX idx_bookings_status (status),
  CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_bookings_lot FOREIGN KEY (parking_lot_id) REFERENCES parking_lots (id),
  CONSTRAINT fk_bookings_slot FOREIGN KEY (parking_slot_id) REFERENCES parking_slots (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id               CHAR(36) PRIMARY KEY,
  booking_id       CHAR(36) NULL,
  user_id          CHAR(36) NOT NULL,
  amount           DECIMAL(10,2) NOT NULL,
  method           ENUM('credit_card','debit_card','upi','wallet','net_banking','cash') NOT NULL,
  status           ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  transaction_id   VARCHAR(255) NULL,
  paid_at          DATETIME NULL,
  gateway_response JSON NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_payments_user (user_id),
  CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings (id),
  CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
  id         CHAR(36) PRIMARY KEY,
  user_id    CHAR(36) NOT NULL,
  type       ENUM('booking','payment','reminder','promotion','alert','system') NOT NULL DEFAULT 'system',
  title      VARCHAR(200) NOT NULL,
  body       TEXT NULL,
  is_read    TINYINT(1) NOT NULL DEFAULT 0,
  data       JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_notifications_user (user_id),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS otps (
  id         CHAR(36) PRIMARY KEY,
  email      VARCHAR(190) NOT NULL,
  purpose    ENUM('register','password_reset') NOT NULL DEFAULT 'register',
  code       VARCHAR(6) NOT NULL,
  expires_at DATETIME NOT NULL,
  used       TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_otps_email (email)
) ENGINE=InnoDB;