import { db } from '../config/database';
import { IPaymentProvider } from '../providers/payment.provider.interface';
import { StripePaymentProvider } from '../providers/stripe.payment.provider';
import { CibEdahabiaPaymentProvider } from '../providers/cib.payment.provider';
import { BookingsService } from '../bookings/bookings.service';
import { ApiError } from '../errors/api.error';
import { AuditService } from '../services/audit.service';

export class PaymentsService {
  private static stripe = new StripePaymentProvider();
  private static cib = new CibEdahabiaPaymentProvider();

  static getProvider(method: string): IPaymentProvider {
    if (method === 'edahabia' || method === 'cib') {
      return this.cib;
    }
    return this.stripe;
  }

  static async createIntent(bookingId: string, paymentMethod: string = 'card', customerEmail: string, idempotencyKey: string) {
    const bRes = await db.query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    if (bRes.rows.length === 0) throw ApiError.notFound('Booking not found');
    const booking = bRes.rows[0];

    if (booking.status === 'confirmed' || booking.status === 'paid') {
      throw ApiError.badRequest('Booking has already been paid and confirmed');
    }

    const provider = this.getProvider(paymentMethod);
    const intent = await provider.createPaymentIntent({
      bookingId,
      amount: parseFloat(booking.total_price),
      currency: booking.currency,
      idempotencyKey,
      description: `TravelGo Reservation ${booking.booking_reference}`,
      customerEmail,
    });

    // Record initiated payment in DB (NEVER storing raw card numbers)
    await db.query(
      `INSERT INTO payments (booking_id, provider_id, payment_intent_id, idempotency_key, amount, currency, status, payment_method_type)
       VALUES ($1, $2, $3, $4, $5, $6, 'initiated', $7)
       ON CONFLICT (payment_intent_id) DO NOTHING`,
      [bookingId, provider.providerId, intent.paymentIntentId, idempotencyKey, booking.total_price, booking.currency, paymentMethod]
    );

    return intent;
  }

  /**
   * SERVER-SIDE PAYMENT VERIFICATION
   * The app is NEVER marked as confirmed simply because the client claims payment succeeded.
   * Backend strictly calls the gateway to verify the charge.
   */
  static async verifyAndFinalizePayment(paymentIntentId: string, bookingId: string) {
    const pRes = await db.query('SELECT * FROM payments WHERE payment_intent_id = $1', [paymentIntentId]);
    if (pRes.rows.length === 0) throw ApiError.notFound('Payment transaction record not found');
    const payment = pRes.rows[0];

    const provider = this.getProvider(payment.payment_method_type);
    const verification = await provider.verifyPayment(paymentIntentId);

    if (!verification.isVerified) {
      await db.query(`UPDATE payments SET status = 'failed' WHERE id = $1`, [payment.id]);
      await db.query(`UPDATE bookings SET status = 'failed' WHERE id = $1`, [bookingId]);
      throw ApiError.badRequest('Payment verification failed with provider gateway', 'PAYMENT_FAILED');
    }

    // Update payment record with verified attributes
    await db.query(
      `UPDATE payments 
       SET status = 'succeeded', server_verified_at = CURRENT_TIMESTAMP, payment_method_last4 = $1, payment_method_brand = $2
       WHERE id = $3`,
      [verification.last4 || null, verification.brand || null, payment.id]
    );

    // Transition booking state to confirmed
    const confirmation = await BookingsService.confirmBookingAfterPayment(bookingId, paymentIntentId, verification.last4);
    await AuditService.log('PAYMENT_VERIFIED_SERVER_SIDE', 'payments', payment.id, undefined, { paymentIntentId, bookingId });

    return {
      isSuccess: true,
      paymentIntentId,
      booking: confirmation,
    };
  }

  static async handleWebhook(providerId: string, rawPayload: string, signature: string) {
    const provider = providerId === 'cib_edahabia' ? this.cib : this.stripe;
    const event = await provider.verifyWebhookSignature(rawPayload, signature);

    if (event.type === 'payment_intent.succeeded') {
      const intentId = event.data?.object?.id;
      if (intentId) {
        const pRes = await db.query('SELECT booking_id FROM payments WHERE payment_intent_id = $1', [intentId]);
        if (pRes.rows.length > 0) {
          await this.verifyAndFinalizePayment(intentId, pRes.rows[0].booking_id);
        }
      }
    }

    return { received: true };
  }
}
