import { Router, Request, Response, NextFunction } from 'express';
import { BookingsService } from './bookings.service';
import { authenticateJwt } from '../auth/auth.middleware';

export const bookingsRouter = Router();

bookingsRouter.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const booking = await BookingsService.createBooking(req.body, req.user?.userId, req.ip);
    res.status(201).json({ success: true, data: booking });
  } catch (err) {
    next(err);
  }
});

bookingsRouter.get('/', authenticateJwt, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const bookings = await BookingsService.getUserBookings(req.user!.userId);
    res.json({ success: true, data: bookings });
  } catch (err) {
    next(err);
  }
});

bookingsRouter.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const booking = await BookingsService.getBookingById(req.params.id, req.user?.userId);
    res.json({ success: true, data: booking });
  } catch (err) {
    next(err);
  }
});

bookingsRouter.post('/:id/cancel', authenticateJwt, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await BookingsService.cancelBooking(req.params.id, req.user!.userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});
