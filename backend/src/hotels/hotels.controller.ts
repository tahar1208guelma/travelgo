import { Router, Request, Response, NextFunction } from 'express';
import { HotelsService } from './hotels.service';

export const hotelsRouter = Router();

hotelsRouter.post('/search', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { destination, checkIn, checkOut, adults, children, roomsCount } = req.body;
    if (!destination || !checkIn || !checkOut) {
      return res.status(400).json({ error: 'destination, checkIn, and checkOut are required' });
    }

    const results = await HotelsService.search(
      {
        destination,
        checkIn,
        checkOut,
        adults: parseInt(adults || '1', 10),
        children: parseInt(children || '0', 10),
        roomsCount: parseInt(roomsCount || '1', 10),
      },
      req.user?.userId
    );

    res.json({ success: true, data: results });
  } catch (err) {
    next(err);
  }
});

hotelsRouter.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const hotel = await HotelsService.getDetails(req.params.id);
    if (!hotel) {
      return res.status(404).json({ error: 'Hotel not found' });
    }
    res.json({ success: true, data: hotel });
  } catch (err) {
    next(err);
  }
});
