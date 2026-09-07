export type ApiErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'SEARCH_FAILED'
  | 'NO_RESULTS'
  | 'PROVIDER_ERROR'
  | 'PRICE_CHANGED'
  | 'AVAILABILITY_CHANGED'
  | 'PAYMENT_FAILED'
  | 'BOOKING_FAILED'
  | 'BOOKING_CANCELLED'
  | 'INTERNAL_SERVER_ERROR';

export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly code: ApiErrorCode;
  public readonly details?: any;

  constructor(statusCode: number, code: ApiErrorCode, message: string, details?: any) {
    super(message);
    this.name = 'ApiError';
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Object.setPrototypeOf(this, new.target.prototype);
  }

  static badRequest(message: string, code: ApiErrorCode = 'VALIDATION_ERROR', details?: any) {
    return new ApiError(400, code, message, details);
  }

  static unauthorized(message: string = 'Authentication token missing or expired') {
    return new ApiError(401, 'UNAUTHORIZED', message);
  }

  static forbidden(message: string = 'You do not have permission to access this resource') {
    return new ApiError(403, 'FORBIDDEN', message);
  }

  static notFound(message: string = 'Resource not found') {
    return new ApiError(404, 'NOT_FOUND', message);
  }

  static priceChanged(oldPrice: number, newPrice: number, currency: string) {
    return new ApiError(
      409,
      'PRICE_CHANGED',
      `Flight fare has changed from ${currency} ${oldPrice} to ${currency} ${newPrice}. Please review and approve the updated fare.`,
      { oldPrice, newPrice, currency }
    );
  }

  static providerError(providerName: string, originalError?: string) {
    return new ApiError(502, 'PROVIDER_ERROR', `Error communicating with ${providerName} travel provider`, {
      provider: providerName,
      reason: originalError,
    });
  }

  static internal(message: string = 'Internal server error occurred') {
    return new ApiError(500, 'INTERNAL_SERVER_ERROR', message);
  }
}
