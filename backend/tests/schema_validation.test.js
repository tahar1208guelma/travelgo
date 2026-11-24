/**
 * @file schema_validation.test.js
 * @description Automated Unit Tests for API Request Schemas.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { ApiSchemas, ValidationError } from '../src/schemas/api_schemas.js';

test('ApiSchemas - Flight Search Validation', async (t) => {
  await t.test('accepts valid flight search query', () => {
    const valid = {
      origin: 'ALG',
      destination: 'DXB',
      departureDate: '2026-12-01',
      returnDate: '2026-12-10',
      adults: '2',
      cabinClass: 'economy'
    };
    const result = ApiSchemas.validateFlightSearch(valid);
    assert.equal(result.origin, 'ALG');
    assert.equal(result.destination, 'DXB');
    assert.equal(result.adults, 2);
  });

  await t.test('rejects identical origin and destination', () => {
    assert.throws(
      () => ApiSchemas.validateFlightSearch({
        origin: 'DXB',
        destination: 'DXB',
        departureDate: '2026-12-01',
        adults: '1'
      }),
      (err) => {
        assert(err instanceof ValidationError);
        assert(err.errors.some(e => e.message.includes('identical')));
        return true;
      }
    );
  });

  await t.test('rejects invalid IATA codes', () => {
    assert.throws(
      () => ApiSchemas.validateFlightSearch({
        origin: 'ALGERIA',
        destination: 'DXB',
        departureDate: '2026-12-01'
      }),
      (err) => err instanceof ValidationError
    );
  });

  await t.test('rejects returnDate before departureDate', () => {
    assert.throws(
      () => ApiSchemas.validateFlightSearch({
        origin: 'ALG',
        destination: 'DXB',
        departureDate: '2026-12-10',
        returnDate: '2026-12-01'
      }),
      (err) => err instanceof ValidationError
    );
  });
});

test('ApiSchemas - Direct Booking Validation', async (t) => {
  await t.test('accepts valid direct booking payload with $1.00 USD service fee', () => {
    const validPayload = {
      bookingType: 'flight',
      provider: 'Amadeus',
      itemId: 'fl_EK_ALG_DXB_1',
      itemName: 'Emirates ALG -> DXB',
      startDate: '2026-12-01T08:30:00Z',
      contactDetails: {
        name: 'Sarah Connor',
        email: 'sarah@traveler.com',
        phone: '+213555123456'
      },
      basePriceUSD: 300.00,
      taxesUSD: 45.00,
      serviceFeeUSD: 1.00, // Strict $1.00 platform fee
      totalAmountUSD: 346.00 // 300 + 45 + 1.00
    };
    const result = ApiSchemas.validateCreateBooking(validPayload);
    assert.equal(result.serviceFeeUSD, 1.00);
    assert.equal(result.totalAmountUSD, 346.00);
  });

  await t.test('rejects booking if service fee does not equal $1.00 USD standard platform fee', () => {
    const invalidPayload = {
      bookingType: 'flight',
      provider: 'Amadeus',
      itemId: 'fl_01',
      itemName: 'Flight',
      startDate: '2026-12-01',
      contactDetails: { name: 'User', email: 'test@travel.com', phone: '12345678' },
      basePriceUSD: 100.00,
      taxesUSD: 10.00,
      serviceFeeUSD: 5.00, // VIOLATION: Must be $1.00
      totalAmountUSD: 115.00
    };
    assert.throws(
      () => ApiSchemas.validateCreateBooking(invalidPayload),
      (err) => {
        assert(err instanceof ValidationError);
        assert(err.errors.some(e => e.field === 'serviceFeeUSD'));
        return true;
      }
    );
  });

  await t.test('rejects mathematical discrepancy in totalAmountUSD', () => {
    const mismatchedPayload = {
      bookingType: 'flight',
      provider: 'Amadeus',
      itemId: 'fl_01',
      itemName: 'Flight',
      startDate: '2026-12-01',
      contactDetails: { name: 'User', email: 'test@travel.com', phone: '12345678' },
      basePriceUSD: 200.00,
      taxesUSD: 20.00,
      serviceFeeUSD: 1.00,
      totalAmountUSD: 999.00 // Intentionally wrong
    };
    assert.throws(
      () => ApiSchemas.validateCreateBooking(mismatchedPayload),
      (err) => {
        assert(err instanceof ValidationError);
        assert(err.errors.some(e => e.field === 'totalAmountUSD'));
        return true;
      }
    );
  });
});

test('ApiSchemas - Commission Config Validation', async (t) => {
  await t.test('enforces zero affiliate service fee ($0.00)', () => {
    assert.throws(
      () => ApiSchemas.validateCommissionConfig({
        standardAffiliateFeeUSD: 2.50 // VIOLATION: Affiliate fee must be $0.00
      }),
      (err) => err instanceof ValidationError
    );
  });

  await t.test('accepts valid platform configuration update', () => {
    const valid = ApiSchemas.validateCommissionConfig({
      standardDirectFeeUSD: 1.00,
      standardAffiliateFeeUSD: 0.00,
      defaultPercentageRate: 0.0075,
      hotelPartnerCommissionRate: 0.12
    });
    assert.equal(valid.standardDirectFeeUSD, 1.00);
    assert.equal(valid.standardAffiliateFeeUSD, 0.00);
    assert.equal(valid.defaultPercentageRate, 0.0075);
  });
});
