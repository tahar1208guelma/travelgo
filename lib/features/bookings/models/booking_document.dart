class BookingDocument {
  final String documentId;
  final String documentTitle;
  final String bookingReference;
  final DateTime issuedAt;
  final String qrData;
  final String? verificationUrl;
  final bool isDemo;
  final String termsAndConditions;
  final String supportEmail;
  final String supportPhone;
  final String supportWebsite;

  const BookingDocument({
    required this.documentId,
    this.documentTitle = 'Travel Booking Confirmation',
    required this.bookingReference,
    required this.issuedAt,
    required this.qrData,
    this.verificationUrl,
    this.isDemo = true,
    this.termsAndConditions =
        'This booking confirmation is subject to TRAVELGO standard booking terms and carrier/hotel conditions of carriage and stay. Please present this document along with valid government-issued photo ID upon check-in.',
    this.supportEmail = 'support@travelgo.com',
    this.supportPhone = '+1 (800) 555-TRVL',
    this.supportWebsite = 'https://travelgo.example',
  });

  BookingDocument copyWith({
    String? documentId,
    String? documentTitle,
    String? bookingReference,
    DateTime? issuedAt,
    String? qrData,
    String? verificationUrl,
    bool? isDemo,
    String? termsAndConditions,
    String? supportEmail,
    String? supportPhone,
    String? supportWebsite,
  }) {
    return BookingDocument(
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      bookingReference: bookingReference ?? this.bookingReference,
      issuedAt: issuedAt ?? this.issuedAt,
      qrData: qrData ?? this.qrData,
      verificationUrl: verificationUrl ?? this.verificationUrl,
      isDemo: isDemo ?? this.isDemo,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      supportWebsite: supportWebsite ?? this.supportWebsite,
    );
  }

  factory BookingDocument.fromJson(Map<String, dynamic> json) {
    return BookingDocument(
      documentId: json['documentId'] as String? ?? 'DOC-001',
      documentTitle: json['documentTitle'] as String? ?? 'Travel Booking Confirmation',
      bookingReference: json['bookingReference'] as String? ?? 'TRV-REF',
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'] as String)
          : DateTime.now(),
      qrData: json['qrData'] as String? ?? json['bookingReference'] as String? ?? 'TRV-REF',
      verificationUrl: json['verificationUrl'] as String?,
      isDemo: json['isDemo'] as bool? ?? true,
      termsAndConditions: json['termsAndConditions'] as String? ??
          'This booking confirmation is subject to TRAVELGO standard booking terms and carrier/hotel conditions of carriage and stay.',
      supportEmail: json['supportEmail'] as String? ?? 'support@travelgo.com',
      supportPhone: json['supportPhone'] as String? ?? '+1 (800) 555-TRVL',
      supportWebsite: json['supportWebsite'] as String? ?? 'https://travelgo.example',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'documentTitle': documentTitle,
      'bookingReference': bookingReference,
      'issuedAt': issuedAt.toIso8601String(),
      'qrData': qrData,
      'verificationUrl': verificationUrl,
      'isDemo': isDemo,
      'termsAndConditions': termsAndConditions,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'supportWebsite': supportWebsite,
    };
  }
}
