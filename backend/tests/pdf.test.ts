import { BackendPdfService } from '../src/services/pdf.service';

describe('PDF Document Generation Rules', () => {
  it('does NOT name document Electronic Ticket when provider confirmation is pending', () => {
    const doc = BackendPdfService.getDocumentTypeAndTitle({
      bookingReference: 'TRV-2026-112233',
      isConfirmedWithProvider: false,
      bookingType: 'flight',
      status: 'pending',
      customerName: 'Karim Benali',
      totalPrice: 180.75,
      currency: 'USD',
      createdAt: new Date().toISOString(),
    });

    expect(doc.documentType).toBe('flight_itinerary');
    expect(doc.documentTitle).toContain('ITINERARY');
    expect(doc.documentTitle).not.toContain('ELECTRONIC FLIGHT TICKET (CONFIRMED)');
  });

  it('names document Electronic Ticket ONLY when confirmed with provider', () => {
    const doc = BackendPdfService.getDocumentTypeAndTitle({
      bookingReference: 'TRV-2026-112233',
      providerReference: 'AH7892K',
      isConfirmedWithProvider: true,
      bookingType: 'flight',
      status: 'confirmed',
      customerName: 'Karim Benali',
      totalPrice: 180.75,
      currency: 'USD',
      createdAt: new Date().toISOString(),
    });

    expect(doc.documentType).toBe('flight_eticket');
    expect(doc.documentTitle).toBe('OFFICIAL ELECTRONIC FLIGHT TICKET (CONFIRMED)');
  });
});
