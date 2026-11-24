/**
 * @file auth_and_roles.test.js
 * @description Automated Unit Tests for JWT signing, verification, and RBAC roles.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { signJwt, verifyJwt, UserRole } from '../src/middleware/auth.js';

test('Auth & RBAC - Token Operations', async (t) => {
  const secret = 'test_secret_key_12345678901234567890';

  await t.test('signs and verifies valid customer JWT', () => {
    const payload = { id: 'usr_123', email: 'user@travel.com', role: UserRole.USER, isGuest: false };
    const token = signJwt(payload, secret, 3600);
    const decoded = verifyJwt(token, secret);

    assert.equal(decoded.id, 'usr_123');
    assert.equal(decoded.email, 'user@travel.com');
    assert.equal(decoded.role, UserRole.USER);
    assert.equal(decoded.isGuest, false);
  });

  await t.test('signs and verifies hotel partner JWT', () => {
    const payload = { id: 'ptr_456', email: 'owner@grandhotel.com', role: UserRole.PARTNER, isGuest: false };
    const token = signJwt(payload, secret, 3600);
    const decoded = verifyJwt(token, secret);

    assert.equal(decoded.role, UserRole.PARTNER);
  });

  await t.test('signs and verifies administrator JWT', () => {
    const payload = { id: 'adm_789', email: 'admin@travelgo.com', role: UserRole.ADMIN, isGuest: false };
    const token = signJwt(payload, secret, 3600);
    const decoded = verifyJwt(token, secret);

    assert.equal(decoded.role, UserRole.ADMIN);
  });

  await t.test('rejects tampered signature', () => {
    const token = signJwt({ id: 'usr_1' }, secret, 3600);
    const tampered = token.substring(0, token.length - 4) + 'abcd';

    assert.throws(
      () => verifyJwt(tampered, secret),
      /Invalid JWT signature/
    );
  });

  await t.test('rejects expired token', () => {
    // expiresIn -10 seconds
    const expiredToken = signJwt({ id: 'usr_expired' }, secret, -10);

    assert.throws(
      () => verifyJwt(expiredToken, secret),
      /expired/
    );
  });
});
