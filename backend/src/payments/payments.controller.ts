import { Router, Request, Response, NextFunction } from 'express';
import { PaymentsService } from './payments.service';

export const paymentsRouter = Router();

paymentsRouter.post('/create-intent', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { bookingId, paymentMethod, customerEmail, idempotencyKey } = req.body;
    if (!bookingId || !idempotencyKey) {
      return res.status(400).json({ error: 'bookingId and idempotencyKey are required' });
    }

    const intent = await PaymentsService.createIntent(
      bookingId,
      paymentMethod || 'card',
      customerEmail || 'customer@travelgo.com',
      idempotencyKey
    );

    res.json({ success: true, data: intent });
  } catch (err) {
    next(err);
  }
});

paymentsRouter.post('/confirm', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { paymentIntentId, bookingId } = req.body;
    if (!paymentIntentId || !bookingId) {
      return res.status(400).json({ error: 'paymentIntentId and bookingId are required' });
    }

    const result = await PaymentsService.verifyAndFinalizePayment(paymentIntentId, bookingId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

paymentsRouter.post('/webhook', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sig = req.headers['stripe-signature'] as string || '';
    const provider = req.query.provider as string || 'stripe';
    const result = await PaymentsService.handleWebhook(provider, JSON.stringify(req.body), sig);
    res.json(result);
  } catch (err) {
    next(err);
  }
});
