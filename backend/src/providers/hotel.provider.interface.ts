export interface HotelRoomDto {
  roomId: string;
  name: string;
  roomType: string;
  capacity: number;
  basePricePerNight: number;
  taxesPerNight: number;
  currency: string;
  breakfastIncluded: boolean;
  cancellationPolicy: string;
  availableUnits: number;
}

export interface HotelPropertyDto {
  hotelId: string;
  providerCode: string;
  isDemo: boolean;
  name: string;
  destination: string;
  city: string;
  country: string;
  address: string;
  starRating: number;
  guestRating: number;
  images: string[];
  amenities: string[];
  rooms: HotelRoomDto[];
}

export interface HotelSearchCriteria {
  destination: string;
  checkIn: string;
  checkOut: string;
  adults: number;
  children: number;
  roomsCount: number;
}

export interface HotelBookingRequest {
  hotelId: string;
  roomId: string;
  checkIn: string;
  checkOut: string;
  guests: Array<{
    firstName: string;
    lastName: string;
    email: string;
    phone?: string;
  }>;
}

export interface HotelBookingResult {
  providerConfirmationReference: string;
  voucherNumber: string;
  status: 'confirmed' | 'pending' | 'failed';
  remarks?: string;
}

export interface IHotelProvider {
  readonly providerId: string;
  readonly providerName: string;
  readonly isDemo: boolean;

  searchHotels(criteria: HotelSearchCriteria): Promise<HotelPropertyDto[]>;
  getHotelDetails(hotelId: string): Promise<HotelPropertyDto | null>;
  createBooking(request: HotelBookingRequest): Promise<HotelBookingResult>;
  cancelBooking(confirmationReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }>;
}
