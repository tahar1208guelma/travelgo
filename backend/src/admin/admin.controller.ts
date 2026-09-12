import { Router, Request, Response, NextFunction } from 'express';
import { AdminService } from './admin.service';
import { authenticateJwt, requireRole } from '../auth/auth.middleware';

export const adminRouter = Router();

// Protect all admin routes
adminRouter.use(authenticateJwt);
adminRouter.use(requireRole('admin'));

adminRouter.get('/dashboard', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = await AdminService.getDashboardMetrics();
    res.json({ success: true, data });
  } catch (err) {
    next(err);
  }
});

adminRouter.get('/bookings', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limit = parseInt(req.query.limit as string || '50', 10);
    const offset = parseInt(req.query.offset as string || '0', 10);
    const bookings = await AdminService.getAllBookings(limit, offset);
    res.json({ success: true, data: bookings });
  } catch (err) {
    next(err);
  }
});

adminRouter.get('/users', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limit = parseInt(req.query.limit as string || '50', 10);
    const offset = parseInt(req.query.offset as string || '0', 10);
    const users = await AdminService.getAllUsers(limit, offset);
    res.json({ success: true, data: users });
  } catch (err) {
    next(err);
  }
});

adminRouter.put('/settings/commission', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { commissionRatePercent } = req.body;
    if (commissionRatePercent === undefined) {
      return res.status(400).json({ error: 'commissionRatePercent is required (e.g. 0.75 for 0.75%)' });
    }
    const result = await AdminService.updateCommissionRate(parseFloat(commissionRatePercent), req.user?.userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

adminRouter.put('/providers/:id/toggle', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { isActive } = req.body;
    const result = await AdminService.toggleProvider(req.params.id, Boolean(isActive), req.user?.userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

adminRouter.post('/bookings/:id/refund', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { amount, reason } = req.body;
    const result = await AdminService.issueRefund(req.params.id, parseFloat(amount), reason || 'Customer request', req.user?.userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

adminRouter.get('/audit-logs', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const logs = await AdminService.getAuditLogs();
    res.json({ success: true, data: logs });
  } catch (err) {
    next(err);
  }
});
