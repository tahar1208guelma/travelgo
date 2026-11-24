/**
 * @file commission_calculator.test.js
 * @description Automated Unit Tests for Deterministic Commission Arithmetic.
 * Verifies AGENTS.md rules 11, 12, and 13.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { CommissionCalculator } from '../src/services/commission_calculator.js';

test('CommissionCalculator - Direct Booking Arithmetic', async (t) => {
  await t.test('computes direct booking with standard $1.00 platform fee', () => {
    const result = CommissionCalculator.calculateDirectBooking({
      baseFare: 320.00,
      taxes: 45.00,
      serviceFee: 1.00,
      commissionRate: 0.0075 // 0.75%
    });

    assert.equal(result.baseFare, 320.00);
    assert.equal(result.taxes, 45.00);
    assert.equal(result.serviceFee, 1.00);
    // Total = 320 + 45 + 1 = 366.00
    assert.equal(result.totalAmount, 366.00);
    // Commission = 320 * 0.0075 = 2.40
    assert.equal(result.commissionAmount, 2.40);
    // Provider Payout = (320 + 45) - 2.40 = 362.60
    assert.equal(result.providerPayout, 362.60);
    // Net Platform Revenue = 1.00 + 2.40 = 3.40
    assert.equal(result.platformRevenue, 3.40);
  });

  await t.test('computes hotel partner direct booking with 12% commission', () => {
    const result = CommissionCalculator.calculateDirectBooking({
      baseFare: 150.00,
      taxes: 15.00,
      serviceFee: 1.00,
      commissionRate: 0.12 // 12% partner commission
    });

    assert.equal(result.totalAmount, 166.00); // 150 + 15 + 1
    assert.equal(result.commissionAmount, 18.00); // 150 * 0.12 = 18.00
    assert.equal(result.providerPayout, 147.00); // (150 + 15) - 18 = 147.00
    assert.equal(result.platformRevenue, 19.00); // 1.00 + 18.00 = 19.00
  });

  await t.test('enforces non-negative inputs', () => {
    assert.throws(
      () => CommissionCalculator.calculateDirectBooking({ baseFare: -50, taxes: 10 }),
      /non-negative/
    );
  });
});

test('CommissionCalculator - Affiliate Redirect Arithmetic', async (t) => {
  await t.test('enforces strictly $0.00 platform markup on affiliate redirects', () => {
    const result = CommissionCalculator.calculateAffiliateRedirect({
      baseFare: 250.00,
      taxes: 30.00
    });

    assert.equal(result.serviceFee, 0.00);
    assert.equal(result.platformMarkup, 0.00);
    assert.equal(result.totalAmount, 280.00);
  });
});

test('CommissionCalculator - Refund Arithmetic', async (t) => {
  await t.test('standard refund returns base fare + taxes and retains $1.00 service fee', () => {
    const refund = CommissionCalculator.calculateRefund({
      baseFare: 200.00,
      taxes: 25.00,
      serviceFee: 1.00,
      isFullRefund: false
    });

    assert.equal(refund.customerRefundAmount, 225.00);
    assert.equal(refund.retainedPlatformFee, 1.00);
  });

  await t.test('full operational waiver refund returns entire total including service fee', () => {
    const refund = CommissionCalculator.calculateRefund({
      baseFare: 200.00,
      taxes: 25.00,
      serviceFee: 1.00,
      isFullRefund: true
    });

    assert.equal(refund.customerRefundAmount, 226.00);
    assert.equal(refund.retainedPlatformFee, 0.00);
  });
});
