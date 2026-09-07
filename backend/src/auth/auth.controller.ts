import { Router, Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { authenticateJwt } from './auth.middleware';

export const authRouter = Router();

authRouter.post('/register', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password, firstName, lastName, phone, country, dateOfBirth } = req.body;
    if (!email || !password || !firstName || !lastName) {
      return res.status(400).json({ error: 'Missing required fields: email, password, firstName, lastName' });
    }
    const result = await AuthService.register({ email, password, firstName, lastName, phone, country, dateOfBirth }, req.ip);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

authRouter.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    const result = await AuthService.login({ email, password }, req.ip);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

authRouter.get('/me', authenticateJwt, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await AuthService.getProfile(req.user!.userId);
    res.json({ success: true, data: profile });
  } catch (err) {
    next(err);
  }
});

authRouter.post('/logout', authenticateJwt, (req: Request, res: Response) => {
  res.json({ success: true, message: 'Logged out successfully' });
});
