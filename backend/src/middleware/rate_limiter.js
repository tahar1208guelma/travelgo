/**
 * @file rate_limiter.js
 * @description In-memory Sliding Window / Token-Bucket Rate Limiter middleware.
 * Prevents API quota exhaustion, DoS attacks, and brute-force attempts.
 */

export class RateLimiter {
  constructor({ windowMs = 60000, max = 200, name = 'global' } = {}) {
    this.windowMs = windowMs;
    this.max = max;
    this.name = name;
    this.hits = new Map(); // key -> Array of timestamps

    // Periodically prune stale entries every 2 minutes
    this.cleanupTimer = setInterval(() => {
      const now = Date.now();
      for (const [key, timestamps] of this.hits.entries()) {
        const validTimestamps = timestamps.filter(ts => now - ts < this.windowMs);
        if (validTimestamps.length === 0) {
          this.hits.delete(key);
        } else {
          this.hits.set(key, validTimestamps);
        }
      }
    }, Math.max(this.windowMs * 2, 10000));

    if (this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  /**
   * Evaluates request rate for a client key (IP or User ID).
   * @param {string} key
   * @returns {{ allowed: boolean, current: number, limit: number, remaining: number, resetTime: number }}
   */
  check(key) {
    const now = Date.now();
    const timestamps = this.hits.get(key) || [];
    const validTimestamps = timestamps.filter(ts => now - ts < this.windowMs);

    if (validTimestamps.length >= this.max) {
      const oldest = validTimestamps[0];
      const resetTime = Math.ceil((oldest + this.windowMs - now) / 1000);
      return {
        allowed: false,
        current: validTimestamps.length,
        limit: this.max,
        remaining: 0,
        resetTime
      };
    }

    validTimestamps.push(now);
    this.hits.set(key, validTimestamps);

    return {
      allowed: true,
      current: validTimestamps.length,
      limit: this.max,
      remaining: this.max - validTimestamps.length,
      resetTime: Math.ceil(this.windowMs / 1000)
    };
  }

  /**
   * Express-style middleware
   */
  middleware() {
    return (req, res, next) => {
      // Determine client key: User ID if authenticated, else IP address
      const clientKey = req.user?.id || req.headers['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1';
      const result = this.check(clientKey);

      res.setHeader('X-RateLimit-Limit', result.limit);
      res.setHeader('X-RateLimit-Remaining', result.remaining);
      res.setHeader('X-RateLimit-Reset', result.resetTime);

      if (!result.allowed) {
        res.statusCode = 429;
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Retry-After', result.resetTime);
        res.end(JSON.stringify({
          error: 'Too Many Requests',
          message: `Rate limit of ${this.max} requests per minute exceeded on ${this.name} endpoint. Please retry after ${result.resetTime} seconds.`,
          retryAfterSeconds: result.resetTime
        }));
        return;
      }

      next();
    };
  }

  reset() {
    this.hits.clear();
  }
}

// Pre-configured rate limiter instances
export const rateLimiters = {
  general: new RateLimiter({ windowMs: 60000, max: 200, name: 'general' }),
  search: new RateLimiter({ windowMs: 60000, max: 60, name: 'search' }),
  booking: new RateLimiter({ windowMs: 60000, max: 20, name: 'booking' }),
  auth: new RateLimiter({ windowMs: 60000, max: 10, name: 'auth' })
};
