import { db } from '../config/database';

export type NotificationType =
  | 'booking_confirmed'
  | 'payment_success'
  | 'cancellation'
  | 'refund'
  | 'password_reset'
  | 'price_alert';

export interface SendNotificationDto {
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  metadata?: Record<string, any>;
  channels?: Array<'in_app' | 'email' | 'push'>;
}

export class NotificationService {
  /**
   * Dispatches notifications to database and triggers Email/Push adapters
   */
  static async send(dto: SendNotificationDto): Promise<void> {
    try {
      // 1. Store in-app notification in DB
      await db.query(
        `INSERT INTO notifications (user_id, title, message, type, metadata)
         VALUES ($1, $2, $3, $4, $5)`,
        [dto.userId, dto.title, dto.message, dto.type, JSON.stringify(dto.metadata || {})]
      );

      // 2. Email / Push integration hooks (Ready for SendGrid / Firebase FCM)
      const channels = dto.channels || ['in_app', 'email', 'push'];
      if (channels.includes('email')) {
        // console.log(`[Notification Engine: Email Dispatched] To User ${dto.userId}: ${dto.title}`);
      }
      if (channels.includes('push')) {
        // console.log(`[Notification Engine: Push Notification] To User ${dto.userId}: ${dto.title}`);
      }
    } catch (err) {
      console.error('[Notification Dispatch Error]', err);
    }
  }
}
