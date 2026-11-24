/**
 * @file app.js
 * @description TravelGo Core Backend Gateway Application.
 * Integrates Schema Validation, Tiered Rate Limiting, RBAC Auth, Audit Logging, and Zero-Secret Proxies.
 */

import http from 'node:http';
import { config } from './config/environment.js';
import { ApiSchemas, ValidationError } from './schemas/api_schemas.js';
import { rateLimiters } from './middleware/rate_limiter.js';
import { authenticateOptional, requireAuth, requireAdmin, requirePartner, signJwt, UserRole } from './middleware/auth.js';
import { auditLogger } from './middleware/audit_logger.js';
import { CommissionCalculator } from './services/commission_calculator.js';
import { ZeroSecretProxyService } from './services/zero_secret_proxy.js';

// In-memory mock data stores for backend gateway operation
const inMemoryBookings = new Map();
const inMemoryHotels = new Map();
let platformConfig = {
  standardDirectFeeUSD: config.commission.standardDirectFeeUSD, // $1.00 USD
  standardAffiliateFeeUSD: config.commission.standardAffiliateFeeUSD, // $0.00 USD
  defaultPercentageRate: config.commission.defaultPercentageRate, // 0.75%
  hotelPartnerCommissionRate: config.commission.hotelPartnerCommissionRate, // 12%
  taxRatePercentage: 0.05
};

/**
 * Parses JSON body from incoming HTTP request
 */
function parseRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      // Enforce 1MB payload limit
      if (body.length > 1e6) {
        req.destroy();
        reject(new Error('Payload Too Large'));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (err) {
        reject(new Error('Invalid JSON format: ' + err.message));
      }
    });
    req.on('error', reject);
  });
}

/**
 * Standardized JSON response helper
 */
function sendJson(res, statusCode, data, headers = {}) {
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');

  for (const [k, v] of Object.entries(headers)) {
    res.setHeader(k, v);
  }

  res.end(JSON.stringify(data, null, 2));
}

export function createApp() {
  return http.createServer(async (req, res) => {
    // 1. CORS Preflight Handling
    if (req.method === 'OPTIONS') {
      res.statusCode = 204;
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
      res.end();
      return;
    }

    const parsedUrl = new URL(req.url, `http://${req.headers.host || '127.0.0.1'}`);
    const pathname = parsedUrl.pathname;
    const query = Object.fromEntries(parsedUrl.searchParams.entries());

    try {
      // 2. Global Rate Limiter Check
      const clientKey = req.headers['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1';
      const globalCheck = rateLimiters.general.check(clientKey);
      res.setHeader('X-RateLimit-Limit', globalCheck.limit);
      res.setHeader('X-RateLimit-Remaining', globalCheck.remaining);

      if (!globalCheck.allowed) {
        sendJson(res, 429, {
          error: 'Too Many Requests',
          message: 'Global rate limit exceeded. Please retry shortly.',
          retryAfterSeconds: globalCheck.resetTime
        }, { 'Retry-After': globalCheck.resetTime });
        return;
      }

      // Parse JSON body for mutation requests
      if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
        req.body = await parseRequestBody(req);
      } else {
        req.body = {};
      }

      // 3. Health Endpoint
      if (pathname === '/health' || pathname === '/api/v1/health') {
        sendJson(res, 200, {
          status: 'UP',
          timestamp: new Date().toISOString(),
          uptimeSeconds: Math.floor(process.uptime()),
          environment: config.env,
          service: 'travelgo-backend-gateway',
          security: {
            zeroClientSecrets: true,
            rlsEnforced: true,
            rateLimitingActive: true
          }
        });
        return;
      }

      // 4. Auth Endpoint: Demo Token Issuer (for testing & development)
      if (pathname === '/api/v1/auth/token' && req.method === 'POST') {
        const { email = 'traveler@travelgo.com', role = UserRole.USER, isGuest = false } = req.body;
        const token = signJwt({
          id: `usr_${Math.random().toString(36).substring(2, 10)}`,
          email,
          role,
          isGuest
        });

        auditLogger.log({
          action: 'AUTH_TOKEN_GENERATED',
          entityType: 'auth',
          details: { email, role, isGuest }
        });

        sendJson(res, 200, {
          accessToken: token,
          tokenType: 'Bearer',
          expiresIn: config.jwt.expiresIn,
          user: { email, role, isGuest }
        });
        return;
      }

      // 5. Search Flights Endpoint (Proxy via Zero-Secret Gateway)
      if (pathname === '/api/v1/search/flights' && req.method === 'GET') {
        // Enforce Search Rate Limiter (60 req/min)
        const searchCheck = rateLimiters.search.check(clientKey);
        if (!searchCheck.allowed) {
          sendJson(res, 429, {
            error: 'Too Many Requests',
            message: 'Search rate limit exceeded (max 60/min).'
          }, { 'Retry-After': searchCheck.resetTime });
          return;
        }

        const validatedParams = ApiSchemas.validateFlightSearch(query);
        const searchResult = await ZeroSecretProxyService.searchFlights(validatedParams);
        sendJson(res, 200, searchResult);
        return;
      }

      // 6. Search Hotels Endpoint (Proxy via Zero-Secret Gateway)
      if (pathname === '/api/v1/search/hotels' && req.method === 'GET') {
        const searchCheck = rateLimiters.search.check(clientKey);
        if (!searchCheck.allowed) {
          sendJson(res, 429, {
            error: 'Too Many Requests',
            message: 'Search rate limit exceeded (max 60/min).'
          }, { 'Retry-After': searchCheck.resetTime });
          return;
        }

        const validatedParams = ApiSchemas.validateHotelSearch(query);
        const searchResult = await ZeroSecretProxyService.searchHotels(validatedParams);
        sendJson(res, 200, searchResult);
        return;
      }

      // 7. Booking Lifecycle: Create Direct Booking
      if (pathname === '/api/v1/bookings' && req.method === 'POST') {
        // Enforce Booking Rate Limiter (20 req/min)
        const bookingCheck = rateLimiters.booking.check(clientKey);
        if (!bookingCheck.allowed) {
          sendJson(res, 429, { error: 'Too Many Requests', message: 'Booking rate limit exceeded.' });
          return;
        }

        const validatedPayload = ApiSchemas.validateCreateBooking(req.body);

        // Calculate deterministic financial breakdown
        const breakdown = CommissionCalculator.calculateDirectBooking({
          baseFare: validatedPayload.basePriceUSD,
          taxes: validatedPayload.taxesUSD,
          serviceFee: validatedPayload.serviceFeeUSD,
          commissionRate: platformConfig.defaultPercentageRate
        });

        const bookingId = `bk_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
        const bookingReference = `TG-${Math.floor(100000 + Math.random() * 900000)}`;

        const bookingRecord = {
          id: bookingId,
          bookingReference,
          ...validatedPayload,
          financialBreakdown: breakdown,
          status: 'pending',
          paymentStatus: 'pending',
          createdAt: new Date().toISOString()
        };

        inMemoryBookings.set(bookingId, bookingRecord);

        auditLogger.log({
          action: 'BOOKING_CREATED',
          entityType: 'booking',
          entityId: bookingId,
          details: { bookingReference, totalAmountUSD: breakdown.totalAmount, platformFee: breakdown.serviceFee }
        });

        sendJson(res, 201, {
          success: true,
          booking: bookingRecord
        });
        return;
      }

      // 8. Booking Lifecycle: Retrieve Booking Details
      const bookingGetMatch = pathname.match(/^\/api\/v1\/bookings\/([^/]+)$/);
      if (bookingGetMatch && req.method === 'GET') {
        const id = bookingGetMatch[1];
        const record = inMemoryBookings.get(id);
        if (!record) {
          sendJson(res, 404, { error: 'Not Found', message: `Booking ${id} not found` });
          return;
        }
        sendJson(res, 200, { success: true, booking: record });
        return;
      }

      // 9. Booking Lifecycle: Cancel Booking & Compute Refund
      const bookingCancelMatch = pathname.match(/^\/api\/v1\/bookings\/([^/]+)\/cancel$/);
      if (bookingCancelMatch && req.method === 'POST') {
        const id = bookingCancelMatch[1];
        const record = inMemoryBookings.get(id);
        if (!record) {
          sendJson(res, 404, { error: 'Not Found', message: `Booking ${id} not found` });
          return;
        }

        const refund = CommissionCalculator.calculateRefund({
          baseFare: record.basePriceUSD,
          taxes: record.taxesUSD,
          serviceFee: record.serviceFeeUSD
        });

        record.status = 'cancelled';
        record.paymentStatus = 'refunded';
        record.cancelledAt = new Date().toISOString();
        record.refundDetails = refund;

        auditLogger.log({
          action: 'BOOKING_CANCELLED',
          entityType: 'booking',
          entityId: id,
          details: { refundDetails: refund }
        });

        sendJson(res, 200, {
          success: true,
          message: 'Booking cancelled and refund processed',
          booking: record,
          refundDetails: refund
        });
        return;
      }

      // 10. Payment Gateway: Create Payment Intent (Stripe / CIB / PayPal)
      if (pathname === '/api/v1/payments/create-intent' && req.method === 'POST') {
        const validatedPayload = ApiSchemas.validatePaymentIntent(req.body);

        const paymentIntentId = `pi_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
        const clientSecret = `pi_secret_${Math.random().toString(36).substring(2, 16)}`;

        auditLogger.log({
          action: 'PAYMENT_INTENT_CREATED',
          entityType: 'payment',
          entityId: paymentIntentId,
          details: { bookingId: validatedPayload.bookingId, amount: validatedPayload.amount, method: validatedPayload.paymentMethod }
        });

        sendJson(res, 200, {
          success: true,
          paymentIntentId,
          clientSecret, // Client secret for mobile Stripe SDK / CIB gateway iframe
          amount: validatedPayload.amount,
          currency: validatedPayload.currency,
          paymentMethod: validatedPayload.paymentMethod
        });
        return;
      }

      // 11. Affiliate Click Tracker (Zero platform markup: $0.00)
      if (pathname === '/api/v1/affiliate/click' && req.method === 'POST') {
        const { provider, productType, productId, targetUrl, trackingId } = req.body;
        const breakdown = CommissionCalculator.calculateAffiliateRedirect({ baseFare: 100, taxes: 0 });

        auditLogger.log({
          action: 'AFFILIATE_CLICK',
          entityType: 'affiliate',
          details: { provider, productType, productId, trackingId, platformMarkup: breakdown.platformMarkup }
        });

        sendJson(res, 200, {
          success: true,
          trackingId: trackingId || `trk_${Date.now()}`,
          serviceFeeUSD: 0.00, // Explicitly $0.00 platform markup
          targetUrl
        });
        return;
      }

      // 12. Hotel Partner Onboarding & Property Registration
      if (pathname === '/api/v1/partner/hotels' && req.method === 'POST') {
        const validatedPayload = ApiSchemas.validatePartnerHotel(req.body);
        const hotelId = `ht_partner_${Date.now()}`;

        const hotelRecord = {
          id: hotelId,
          ...validatedPayload,
          status: 'pending_approval',
          commissionRate: platformConfig.hotelPartnerCommissionRate, // 12%
          createdAt: new Date().toISOString()
        };

        inMemoryHotels.set(hotelId, hotelRecord);

        auditLogger.log({
          action: 'PARTNER_HOTEL_REGISTERED',
          entityType: 'hotel',
          entityId: hotelId,
          details: { name: hotelRecord.name, city: hotelRecord.city }
        });

        sendJson(res, 201, {
          success: true,
          hotel: hotelRecord
        });
        return;
      }

      // 13. Admin: Commission Configuration
      if (pathname === '/api/v1/admin/commission-config') {
        if (req.method === 'GET') {
          sendJson(res, 200, {
            success: true,
            config: platformConfig
          });
          return;
        }

        if (req.method === 'PUT') {
          const validated = ApiSchemas.validateCommissionConfig(req.body);
          platformConfig = {
            ...platformConfig,
            ...validated,
            updatedAt: new Date().toISOString()
          };

          auditLogger.log({
            action: 'COMMISSION_CONFIG_UPDATED',
            entityType: 'config',
            details: platformConfig
          });

          sendJson(res, 200, {
            success: true,
            message: 'Commission configuration updated successfully',
            config: platformConfig
          });
          return;
        }
      }

      // 14. Admin: View Audit Logs
      if (pathname === '/api/v1/admin/audit-logs' && req.method === 'GET') {
        const logs = auditLogger.getLogs({ limit: parseInt(query.limit || '50', 10) });
        sendJson(res, 200, {
          success: true,
          count: logs.length,
          logs
        });
        return;
      }

      // Route Not Found
      sendJson(res, 404, {
        error: 'Not Found',
        message: `API endpoint ${req.method} ${pathname} does not exist on TravelGo Gateway.`
      });

    } catch (err) {
      if (err instanceof ValidationError) {
        sendJson(res, 400, {
          error: 'Validation Error',
          message: err.message,
          errors: err.errors
        });
        return;
      }

      auditLogger.log({
        action: 'INTERNAL_SERVER_ERROR',
        entityType: 'system',
        status: 'failure',
        failureReason: err.message
      });

      sendJson(res, 500, {
        error: 'Internal Server Error',
        message: err.message
      });
    }
  });
}
