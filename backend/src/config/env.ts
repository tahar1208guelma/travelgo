import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, '../../../.env') });

export const ENV = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '4000', 10),
  DATABASE_URL: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/travelgo',
  JWT_SECRET: process.env.JWT_SECRET || 'travelgo_super_secret_jwt_key_2026_production',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  
  // Platform Commission
  COMMISSION_RATE: parseFloat(process.env.COMMISSION_RATE || '0.0075'), // Default 0.75%
  
  // Flight Providers Credentials (Strictly on backend)
  AMADEUS_CLIENT_ID: process.env.AMADEUS_CLIENT_ID || '',
  AMADEUS_CLIENT_SECRET: process.env.AMADEUS_CLIENT_SECRET || '',
  DUFFEL_ACCESS_TOKEN: process.env.DUFFEL_ACCESS_TOKEN || '',

  // Hotel Providers Credentials
  BOOKING_COM_API_KEY: process.env.BOOKING_COM_API_KEY || '',
  EXPEDIA_API_KEY: process.env.EXPEDIA_API_KEY || '',

  // Payment Credentials
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY || '',
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET || '',
  CIB_MERCHANT_KEY: process.env.CIB_MERCHANT_KEY || '',

  // Security
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
  RATE_LIMIT_MAX: parseInt(process.env.RATE_LIMIT_MAX || '200', 10),
};
