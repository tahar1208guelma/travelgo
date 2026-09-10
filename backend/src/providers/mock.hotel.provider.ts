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

    // Simulate resolving country from destination
    let country = 'Algeria';
    if (['Paris', 'London', 'Rome', 'Madrid', 'Barcelona'].includes(dest)) country = 'Europe';
    else if (['Istanbul', 'Antalya'].includes(dest)) country = 'Turkey';
    else if (['Dubai'].includes(dest)) country = 'UAE';
    else if (['Cairo'].includes(dest)) country = 'Egypt';
    else if (['Tunis'].includes(dest)) country = 'Tunisia';

    const globalHotels: HotelPropertyDto[] = [
      {
        hotelId: `DEMO-HTL-01-${dest.toUpperCase()}`,
        providerCode: this.providerId,
        isDemo: true,
        name: `${dest} Grand Palace & Spa Luxury Suites`,
        destination: dest,
        city: dest,
        country: country,
        address: `12 Boulevard Central, ${dest} City Center`,
        starRating: 5.0,
        guestRating: 9.3,
        images: [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
        ],
        amenities: ['Free High-Speed Wi-Fi', 'Continental Breakfast', 'Swimming Pool', 'Spa & Wellness Center', 'Valet Parking', 'Airport Shuttle'],
        rooms: [
          {
            roomId: 'RM-STD-01',
            name: 'Standard Room',
            roomType: 'Standard Queen',
            capacity: 2,
            basePricePerNight: 120.0,
            taxesPerNight: 18.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Free cancellation up to 48 hours before check-in',
            availableUnits: 4,
          },
          {
            roomId: 'RM-DELUXE-01',
            name: 'Deluxe Ocean/City View',
            roomType: 'Deluxe King',
            capacity: 2,
            basePricePerNight: 180.0,
            taxesPerNight: 24.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Free cancellation up to 48 hours before check-in',
            availableUnits: 3,
          },
          {
            roomId: 'RM-SUITE-02',
            name: 'Executive Suite',
            roomType: 'Executive King Suite',
            capacity: 4,
            basePricePerNight: 350.0,
            taxesPerNight: 45.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Non-refundable (Special Promotion)',
            availableUnits: 2,
          },
        ],
      },
      {
        hotelId: `DEMO-HTL-02-${dest.toUpperCase()}`,
        providerCode: this.providerId,
        isDemo: true,
        name: `${dest} Marriott Executive Apartments & Hotel`,
        destination: dest,
        city: dest,
        country: country,
        address: `Airport Road, ${dest}`,
        starRating: 4.5,
        guestRating: 8.8,
        images: [
          'https://images.unsplash.com/photo-1551882547-ff40eb0d1556?w=800',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          'https://images.unsplash.com/photo-1517840901100-8179e982acb7?w=800',
        ],
        amenities: ['Free High-Speed Wi-Fi', 'Fitness Center', 'International Restaurant', 'Business Conference Rooms'],
        rooms: [
          {
            roomId: 'RM-STD-02',
            name: 'Standard Room with Balcony',
            roomType: 'Standard Queen',
            capacity: 2,
            basePricePerNight: 85.0,
            taxesPerNight: 12.0,
            currency: 'USD',
            breakfastIncluded: false,
            cancellationPolicy: 'Free cancellation up to 24 hours prior',
            availableUnits: 7,
          },
          {
            roomId: 'RM-DELUXE-02',
            name: 'Deluxe Ocean/City View',
            roomType: 'Deluxe King',
            capacity: 2,
            basePricePerNight: 130.0,
            taxesPerNight: 15.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Free cancellation up to 24 hours prior',
            availableUnits: 4,
          }
        ],
      },
      {
        hotelId: `DEMO-HTL-03-${dest.toUpperCase()}`,
        providerCode: this.providerId,
        isDemo: true,
        name: `The Ritz-Carlton ${dest}`,
        destination: dest,
        city: dest,
        country: country,
        address: `1 Luxury Avenue, ${dest}`,
        starRating: 5.0,
        guestRating: 9.8,
        images: [
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800',
        ],
        amenities: ['Free High-Speed Wi-Fi', 'Continental Breakfast', 'Swimming Pool', 'Spa', 'Airport Shuttle', 'Butler Service'],
        rooms: [
          {
            roomId: 'RM-DELUXE-03',
            name: 'Deluxe Ocean/City View',
            roomType: 'Deluxe King',
            capacity: 2,
            basePricePerNight: 450.0,
            taxesPerNight: 55.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Free cancellation up to 72 hours before check-in',
            availableUnits: 5,
          },
          {
            roomId: 'RM-SUITE-03',
            name: 'Executive Suite',
            roomType: 'Presidential Suite',
            capacity: 4,
            basePricePerNight: 1200.0,
            taxesPerNight: 150.0,
            currency: 'USD',
            breakfastIncluded: true,
            cancellationPolicy: 'Non-refundable',
            availableUnits: 1,
          },
        ],
      }
    ];

    // If searching for a specific hotel name (mock logic)
    if (dest.toLowerCase().includes('marriott')) {
      return [globalHotels[1]];
    }
    if (dest.toLowerCase().includes('ritz')) {
      return [globalHotels[2]];
    }

    return globalHotels;
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
