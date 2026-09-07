enum PaymentMethodType {
  creditCard('Credit / Debit Card (PCI-DSS Tokenized)'),
  applePay('Apple Pay (Direct Token)'),
  googlePay('Google Pay (Direct Token)'),
  wireTransfer('Bank Wire Transfer');

  final String displayName;
  const PaymentMethodType(this.displayName);
}

/// Tokenized Payment Nonce produced by PCI-DSS compliant Hosted Fields / SDK
/// NEVER contains raw full card numbers or security CVV in memory.
class TokenizedPaymentMethod {
  final String paymentToken; // e.g. "tok_1N837482934"
  final String cardBrand; // "Visa", "Mastercard", "Amex"
  final String last4; // "4242"
  final String expiryMonth; // "12"
  final String expiryYear; // "28"
  final String cardholderName;
  final bool requires3DS;

  const TokenizedPaymentMethod({
    required this.paymentToken,
    required this.cardBrand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    this.requires3DS = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentToken': paymentToken,
      'cardBrand': cardBrand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardholderName': cardholderName,
      'requires3DS': requires3DS,
    };
  }
}
