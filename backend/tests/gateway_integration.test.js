/**
 * @file gateway_integration.test.js
 * @description End-to-end integration tests for the TravelGo Backend Gateway.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../src/app.js';

test('Backend Gateway - E2E Integration Suite', async (t) => {
  const server = createApp();

  await new Promise((resolve) => {
    server.listen(0, '127.0.0.1', resolve);
  });

  const port = server.address().port;
  const baseUrl = `http://127.0.0.1:${port}`;

  t.after(() => {
    server.close();
  });

  await t.test('GET /health returns 200 with zero client secrets flag', async () => {
    const res = await fetch(`${baseUrl}/health`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'UP');
    assert.equal(body.security.zeroClientSecrets, true);
    assert.equal(body.security.rlsEnforced, true);
  });

  await t.test('GET /api/v1/search/flights returns verified flight inventory with $1.00 platform fee', async () => {
    const res = await fetch(`${baseUrl}/api/v1/search/flights?origin=ALG&destination=DXB&departureDate=2026-12-01&adults=1&cabinClass=economy`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.success, true);
    assert(body.offers.length > 0);
    assert.equal(body.offers[0].serviceFeeUSD, 1.00); // Standard $1.00 platform fee
    assert.equal(body.gatewaySecurity.zeroClientSecretsVerified, true);
  });

  await t.test('POST /api/v1/bookings creates booking with deterministic pricing and $1.00 fee', async () => {
    const payload = {
      bookingType: 'flight',
      provider: 'Amadeus',
      itemId: 'fl_EK_1',
      itemName: 'Emirates Flight ALG -> DXB',
      startDate: '2026-12-01T08:30:00Z',
      contactDetails: {
        name: 'Sarah Connor',
        email: 'sarah@traveler.com',
        phone: '+213555123456'
      },
      basePriceUSD: 300.00,
      taxesUSD: 45.00,
      serviceFeeUSD: 1.00,
      totalAmountUSD: 346.00
    };

    const res = await fetch(`${baseUrl}/api/v1/bookings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    assert.equal(res.status, 201);
    const body = await res.json();
    assert.equal(body.success, true);
    assert(body.booking.bookingReference.startsWith('TG-'));
    assert.equal(body.booking.financialBreakdown.serviceFee, 1.00);
    assert.equal(body.booking.financialBreakdown.totalAmount, 346.00);
  });

  await t.test('POST /api/v1/bookings/:id/cancel cancels booking and calculates refund retaining $1.00 fee', async () => {
    // 1. Create booking
    const createRes = await fetch(`${baseUrl}/api/v1/bookings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        bookingType: 'hotel',
        provider: 'PartnerDirect',
        itemId: 'ht_1',
        itemName: 'Luxury Hotel',
        startDate: '2026-12-05',
        contactDetails: { name: 'John Doe', email: 'john@travel.com', phone: '+1234567890' },
        basePriceUSD: 200.00,
        taxesUSD: 20.00,
        serviceFeeUSD: 1.00,
        totalAmountUSD: 221.00
      })
    });
    const createBody = await createRes.json();
    const bookingId = createBody.booking.id;

    // 2. Cancel booking
    const cancelRes = await fetch(`${baseUrl}/api/v1/bookings/${bookingId}/cancel`, {
      method: 'POST'
    });
    assert.equal(cancelRes.status, 200);
    const cancelBody = await cancelRes.json();
    assert.equal(cancelBody.booking.status, 'cancelled');
    assert.equal(cancelBody.refundDetails.customerRefundAmount, 220.00); // 200 + 20
    assert.equal(cancelBody.refundDetails.retainedPlatformFee, 1.00);
  });

  await t.test('POST /api/v1/affiliate/click enforces $0.00 platform markup', async () => {
    const res = await fetch(`${baseUrl}/api/v1/affiliate/click`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        provider: 'Booking.com',
        productType: 'hotel',
        productId: 'ht_dubai_001',
        targetUrl: 'https://booking.com/hotel/123'
      })
    });

    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.serviceFeeUSD, 0.00);
  });

  await t.test('GET /api/v1/admin/commission-config returns platform fees', async () => {
    const res = await fetch(`${baseUrl}/api/v1/admin/commission-config`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.config.standardDirectFeeUSD, 1.00);
    assert.equal(body.config.standardAffiliateFeeUSD, 0.00);
    assert.equal(body.config.defaultPercentageRate, 0.0075);
  });
});
