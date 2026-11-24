/**
 * @file environment.js
 * @description Centralized environment configuration and security validator for TravelGo Backend Gateway.
 */

import fs from 'node:fs';
import path from 'node:path';

// Lightweight .env reader to ensure zero external dependency requirement
function loadEnv() {
  const envPath = path.resolve(process.cwd(), '.env');
  if (fs.existsSync(envPath)) {
    const content = fs.readFileSync(envPath, 'utf8');
    const lines = content.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const eqIdx = trimmed.indexOf('=');
      if (eqIdx !== -1) {
        const key = trimmed.substring(0, eqIdx).trim();
        const val = trimmed.substring(eqIdx + 1).trim().replace(/^['"]|['"]$/g, '');
        if (!process.env[key]) {
          process.env[key] = val;
        }
      }
    }
  }
}

loadEnv();

export const config = {
  env: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',
  port: parseInt(process.env.PORT || '4000', 10),
  host: process.env.HOST || '0.0.0.0',
  corsOrigins: (process.env.CORS_ORIGIN || '*').split(',').map(s => s.trim()),

  // Database & Supabase
  databaseUrl: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/travelgo',
  supabase: {
    url: process.env.SUPABASE_URL || 'https://mock-supabase.travelgo.internal',
    anonKey: process.env.SUPABASE_ANON_KEY || 'public-anon-key-mock',
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || 'backend-service-role-key-mock'
  },

  // Security & Authentication
  jwt: {
    secret: process.env.JWT_SECRET || 'travelgo_default_dev_secret_replace_in_production_2026',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  },

  // Financial Commissions
  commission: {
    standardDirectFeeUSD: parseFloat(process.env.STANDARD_DIRECT_FEE_USD || '1.00'),
    standardAffiliateFeeUSD: parseFloat(process.env.STANDARD_AFFILIATE_FEE_USD || '0.00'),
    defaultPercentageRate: parseFloat(process.env.COMMISSION_RATE || '0.0075'), // 0.75%
    hotelPartnerCommissionRate: parseFloat(process.env.HOTEL_PARTNER_COMMISSION_RATE || '0.12') // 12%
  },

  // Rate Limiting Config
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10), // 1 minute
    maxGeneral: parseInt(process.env.RATE_LIMIT_MAX || '200', 10),
    maxSearch: 60,
    maxBooking: 20,
    maxAuth: 10
  },

  // Third-party Provider Credentials (STRICTLY SERVER-SIDE ONLY)
  providers: {
    amadeus: {
      clientId: process.env.AMADEUS_CLIENT_ID || '',
      clientSecret: process.env.AMADEUS_CLIENT_SECRET || '',
      environment: process.env.AMADEUS_ENVIRONMENT || 'test'
    },
    duffel: {
      accessToken: process.env.DUFFEL_ACCESS_TOKEN || ''
    },
    hotel: {
      bookingComApiKey: process.env.BOOKING_COM_API_KEY || '',
      expediaApiKey: process.env.EXPEDIA_API_KEY || '',
      expediaSecret: process.env.EXPEDIA_API_SECRET || ''
    },
    stripe: {
      secretKey: process.env.STRIPE_SECRET_KEY || '',
      webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || ''
    },
    cib: {
      merchantKey: process.env.CIB_MERCHANT_KEY || '',
      terminalId: process.env.CIB_TERMINAL_ID || ''
    }
  }
};

/**
 * Validates that production environments do not use default or insecure secrets
 */
export function validateProductionConfig() {
  const issues = [];
  if (config.isProduction) {
    if (config.jwt.secret.includes('default_dev_secret')) {
      issues.push('JWT_SECRET is using an insecure development default in production');
    }
    if (!process.env.DATABASE_URL) {
      issues.push('DATABASE_URL must be specified in production');
    }
  }
  return {
    isValid: issues.length === 0,
    issues
  };
}
