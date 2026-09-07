import { db } from '../config/database';

export class AuditService {
  static async log(
    action: string,
    entityType: string,
    entityId?: string,
    userId?: string,
    details?: Record<string, any>,
    ipAddress?: string
  ): Promise<void> {
    try {
      await db.query(
        `INSERT INTO audit_logs (action, entity_type, entity_id, user_id, details, ip_address)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [action, entityType, entityId || null, userId || null, JSON.stringify(details || {}), ipAddress || null]
      );
    } catch (err) {
      console.error('[Audit Log Failure]', err);
    }
  }
}
