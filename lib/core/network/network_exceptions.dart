/// Base exception for all network and travel API interactions
class NetworkException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const NetworkException(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() => 'NetworkException($statusCode, $errorCode): $message';
}

/// Thrown when the user's authentication token has expired or is invalid
class UnauthorizedException extends NetworkException {
  const UnauthorizedException([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

/// Thrown when an inventory price lock expired or the fare changed on GDS
class PriceChangedException extends NetworkException {
  final double oldPrice;
  final double newPrice;

  const PriceChangedException({
    required this.oldPrice,
    required this.newPrice,
    String message = 'The airfare/room price has updated with the provider.',
  }) : super(message, errorCode: 'PRICE_CHANGED', statusCode: 409);
}

/// Thrown when a seat or hotel room is no longer available
class InventorySoldOutException extends NetworkException {
  const InventorySoldOutException([super.message = 'Selected flight seat or room is no longer available.'])
      : super(errorCode: 'INVENTORY_SOLD_OUT', statusCode: 410);
}

/// Thrown when payment authorization fails or 3DS challenge is rejected
class PaymentFailedException extends NetworkException {
  final String? declineCode;

  const PaymentFailedException(super.message, {this.declineCode})
      : super(errorCode: declineCode ?? 'PAYMENT_DECLINED', statusCode: 402);
}
