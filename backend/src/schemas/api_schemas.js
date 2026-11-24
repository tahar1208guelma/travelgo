/**
 * @file api_schemas.js
 * @description Strict API request and payload validation schemas for TravelGo Gateway.
 * Validates data types, ranges, IATA codes, ISO dates, and financial invariants.
 */

// ISO Date Regex (YYYY-MM-DD)
const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;
// 3-letter IATA Airport Code
const IATA_REGEX = /^[A-Z]{3}$/;
// Basic Email Regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
// UUID v4 Regex
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export class ValidationError extends Error {
  constructor(errors) {
    super('API Request Schema Validation Failed');
    this.name = 'ValidationError';
    this.statusCode = 400;
    this.errors = errors;
  }
}

export const ApiSchemas = {
  /**
   * Validates Flight Search query parameters
   */
  validateFlightSearch(params) {
    const errors = [];
    const origin = (params.origin || '').trim().toUpperCase();
    const destination = (params.destination || '').trim().toUpperCase();
    const departureDate = (params.departureDate || '').trim();
    const returnDate = params.returnDate ? params.returnDate.trim() : null;
    const adults = parseInt(params.adults || '1', 10);
    const cabinClass = (params.cabinClass || 'economy').toLowerCase();

    if (!IATA_REGEX.test(origin)) {
      errors.push({ field: 'origin', message: 'Origin must be a 3-letter IATA airport code (e.g. ALG, DXB, JFK)' });
    }
    if (!IATA_REGEX.test(destination)) {
      errors.push({ field: 'destination', message: 'Destination must be a 3-letter IATA airport code (e.g. CDG, LHR)' });
    }
    if (origin && destination && origin === destination) {
      errors.push({ field: 'destination', message: 'Origin and destination airport codes cannot be identical' });
    }

    if (!DATE_REGEX.test(departureDate)) {
      errors.push({ field: 'departureDate', message: 'departureDate must be formatted as YYYY-MM-DD' });
    } else {
      const depTime = new Date(departureDate).getTime();
      const todayTime = new Date(new Date().toISOString().split('T')[0]).getTime();
      if (depTime < todayTime) {
        errors.push({ field: 'departureDate', message: 'departureDate cannot be in the past' });
      }
    }

    if (returnDate) {
      if (!DATE_REGEX.test(returnDate)) {
        errors.push({ field: 'returnDate', message: 'returnDate must be formatted as YYYY-MM-DD' });
      } else if (new Date(returnDate).getTime() < new Date(departureDate).getTime()) {
        errors.push({ field: 'returnDate', message: 'returnDate cannot precede departureDate' });
      }
    }

    if (isNaN(adults) || adults < 1 || adults > 9) {
      errors.push({ field: 'adults', message: 'adults must be an integer between 1 and 9' });
    }

    const validCabins = ['economy', 'premium_economy', 'business', 'first'];
    if (!validCabins.includes(cabinClass)) {
      errors.push({ field: 'cabinClass', message: `cabinClass must be one of: ${validCabins.join(', ')}` });
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return {
      origin,
      destination,
      departureDate,
      returnDate,
      adults,
      cabinClass
    };
  },

  /**
   * Validates Hotel Search query parameters
   */
  validateHotelSearch(params) {
    const errors = [];
    const destination = (params.destination || '').trim();
    const checkInDate = (params.checkInDate || '').trim();
    const checkOutDate = (params.checkOutDate || '').trim();
    const guests = parseInt(params.guests || '1', 10);
    const rooms = parseInt(params.rooms || '1', 10);

    if (!destination || destination.length < 2) {
      errors.push({ field: 'destination', message: 'destination city or location must be at least 2 characters' });
    }

    if (!DATE_REGEX.test(checkInDate)) {
      errors.push({ field: 'checkInDate', message: 'checkInDate must be formatted as YYYY-MM-DD' });
    }
    if (!DATE_REGEX.test(checkOutDate)) {
      errors.push({ field: 'checkOutDate', message: 'checkOutDate must be formatted as YYYY-MM-DD' });
    }
    if (DATE_REGEX.test(checkInDate) && DATE_REGEX.test(checkOutDate)) {
      if (new Date(checkOutDate).getTime() <= new Date(checkInDate).getTime()) {
        errors.push({ field: 'checkOutDate', message: 'checkOutDate must be after checkInDate' });
      }
    }

    if (isNaN(guests) || guests < 1 || guests > 20) {
      errors.push({ field: 'guests', message: 'guests must be an integer between 1 and 20' });
    }
    if (isNaN(rooms) || rooms < 1 || rooms > 10) {
      errors.push({ field: 'rooms', message: 'rooms must be an integer between 1 and 10' });
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return {
      destination,
      checkInDate,
      checkOutDate,
      guests,
      rooms
    };
  },

  /**
   * Validates Direct Booking Creation Payload
   */
  validateCreateBooking(body) {
    const errors = [];
    if (!body || typeof body !== 'object') {
      throw new ValidationError([{ field: 'body', message: 'Request body must be a JSON object' }]);
    }

    const {
      bookingType,
      provider,
      itemId,
      itemName,
      startDate,
      endDate,
      guestCount = 1,
      contactDetails,
      passengers = [],
      basePriceUSD,
      taxesUSD = 0,
      serviceFeeUSD = 1.00,
      totalAmountUSD
    } = body;

    if (!['flight', 'hotel'].includes(bookingType)) {
      errors.push({ field: 'bookingType', message: "bookingType must be either 'flight' or 'hotel'" });
    }
    if (!provider || typeof provider !== 'string') {
      errors.push({ field: 'provider', message: 'provider name is required' });
    }
    if (!itemId || typeof itemId !== 'string') {
      errors.push({ field: 'itemId', message: 'itemId reference is required' });
    }
    if (!itemName || typeof itemName !== 'string') {
      errors.push({ field: 'itemName', message: 'itemName is required' });
    }
    if (!startDate) {
      errors.push({ field: 'startDate', message: 'startDate is required' });
    }

    if (!contactDetails || typeof contactDetails !== 'object') {
      errors.push({ field: 'contactDetails', message: 'contactDetails object is required' });
    } else {
      if (!contactDetails.name || contactDetails.name.trim().length < 2) {
        errors.push({ field: 'contactDetails.name', message: 'Contact name must be at least 2 characters' });
      }
      if (!contactDetails.email || !EMAIL_REGEX.test(contactDetails.email)) {
        errors.push({ field: 'contactDetails.email', message: 'A valid contact email is required' });
      }
      if (!contactDetails.phone || contactDetails.phone.trim().length < 6) {
        errors.push({ field: 'contactDetails.phone', message: 'Valid contact phone number is required' });
      }
    }

    // Financial arithmetic checks
    if (typeof basePriceUSD !== 'number' || basePriceUSD < 0) {
      errors.push({ field: 'basePriceUSD', message: 'basePriceUSD must be a non-negative number' });
    }
    if (typeof taxesUSD !== 'number' || taxesUSD < 0) {
      errors.push({ field: 'taxesUSD', message: 'taxesUSD must be a non-negative number' });
    }
    // Strict platform rule: standard direct platform service fee is default $1.00 USD
    if (typeof serviceFeeUSD !== 'number' || Math.abs(serviceFeeUSD - 1.00) > 0.001) {
      errors.push({ field: 'serviceFeeUSD', message: 'serviceFeeUSD must be strictly $1.00 USD standard platform fee' });
    }

    if (typeof totalAmountUSD !== 'number') {
      errors.push({ field: 'totalAmountUSD', message: 'totalAmountUSD is required' });
    } else {
      const expectedTotal = Math.round(((basePriceUSD || 0) + (taxesUSD || 0) + (serviceFeeUSD || 0)) * 100) / 100;
      if (Math.abs(totalAmountUSD - expectedTotal) > 0.01) {
        errors.push({
          field: 'totalAmountUSD',
          message: `totalAmountUSD (${totalAmountUSD}) does not match basePrice + taxes + serviceFee (${expectedTotal})`
        });
      }
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return body;
  },

  /**
   * Validates Payment Intent Payload
   */
  validatePaymentIntent(body) {
    const errors = [];
    if (!body || typeof body !== 'object') {
      throw new ValidationError([{ field: 'body', message: 'Request body must be a JSON object' }]);
    }

    const { bookingId, amount, currency = 'USD', paymentMethod } = body;

    if (!bookingId || typeof bookingId !== 'string') {
      errors.push({ field: 'bookingId', message: 'Valid bookingId is required' });
    }
    if (typeof amount !== 'number' || amount <= 0) {
      errors.push({ field: 'amount', message: 'amount must be a positive number' });
    }
    if (!['USD', 'EUR', 'DZD', 'GBP', 'AED'].includes(currency.toUpperCase())) {
      errors.push({ field: 'currency', message: 'Unsupported currency code' });
    }
    if (!['stripe', 'paypal', 'cib'].includes(paymentMethod)) {
      errors.push({ field: 'paymentMethod', message: "paymentMethod must be one of: 'stripe', 'paypal', 'cib'" });
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return body;
  },

  /**
   * Validates Hotel Partner Onboarding & Property Registration
   */
  validatePartnerHotel(body) {
    const errors = [];
    if (!body || typeof body !== 'object') {
      throw new ValidationError([{ field: 'body', message: 'Request body must be a JSON object' }]);
    }

    const { name, address, city, country, contactEmail, contactPhone, rooms } = body;

    if (!name || name.trim().length < 3) {
      errors.push({ field: 'name', message: 'Property name must be at least 3 characters' });
    }
    if (!address || address.trim().length < 5) {
      errors.push({ field: 'address', message: 'Valid physical address is required' });
    }
    if (!city || city.trim().length < 2) {
      errors.push({ field: 'city', message: 'City is required' });
    }
    if (!country || country.trim().length < 2) {
      errors.push({ field: 'country', message: 'Country is required' });
    }
    if (!contactEmail || !EMAIL_REGEX.test(contactEmail)) {
      errors.push({ field: 'contactEmail', message: 'Valid business contact email is required' });
    }

    if (!Array.isArray(rooms) || rooms.length === 0) {
      errors.push({ field: 'rooms', message: 'At least one room category must be provided' });
    } else {
      rooms.forEach((r, idx) => {
        if (!r.name || r.name.trim().length < 2) {
          errors.push({ field: `rooms[${idx}].name`, message: 'Room name is required' });
        }
        if (typeof r.basePricePerNight !== 'number' || r.basePricePerNight < 0) {
          errors.push({ field: `rooms[${idx}].basePricePerNight`, message: 'Room nightly price must be non-negative' });
        }
      });
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return body;
  },

  /**
   * Validates Admin Commission Configuration Update
   */
  validateCommissionConfig(body) {
    const errors = [];
    if (!body || typeof body !== 'object') {
      throw new ValidationError([{ field: 'body', message: 'Request body must be a JSON object' }]);
    }

    const {
      standardDirectFeeUSD,
      standardAffiliateFeeUSD,
      defaultPercentageRate,
      hotelPartnerCommissionRate
    } = body;

    if (standardDirectFeeUSD !== undefined && (typeof standardDirectFeeUSD !== 'number' || standardDirectFeeUSD < 0)) {
      errors.push({ field: 'standardDirectFeeUSD', message: 'standardDirectFeeUSD must be non-negative' });
    }
    if (standardAffiliateFeeUSD !== undefined && standardAffiliateFeeUSD !== 0.00) {
      errors.push({ field: 'standardAffiliateFeeUSD', message: 'standardAffiliateFeeUSD must remain $0.00' });
    }
    if (defaultPercentageRate !== undefined && (typeof defaultPercentageRate !== 'number' || defaultPercentageRate < 0 || defaultPercentageRate > 0.5)) {
      errors.push({ field: 'defaultPercentageRate', message: 'defaultPercentageRate must be between 0.00 and 0.50 (e.g. 0.0075 for 0.75%)' });
    }
    if (hotelPartnerCommissionRate !== undefined && (typeof hotelPartnerCommissionRate !== 'number' || hotelPartnerCommissionRate < 0 || hotelPartnerCommissionRate > 0.5)) {
      errors.push({ field: 'hotelPartnerCommissionRate', message: 'hotelPartnerCommissionRate must be between 0.00 and 0.50' });
    }

    if (errors.length > 0) {
      throw new ValidationError(errors);
    }

    return body;
  }
};
