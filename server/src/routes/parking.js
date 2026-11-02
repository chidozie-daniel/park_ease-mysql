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
const OSM_CACHE_TTL_MS = 300_000;
const OSM_MAX_RESULTS = 40;
const osmCache = new Map();
let nextNominatimRequestAt = 0;

function parkingAddress(tags, latitude, longitude) {
  if (tags['addr:full']) return tags['addr:full'];

  const street = [tags['addr:housenumber'], tags['addr:street']]
    .filter(Boolean)
    .join(' ');
  const locality = [
    tags['addr:suburb'],
    tags['addr:city'] || tags['addr:town'] || tags['addr:village'],
    tags['addr:country'],
  ]
    .filter(Boolean)
    .join(', ');
  const address = [street, locality].filter(Boolean).join(', ');
  return address || `Mapped parking location (${latitude.toFixed(5)}, ${longitude.toFixed(5)})`;
}

function mapOsmParking(element) {
  const latitude = Number(element.lat);
  const longitude = Number(element.lon);
  if (
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    element.category !== 'amenity' ||
    element.type !== 'parking'
  ) {
    return null;
  }

  const tags = element.extratags || {};
  const parkingType = tags.parking;
  const type =
    parkingType === 'underground'
      ? 'underground'
      : parkingType === 'multi-storey'
        ? 'indoor'
        : parkingType === 'covered'
          ? 'covered'
          : 'outdoor';
  const amenities = [];
  if (tags.fee) amenities.push(tags.fee === 'yes' ? 'Paid parking' : 'No parking fee');
  if (tags.capacity) amenities.push(`Capacity: ${tags.capacity}`);
  if (tags.opening_hours) amenities.push(`Hours: ${tags.opening_hours}`);

  return {
    id: `osm_${element.osm_type}_${element.osm_id}`,
    name:
      element.name ||
      `Parking area near ${element.display_name?.split(',')[0] || 'this location'}`,
    address: element.display_name || parkingAddress(tags, latitude, longitude),
    latitude,
    longitude,
    type,
    totalSlots: 0,
    availableSlots: 0,
    hourlyRate: 0,
    dailyRate: null,
    description: 'Mapped by OpenStreetMap. Confirm access, rates, and availability on site.',
    amenities,
    status: 'available',
    imageUrl: null,
    isActive: true,
    isBookable: false,
    source: 'openstreetmap',
    createdAt: new Date(0).toISOString(),
    updatedAt: null,
  };
}

async function findOsmParking(latitude, longitude, radiusKm, searchTerm) {
  const cacheKey = `${latitude.toFixed(3)},${longitude.toFixed(3)},${radiusKm},${searchTerm.toLowerCase()}`;
  const cached = osmCache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) return cached.places;

  const latitudePadding = radiusKm / KM_PER_DEGREE;
  const longitudePadding =
    radiusKm /
    (KM_PER_DEGREE * Math.max(0.01, Math.cos((latitude * Math.PI) / 180)));
  const viewbox = [
    Math.max(-180, longitude - longitudePadding),
    Math.min(90, latitude + latitudePadding),
    Math.min(180, longitude + longitudePadding),
    Math.max(-90, latitude - latitudePadding),
  ].join(',');
  const searchQuery = searchTerm
    ? /\bparking\b/i.test(searchTerm)
      ? searchTerm
      : `${searchTerm} parking`
    : 'parking';
  const params = new URLSearchParams({
    q: searchQuery,
    format: 'jsonv2',
    viewbox,
    bounded: '1',
    limit: String(OSM_MAX_RESULTS),
    addressdetails: '1',
    extratags: '1',
  });

  const delay = Math.max(0, nextNominatimRequestAt - Date.now());
  if (delay > 0) {
    await new Promise((resolve) => setTimeout(resolve, delay));
  }
  nextNominatimRequestAt = Date.now() + 1_000;

  const response = await fetch(
    `https://nominatim.openstreetmap.org/search?${params.toString()}`,
    {
      headers: {
        'User-Agent':
          'ParkEase/1.0 (+https://github.com/chidozie-daniel/park_ease-mysql)',
        Accept: 'application/json',
      },
      signal: AbortSignal.timeout(10_000),
    }
  );

  if (!response.ok) {
    throw new Error(`OpenStreetMap search returned HTTP ${response.status}`);
  }
  const payload = await response.json();
  if (!Array.isArray(payload)) {
    throw new Error('OpenStreetMap search returned an invalid response');
  }

  const places = payload
    .map(mapOsmParking)
    .filter(Boolean)
    .filter(
      (place) =>
        distanceKm(latitude, longitude, place.latitude, place.longitude) <= radiusKm
    );
  for (const [key, entry] of osmCache) {
    if (entry.expiresAt <= Date.now()) osmCache.delete(key);
  }
  osmCache.set(cacheKey, { places, expiresAt: Date.now() + OSM_CACHE_TTL_MS });
  return places;
}

function distanceKm(aLat, aLng, bLat, bLng) {
  const toRadians = (degrees) => (degrees * Math.PI) / 180;
  const latDelta = toRadians(bLat - aLat);
  const lngDelta = toRadians(bLng - aLng);
  const a =
    Math.sin(latDelta / 2) ** 2 +
    Math.cos(toRadians(aLat)) *
      Math.cos(toRadians(bLat)) *
      Math.sin(lngDelta / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

router.get(
  '/search',
  requireAuth,
  wrap(async (req, res) => {
    const { lat, lng, radius, q } = req.query;
    const searchTerm = typeof q === 'string' ? q.trim().slice(0, 100) : '';

    let rows;
    if (lat !== undefined && lng !== undefined) {
      const latitude = parseFloat(lat);
      const longitude = parseFloat(lng);
      const radiusKm = radius === undefined ? 10 : parseFloat(radius);

      if (
        !Number.isFinite(latitude) ||
        !Number.isFinite(longitude) ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180
      ) {
        throw new HttpError(400, 'Invalid latitude or longitude');
      }
      if (!Number.isFinite(radiusKm) || radiusKm <= 0 || radiusKm > 10) {
        throw new HttpError(400, 'Radius must be greater than 0 and at most 10 km');
      }

      const queryCondition = searchTerm
        ? `AND (name LIKE ? OR address LIKE ?)`
        : '';
      const queryValues = searchTerm
        ? [`%${searchTerm}%`, `%${searchTerm}%`]
        : [];
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
           ${queryCondition}
           AND (${KM_PER_DEGREE} * 1000 *
            (ACOS(
              LEAST(1.0, COS(RADIANS(?)) * COS(RADIANS(latitude)) *
                COS(RADIANS(longitude) - RADIANS(?)) +
                SIN(RADIANS(?)) * SIN(RADIANS(latitude)))
            )) / 1000) <= ?
         ORDER BY distance_km ASC`,
        [
          latitude,
          longitude,
          latitude,
          ...queryValues,
          latitude,
          longitude,
          latitude,
          radiusKm,
        ]
      );

      let lots = result.map((lot) => {
        const { distance_km: distanceKm, ...rest } = lot;
        return { ...camelizeKeys(rest), distanceKm: Math.round(distanceKm * 100) / 100 };
      });

      const warnings = [];
      try {
        let osmPlaces = await findOsmParking(
          latitude,
          longitude,
          radiusKm,
          searchTerm
        );
        if (searchTerm) {
          const normalizedTerm = searchTerm.toLocaleLowerCase();
          osmPlaces = osmPlaces.filter((place) =>
            `${place.name} ${place.address} ${place.amenities.join(' ')}`
              .toLocaleLowerCase()
              .includes(normalizedTerm)
          );
        }

        const registeredPlaces = lots;
        const uniqueOsmPlaces = osmPlaces.filter(
          (place) =>
            !registeredPlaces.some(
              (registered) =>
                distanceKm(
                  registered.latitude,
                  registered.longitude,
                  place.latitude,
                  place.longitude
                ) < 0.05
            )
        );
        lots = [...registeredPlaces, ...uniqueOsmPlaces].sort(
          (a, b) =>
            distanceKm(latitude, longitude, a.latitude, a.longitude) -
            distanceKm(latitude, longitude, b.latitude, b.longitude)
        );
      } catch (error) {
        console.warn('[parking] OpenStreetMap search unavailable:', error.message);
        warnings.push(
          'OpenStreetMap search is unavailable right now. Showing registered lots only.'
        );
      }

      return res.json({ data: lots, warnings });
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