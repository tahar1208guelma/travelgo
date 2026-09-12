export interface DocumentMetadata {
  bookingReference: string;
  providerReference?: string;
  isConfirmedWithProvider: boolean;
  bookingType: 'flight' | 'hotel' | 'combined';
  status: string;
  customerName: string;
  totalPrice: number;
  currency: string;
  createdAt: string;
}

export class BackendPdfService {
  /**
   * Resolves official document title based on real provider confirmation status
   * Rule: Never name a document "Electronic Flight Ticket" unless confirmed by provider.
   */
  static getDocumentTypeAndTitle(meta: DocumentMetadata): { documentType: string; documentTitle: string } {
    if (meta.bookingType === 'hotel') {
      return {
        documentType: 'hotel_voucher',
        documentTitle: 'OFFICIAL HOTEL RESERVATION VOUCHER',
      };
    }

    if (meta.bookingType === 'flight') {
      if (meta.isConfirmedWithProvider && meta.status === 'confirmed') {
        return {
          documentType: 'flight_eticket',
          documentTitle: 'OFFICIAL ELECTRONIC FLIGHT TICKET (CONFIRMED)',
        };
      }
      return {
        documentType: 'flight_itinerary',
        documentTitle: 'FLIGHT ITINERARY & PROVISIONAL RESERVATION VOUCHER',
      };
    }

    return {
      documentType: 'booking_confirmation',
      documentTitle: 'TRAVELGO PACKAGE CONFIRMATION VOUCHER',
    };
  }

  /**
   * Generates document verification payload for QR Codes
   */
  static generateVerificationPayload(meta: DocumentMetadata): string {
    return JSON.stringify({
      issuer: 'TRAVELGO_GLOBAL_NETWORK',
      bookingRef: meta.bookingReference,
      pnr: meta.providerReference || 'PENDING',
      isTicketConfirmed: meta.isConfirmedWithProvider,
      status: meta.status,
      totalAmount: `${meta.currency} ${meta.totalPrice}`,
      verifiedAt: new Date().toISOString(),
    });
  }
}
