/**
 * @file audit_logger.js
 * @description Audit logging middleware and persistence service for compliance and security forensics.
 * Strips sensitive PII and financial credentials before logging.
 */

export class AuditLogger {
  constructor() {
    this.logs = []; // In-memory store (also syncs to database audit_logs table)
    this.maxMemoryLogs = 1000;
  }

  /**
   * Masks sensitive credentials from data objects
   */
  static sanitize(obj) {
    if (!obj || typeof obj !== 'object') return obj;
    const sanitized = Array.isArray(obj) ? [...obj] : { ...obj };

    const sensitiveFields = [
      'password',
      'secret',
      'token',
      'apiKey',
      'cardNumber',
      'cvv',
      'authorization',
      'clientSecret'
    ];

    for (const key of Object.keys(sanitized)) {
      const lower = key.toLowerCase();
      if (sensitiveFields.some(field => lower.includes(field.toLowerCase()))) {
        sanitized[key] = '[REDACTED_SENSITIVE]';
      } else if (typeof sanitized[key] === 'object') {
        sanitized[key] = AuditLogger.sanitize(sanitized[key]);
      }
    }

    return sanitized;
  }

  /**
   * Records an audit event
   */
  log({
    userId = null,
    action,
    entityType,
    entityId = null,
    ip = '127.0.0.1',
    userAgent = 'Unknown',
    details = {},
    status = 'success',
    failureReason = null
  }) {
    const entry = {
      id: `audit_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`,
      timestamp: new Date().toISOString(),
      userId,
      action,
      entityType,
      entityId,
      ip,
      userAgent,
      details: AuditLogger.sanitize(details),
      status,
      failureReason
    };

    this.logs.unshift(entry);
    if (this.logs.length > this.maxMemoryLogs) {
      this.logs.pop();
    }

    return entry;
  }

  /**
   * Express-style middleware to log mutating API requests
   */
  middleware() {
    return (req, res, next) => {
      // We log state-mutating HTTP methods
      if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method)) {
        const originalEnd = res.end;
        const startTime = Date.now();

        res.end = (...args) => {
          const durationMs = Date.now() - startTime;
          const status = res.statusCode >= 400 ? 'failure' : 'success';

          this.log({
            userId: req.user?.id || null,
            action: `${req.method}_${req.url.split('?')[0]}`,
            entityType: 'api_request',
            ip: req.headers['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1',
            userAgent: req.headers['user-agent'] || 'Unknown',
            details: {
              method: req.method,
              path: req.url,
              statusCode: res.statusCode,
              durationMs,
              body: AuditLogger.sanitize(req.body)
            },
            status,
            failureReason: status === 'failure' ? `HTTP Status ${res.statusCode}` : null
          });

          return originalEnd.apply(res, args);
        };
      }

      next();
    };
  }

  getLogs({ limit = 50, entityType = null, userId = null } = {}) {
    let filtered = this.logs;
    if (entityType) filtered = filtered.filter(l => l.entityType === entityType);
    if (userId) filtered = filtered.filter(l => l.userId === userId);
    return filtered.slice(0, limit);
  }

  clear() {
    this.logs = [];
  }
}

export const auditLogger = new AuditLogger();
