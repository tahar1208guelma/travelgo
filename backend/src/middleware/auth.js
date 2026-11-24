/**
 * @file auth.js
 * @description Authentication and Role-Based Access Control (RBAC) middleware for TravelGo Gateway.
 * Supports UserRole.user, UserRole.partner, UserRole.admin, and Guest mode.
 */

import crypto from 'node:crypto';
import { config } from '../config/environment.js';

export const UserRole = {
  USER: 'user',
  PARTNER: 'partner',
  ADMIN: 'admin'
};

/**
 * Encodes object to Base64URL string
 */
function base64UrlEncode(str) {
  return Buffer.from(str)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

/**
 * Decodes Base64URL string to Buffer
 */
function base64UrlDecode(str) {
  let base64 = str.replace(/-/g, '+').replace(/_/g, '/');
  while (base64.length % 4) {
    base64 += '=';
  }
  return Buffer.from(base64, 'base64').toString('utf8');
}

/**
 * Generates an HMAC-SHA256 signed JWT
 */
export function signJwt(payload, secret = config.jwt.secret, expiresInSeconds = 7 * 24 * 3600) {
  const header = { alg: 'HS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const fullPayload = {
    ...payload,
    iat: now,
    exp: now + expiresInSeconds
  };

  const headerB64 = base64UrlEncode(JSON.stringify(header));
  const payloadB64 = base64UrlEncode(JSON.stringify(fullPayload));
  const signature = crypto
    .createHmac('sha256', secret)
    .update(`${headerB64}.${payloadB64}`)
    .digest('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');

  return `${headerB64}.${payloadB64}.${signature}`;
}

/**
 * Verifies and decodes an HMAC-SHA256 signed JWT
 */
export function verifyJwt(token, secret = config.jwt.secret) {
  if (!token || typeof token !== 'string') {
    throw new Error('Token is missing or invalid');
  }

  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('Malformed JWT');
  }

  const [headerB64, payloadB64, signature] = parts;
  const expectedSig = crypto
    .createHmac('sha256', secret)
    .update(`${headerB64}.${payloadB64}`)
    .digest('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');

  if (signature !== expectedSig) {
    throw new Error('Invalid JWT signature');
  }

  const payload = JSON.parse(base64UrlDecode(payloadB64));
  const now = Math.floor(Date.now() / 1000);

  if (payload.exp && payload.exp < now) {
    throw new Error('JWT token has expired');
  }

  return payload;
}

/**
 * Optional authentication (parses token if present, sets guest otherwise)
 */
export function authenticateOptional(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7);
    try {
      const decoded = verifyJwt(token);
      req.user = decoded;
    } catch {
      req.user = { isGuest: true, role: UserRole.USER };
    }
  } else {
    req.user = { isGuest: true, role: UserRole.USER };
  }
  next();
}

/**
 * Strict authentication guard
 */
export function requireAuth(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.statusCode = 401;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ error: 'Unauthorized', message: 'Bearer token required' }));
    return;
  }

  const token = authHeader.substring(7);
  try {
    const decoded = verifyJwt(token);
    if (decoded.isGuest) {
      res.statusCode = 403;
      res.setHeader('Content-Type', 'application/json');
      res.end(JSON.stringify({ error: 'Forbidden', message: 'Full account registration required for this action' }));
      return;
    }
    req.user = decoded;
    next();
  } catch (err) {
    res.statusCode = 401;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ error: 'Unauthorized', message: err.message }));
  }
}

/**
 * Admin role guard
 */
export function requireAdmin(req, res, next) {
  requireAuth(req, res, () => {
    if (req.user?.role !== UserRole.ADMIN) {
      res.statusCode = 403;
      res.setHeader('Content-Type', 'application/json');
      res.end(JSON.stringify({ error: 'Forbidden', message: 'Administrator privileges required' }));
      return;
    }
    next();
  });
}

/**
 * Partner or Admin role guard
 */
export function requirePartner(req, res, next) {
  requireAuth(req, res, () => {
    if (req.user?.role !== UserRole.PARTNER && req.user?.role !== UserRole.ADMIN) {
      res.statusCode = 403;
      res.setHeader('Content-Type', 'application/json');
      res.end(JSON.stringify({ error: 'Forbidden', message: 'Partner or Administrator privileges required' }));
      return;
    }
    next();
  });
}
