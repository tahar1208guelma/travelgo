/**
 * @file rate_limiter.test.js
 * @description Automated Unit Tests for Sliding Window Rate Limiting.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { RateLimiter } from '../src/middleware/rate_limiter.js';

test('RateLimiter - Sliding Window Enforcement', async (t) => {
  await t.test('allows requests within threshold', () => {
    const limiter = new RateLimiter({ windowMs: 1000, max: 3, name: 'test' });
    const res1 = limiter.check('client_1');
    const res2 = limiter.check('client_1');
    const res3 = limiter.check('client_1');

    assert.equal(res1.allowed, true);
    assert.equal(res1.remaining, 2);
    assert.equal(res2.allowed, true);
    assert.equal(res2.remaining, 1);
    assert.equal(res3.allowed, true);
    assert.equal(res3.remaining, 0);
  });

  await t.test('blocks bursts exceeding the limit with 429 status', () => {
    const limiter = new RateLimiter({ windowMs: 1000, max: 2, name: 'test' });
    limiter.check('client_2');
    limiter.check('client_2');
    const overLimit = limiter.check('client_2');

    assert.equal(overLimit.allowed, false);
    assert.equal(overLimit.remaining, 0);
    assert(overLimit.resetTime >= 1);
  });

  await t.test('isolates different clients', () => {
    const limiter = new RateLimiter({ windowMs: 1000, max: 1, name: 'test' });
    const clientA1 = limiter.check('client_A');
    const clientA2 = limiter.check('client_A');
    const clientB1 = limiter.check('client_B');

    assert.equal(clientA1.allowed, true);
    assert.equal(clientA2.allowed, false);
    assert.equal(clientB1.allowed, true); // Distinct client is not blocked
  });
});
