import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { ENV } from './config/env';
import { ApiError } from './errors/api.error';
import { authRouter } from './auth/auth.controller';
import { flightsRouter } from './flights/flights.controller';
import { hotelsRouter } from './hotels/hotels.controller';
import { bookingsRouter } from './bookings/bookings.controller';
import { paymentsRouter } from './payments/payments.controller';
import { usersRouter } from './users/users.controller';
import { adminRouter } from './admin/admin.controller';
import { financeRouter } from './finance/finance.controller';
import { CurrencyService } from './services/currency.service';
import { CommissionService } from './services/commission.service';

const app = express();

// 1. Security & Standard Middleware
app.use(helmet());
app.use(cors({ origin: ENV.CORS_ORIGIN, credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: ENV.RATE_LIMIT_MAX,
  message: { success: false, error: 'Too many requests from this IP. Please try again later.' },
});
app.use(limiter);

// 2. Health & Status Endpoints
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    service: 'TravelGo Global Booking API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

app.get('/currencies', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const currencies = await CurrencyService.getCurrencies();
    res.json({ success: true, data: currencies });
  } catch (err) {
    next(err);
  }
});

app.get('/commission/current', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rate = await CommissionService.getCommissionRate();
    res.json({ success: true, data: { commissionRateDecimal: rate, commissionRatePercent: rate * 100 } });
  } catch (err) {
    next(err);
  }
});

// 3. Mount Modular Feature Routes
app.use('/auth', authRouter);
app.use('/flights', flightsRouter);
app.use('/hotels', hotelsRouter);
app.use('/bookings', bookingsRouter);
app.use('/payments', paymentsRouter);
app.use('/users', usersRouter);
app.use('/admin', adminRouter);
app.use('/admin/finance', financeRouter);

// 4. 404 Route Handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Cannot ${req.method} ${req.path}`,
    },
  });
});

// 5. Global Error Handling Middleware
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  const statusCode = err instanceof ApiError ? err.statusCode : 500;
  const errorCode = err instanceof ApiError ? err.code : 'INTERNAL_SERVER_ERROR';
  const message = err.message || 'An unexpected error occurred';

  if (statusCode === 500) {
    console.error('[Unhandled Server Exception]', err);
  }

  res.status(statusCode).json({
    success: false,
    error: {
      code: errorCode,
      message,
      details: err.details || undefined,
    },
  });
});

// 6. Server Initialization
const server = app.listen(ENV.PORT, () => {
  console.log(`=======================================================`);
  console.log(`🚀 TravelGo Production Backend Server Active`);
  console.log(`📡 URL: http://localhost:${ENV.PORT}`);
  console.log(`🌍 Environment: ${ENV.NODE_ENV}`);
  console.log(`💼 Platform Commission: ${(ENV.COMMISSION_RATE * 100).toFixed(2)}%`);
  console.log(`=======================================================`);
});

// Graceful Shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Closing TravelGo backend gracefully...');
  server.close(() => process.exit(0));
});

export default app;
