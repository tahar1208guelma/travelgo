import { Router, Request, Response, NextFunction } from 'express';
import { FlightsService } from './flights.service';

export const flightsRouter = Router();

flightsRouter.post('/search', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { originCode, destinationCode, departureDate, returnDate, adults, children, infants, cabinClass } = req.body;
    if (!originCode || !destinationCode || !departureDate) {
      return res.status(400).json({ error: 'originCode, destinationCode, and departureDate are required' });
    }

    const results = await FlightsService.search(
      {
        originCode,
        destinationCode,
        departureDate,
        returnDate,
        adults: parseInt(adults || '1', 10),
        children: parseInt(children || '0', 10),
        infants: parseInt(infants || '0', 10),
        cabinClass: cabinClass || 'Economy',
      },
      req.user?.userId
    );

    res.json({ success: true, data: results });
  } catch (err) {
    next(err);
  }
});

flightsRouter.post('/:id/verify-price', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await FlightsService.verifyPrice(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});
