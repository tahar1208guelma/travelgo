/**
 * ============================================================================
 * NOTICE: DEMO DATA ONLY / DEVELOPMENT MOCK HOTEL PROVIDER
 * This provider is used exclusively for testing when live Hotel API credentials
 * (Booking.com or Expedia) are not configured in environment variables.
 * ============================================================================
 */

import { IHotelProvider, HotelSearchCriteria, HotelPropertyDto, HotelBookingRequest, HotelBookingResult } from './hotel.provider.interface';

export class MockHotelProvider implements IHotelProvider {
  public readonly providerId = 'mock_hotel';
  public readonly providerName = 'TravelGo Mock Hotel Engine (DEMO ONLY)';
  public readonly isDemo = true;

  async searchHotels(criteria: HotelSearchCriteria): Promise<HotelPropertyDto[]> {
    const dest = criteria.destination;

    return [
      {
        hotelId: 'DEMO-HTL-01',
        providerCode: this.providerId,
        isDemo: true,
        name: `${dest} Grand Palace & Spa Luxury Suites`,
        destination: dest,
        city: dest,
        country: 'Algeria',
        address: `12 Boulevard Mohamed V, ${dest} Center`,
        starRating: 5.0,
        guestRating: 9.3,
        images: [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
        ],
        amenities: ['Free High-Speed WiFi', 'Infinity Swimming Pool', 'Spa & Wellness Center', 'Valet Parking', 'Airport Shuttle'],
        rooms: [
          {
            roomId: 'RM-DELUXE-01',
            name: 'Deluxe Executive King Suite',
            roomType: 'Deluxe King',
            capacity: 2,
            basePricePerNight: 120.0,
            taxesPerNight: 18.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Free cancellation up to 48 hours before check-in',
            availableUnits: 4,
          },
          {
            roomId: 'RM-SUITE-02',
            name: 'Presidential Panoramic Sea/City View Suite',
            roomType: 'Presidential Suite',
            capacity: 3,
            basePricePerNight: 240.0,
            taxesPerNight: 30.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Non-refundable (Special Promotion)',
            availableUnits: 2,
          },
        ],
      },
      {
        hotelId: 'DEMO-HTL-02',
        providerCode: this.providerId,
        isDemo: true,
        name: `${dest} Marriott Executive Apartments & Hotel`,
        destination: dest,
        city: dest,
        country: 'Algeria',
        address: `Route de l'Aéroport, ${dest}`,
        starRating: 4.5,
        guestRating: 8.8,
        images: [
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        ],
        amenities: ['Free WiFi', 'Fitness Center', 'International Restaurant', 'Business Conference Rooms'],
        rooms: [
          {
            roomId: 'RM-STD-01',
            name: 'Standard Queen Room with Balcony',
            roomType: 'Standard Queen',
            capacity: 2,
            basePricePerNight: 85.0,
            taxesPerNight: 12.0,
            currency: 'USD',
            breakfastIncluded: false,
            cancellationPolicy: 'Free cancellation up to 24 hours prior',
            availableUnits: 7,
          },
        ],
      },
    ];
  }

  async getHotelDetails(hotelId: string): Promise<HotelPropertyDto | null> {
    const list = await this.searchHotels({ destination: 'Algiers', checkIn: '', checkOut: '', adults: 1, children: 0, roomsCount: 1 });
    return list.find((h) => h.hotelId === hotelId) || list[0];
  }

  async createBooking(request: HotelBookingRequest): Promise<HotelBookingResult> {
    const conf = 'HTL-' + Math.random().toString(36).substring(2, 8).toUpperCase();
    return {
      providerConfirmationReference: conf,
      voucherNumber: `VCH-HTL-${Date.now()}`,
      status: 'confirmed',
      remarks: 'DEMO HOTEL VOUCHER ONLY - Issued by TravelGo Sandbox Mock Engine',
    };
  }

  async cancelBooking(confirmationReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }> {
    return { isCancelled: true, refundEligible: true, cancellationFee: 0 };
  }
}
