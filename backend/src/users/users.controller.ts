import { Router, Request, Response, NextFunction } from 'express';
import { UsersService } from './users.service';
import { authenticateJwt } from '../auth/auth.middleware';

export const usersRouter = Router();

usersRouter.use(authenticateJwt);

usersRouter.get('/profile', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await UsersService.updateProfile(req.user!.userId, {});
    res.json({ success: true, data: profile });
  } catch (err) {
    next(err);
  }
});

usersRouter.put('/profile', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const updated = await UsersService.updateProfile(req.user!.userId, req.body);
    res.json({ success: true, data: updated });
  } catch (err) {
    next(err);
  }
});

usersRouter.get('/passengers', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const passengers = await UsersService.getPassengers(req.user!.userId);
    res.json({ success: true, data: passengers });
  } catch (err) {
    next(err);
  }
});

usersRouter.post('/passengers', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const passenger = await UsersService.addPassenger(req.user!.userId, req.body);
    res.status(201).json({ success: true, data: passenger });
  } catch (err) {
    next(err);
  }
});
