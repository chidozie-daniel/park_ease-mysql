const BOOL_KEYS = new Set([
  'is_active',
  'isActive',
  'is_read',
  'isRead',
  'is_default',
  'isDefault',
  'used',
]);

const MYSQL_DATETIME = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/;

function toCamel(str) {
  return String(str).replace(/_([a-z0-9])/gi, (_, c) => c.toUpperCase());
}

function normalize(value) {
  if (typeof value === 'string' && MYSQL_DATETIME.test(value)) {
    return value.replace(' ', 'T');
  }
  return value;
}

function camelizeValue(key, value) {
  if (BOOL_KEYS.has(key)) {
    return value === 1 || value === true ? true : false;
  }
  return normalize(value);
}

function camelizeKeys(value) {
  if (Array.isArray(value)) {
    return value.map(camelizeKeys);
  }
  if (value !== null && typeof value === 'object') {
    const out = {};
    for (const rawKey of Object.keys(value)) {
      const key = toCamel(rawKey);
      out[key] = camelizeValue(rawKey, camelizeKeys(value[rawKey]));
    }
    return out;
  }
  return normalize(value);
}

module.exports = { camelizeKeys };