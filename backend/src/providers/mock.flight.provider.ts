/**
 * ============================================================================
 * NOTICE: DEMO DATA ONLY / DEVELOPMENT MOCK PROVIDER
 * This provider is used exclusively for testing when live GDS API credentials
 * (Amadeus or Duffel) are not configured in environment variables.
 * ============================================================================
 */

import { IFlightProvider, FlightSearchCriteria, FlightOfferRawDto, FlightBookingRequest, FlightBookingResult, FlightSegmentDto } from './flight.provider.interface';

export class MockFlightProvider implements IFlightProvider {
  public readonly providerId = 'mock_flight';
  public readonly providerName = 'TravelGo Mock Flight Engine (DEMO ONLY)';
  public readonly isDemo = true;

  async searchFlights(criteria: FlightSearchCriteria): Promise<FlightOfferRawDto[]> {
    const origin = criteria.originCode.toUpperCase();
    const dest = criteria.destinationCode.toUpperCase();
    const depDate = new Date(criteria.departureDate);
    const offers: FlightOfferRawDto[] = [];

    // Multipliers for cabin class
    let cabinMultiplier = 1.0;
    if (criteria.cabinClass === 'Premium Economy') cabinMultiplier = 1.4;
    if (criteria.cabinClass === 'Business') cabinMultiplier = 2.2;
    if (criteria.cabinClass === 'First') cabinMultiplier = 3.8;

    // 1. DIRECT OFFERS
    const directAirlines = [
      { code: 'AH', name: 'Air Algerie', base: 145.0, taxes: 42.0, num: 'AH1004', plane: 'Boeing 737-800' },
      { code: 'TK', name: 'Turkish Airlines', base: 195.0, taxes: 45.0, num: 'TK652', plane: 'Airbus A350-900' },
      { code: 'AF', name: 'Air France', base: 155.0, taxes: 42.0, num: 'AF1854', plane: 'Airbus A320neo' },
      { code: 'PC', name: 'Pegasus Airlines', base: 125.0, taxes: 35.0, num: 'PC242', plane: 'Airbus A321neo' },
    ];

    directAirlines.forEach((airline, index) => {
      const depTime = new Date(depDate);
      depTime.setHours(8 + index * 3, 30, 0, 0);
      const arrTime = new Date(depTime.getTime() + 2.5 * 3600 * 1000);

      const basePrice = airline.base * cabinMultiplier * criteria.adults;
      const taxes = airline.taxes * criteria.adults;

      offers.push({
        providerOfferId: `DEMO-DIR-${airline.code}-${100 + index}`,
        providerCode: this.providerId,
        isDemo: true,
        validatingAirline: airline.name,
        validatingAirlineCode: airline.code,
        basePrice,
        taxes,
        currency: 'USD',
        seatsRemaining: 9 - index,
        isRefundable: criteria.cabinClass !== 'Economy',
        baggageSummary: '1 x 23 kg checked, 1 x 8 kg cabin',
        priceLockExpiry: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
        outboundSegments: [
          {
            airline: airline.name,
            airlineCode: airline.code,
            flightNumber: airline.num,
            departureAirport: `${origin} Airport`,
            departureAirportCode: origin,
            departureCity: origin,
            departureTerminal: 'T1',
            departureDateTime: depTime.toISOString(),
            arrivalAirport: `${dest} Airport`,
            arrivalAirportCode: dest,
            arrivalCity: dest,
            arrivalTerminal: 'T2',
            arrivalDateTime: arrTime.toISOString(),
            durationMinutes: 150,
            cabinClass: criteria.cabinClass,
            aircraftType: airline.plane,
            baggageAllowance: '23 kg',
          },
        ],
      });
    });

    // 2. 1-STOP CONNECTING OFFERS (e.g. via IST, DOH, CDG)
    const transitHubs = [
      { hub: 'IST', hubCity: 'Istanbul', airline: 'Turkish Airlines', code: 'TK', base: 165.0, f1: 'TK650', f2: 'TK780' },
      { hub: 'DOH', hubCity: 'Doha', airline: 'Qatar Airways', code: 'QR', base: 285.0, f1: 'QR1370', f2: 'QR812' },
      { hub: 'CDG', hubCity: 'Paris', airline: 'Air France', code: 'AF', base: 160.0, f1: 'AF1850', f2: 'AF220' },
    ];

    transitHubs.forEach((hubItem, idx) => {
      if (hubItem.hub === origin || hubItem.hub === dest) return;
      const depTime = new Date(depDate);
      depTime.setHours(7 + idx * 4, 15, 0, 0);
      const arr1 = new Date(depTime.getTime() + 3 * 3600 * 1000);
      const dep2 = new Date(arr1.getTime() + 2 * 3600 * 1000); // 2h layover
      const arr2 = new Date(dep2.getTime() + 4 * 3600 * 1000);

      offers.push({
        providerOfferId: `DEMO-1STOP-${hubItem.code}-${200 + idx}`,
        providerCode: this.providerId,
        isDemo: true,
        validatingAirline: hubItem.airline,
        validatingAirlineCode: hubItem.code,
        basePrice: hubItem.base * cabinMultiplier * criteria.adults,
        taxes: 52.0 * criteria.adults,
        currency: 'USD',
        seatsRemaining: 5,
        isRefundable: false,
        baggageSummary: '2 x 23 kg checked (Auto-transferred)',
        priceLockExpiry: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
        outboundSegments: [
          {
            airline: hubItem.airline,
            airlineCode: hubItem.code,
            flightNumber: hubItem.f1,
            departureAirport: `${origin} Airport`,
            departureAirportCode: origin,
            departureCity: origin,
            departureTerminal: 'T1',
            departureDateTime: depTime.toISOString(),
            arrivalAirport: `${hubItem.hubCity} Airport`,
            arrivalAirportCode: hubItem.hub,
            arrivalCity: hubItem.hubCity,
            arrivalTerminal: 'T2',
            arrivalDateTime: arr1.toISOString(),
            durationMinutes: 180,
            cabinClass: criteria.cabinClass,
            aircraftType: 'Airbus A321neo',
          },
          {
            airline: hubItem.airline,
            airlineCode: hubItem.code,
            flightNumber: hubItem.f2,
            departureAirport: `${hubItem.hubCity} Airport`,
            departureAirportCode: hubItem.hub,
            departureCity: hubItem.hubCity,
            departureTerminal: 'T2',
            departureDateTime: dep2.toISOString(),
            arrivalAirport: `${dest} Airport`,
            arrivalAirportCode: dest,
            arrivalCity: dest,
            arrivalTerminal: 'T1',
            arrivalDateTime: arr2.toISOString(),
            durationMinutes: 240,
            cabinClass: criteria.cabinClass,
            aircraftType: 'Boeing 787-9 Dreamliner',
          },
        ],
      });
    });

    // 3. 2-STOPS CONNECTING OFFERS (Multi-stop as requested)
    const dep2Stop = new Date(depDate);
    dep2Stop.setHours(6, 0, 0, 0);
    const a1 = new Date(dep2Stop.getTime() + 2 * 3600 * 1000);
    const d2 = new Date(a1.getTime() + 1.5 * 3600 * 1000);
    const a2 = new Date(d2.getTime() + 3 * 3600 * 1000);
    const d3 = new Date(a2.getTime() + 2 * 3600 * 1000);
    const a3 = new Date(d3.getTime() + 4 * 3600 * 1000);

    offers.push({
      providerOfferId: 'DEMO-2STOPS-MULTI-301',
      providerCode: this.providerId,
      isDemo: true,
      validatingAirline: 'Air Algerie & Qatar Airways',
      validatingAirlineCode: 'QR',
      basePrice: 230.0 * cabinMultiplier * criteria.adults,
      taxes: 65.0 * criteria.adults,
      currency: 'USD',
      seatsRemaining: 4,
      isRefundable: false,
      baggageSummary: '2 x 23 kg checked luggage',
      priceLockExpiry: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
      outboundSegments: [
        {
          airline: 'Air Algerie',
          airlineCode: 'AH',
          flightNumber: 'AH1000',
          departureAirport: `${origin} Airport`,
          departureAirportCode: origin,
          departureCity: origin,
          departureDateTime: dep2Stop.toISOString(),
          arrivalAirport: 'Rome FCO',
          arrivalAirportCode: 'FCO',
          arrivalCity: 'Rome',
          arrivalDateTime: a1.toISOString(),
          durationMinutes: 120,
          cabinClass: criteria.cabinClass,
          aircraftType: 'Boeing 737-800',
        },
        {
          airline: 'Qatar Airways',
          airlineCode: 'QR',
          flightNumber: 'QR132',
          departureAirport: 'Rome FCO',
          departureAirportCode: 'FCO',
          departureCity: 'Rome',
          departureDateTime: d2.toISOString(),
          arrivalAirport: 'Doha Hamad DOH',
          arrivalAirportCode: 'DOH',
          arrivalCity: 'Doha',
          arrivalDateTime: a2.toISOString(),
          durationMinutes: 180,
          cabinClass: criteria.cabinClass,
          aircraftType: 'Airbus A350-900',
        },
        {
          airline: 'Qatar Airways',
          airlineCode: 'QR',
          flightNumber: 'QR818',
          departureAirport: 'Doha Hamad DOH',
          departureAirportCode: 'DOH',
          departureCity: 'Doha',
          departureDateTime: d3.toISOString(),
          arrivalAirport: `${dest} Airport`,
          arrivalAirportCode: dest,
          arrivalCity: dest,
          arrivalDateTime: a3.toISOString(),
          durationMinutes: 240,
          cabinClass: criteria.cabinClass,
          aircraftType: 'Boeing 777-300ER',
        },
      ],
    });

    return offers;
  }

  async verifyPrice(offerId: string): Promise<{ isAvailable: boolean; currentBasePrice: number; currentTaxes: number }> {
    return { isAvailable: true, currentBasePrice: 145.0, currentTaxes: 42.0 };
  }

  async createBooking(request: FlightBookingRequest): Promise<FlightBookingResult> {
    const pnr = 'TG' + Math.random().toString(36).substring(2, 6).toUpperCase() + 'DZ';
    const tickets: Record<string, string> = {};
    request.passengers.forEach((p, idx) => {
      tickets[`${p.firstName} ${p.lastName}`] = `057-24901${100 + idx}`;
    });

    return {
      providerReference: pnr,
      ticketNumbers: tickets,
      isTicketIssued: true,
      status: 'confirmed',
      remarks: 'DEMO BOOKING ONLY - Generated by TravelGo Development Mock Provider',
    };
  }

  async cancelBooking(providerReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }> {
    return { isCancelled: true, refundEligible: true, cancellationFee: 25.0 };
  }
}
