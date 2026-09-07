import { MockFlightProvider } from '../src/providers/mock.flight.provider';

describe('Flight Provider Tests', () => {
  const provider = new MockFlightProvider();

  it('marks all mock results explicitly as DEMO DATA', async () => {
    expect(provider.isDemo).toBe(true);

    const offers = await provider.searchFlights({
      originCode: 'ALG',
      destinationCode: 'IST',
      departureDate: '2026-09-20',
      adults: 1,
      children: 0,
      infants: 0,
      cabinClass: 'Economy',
    });

    expect(offers.length).toBeGreaterThan(0);
    offers.forEach((offer) => {
      expect(offer.isDemo).toBe(true);
      expect(offer.outboundSegments.length).toBeGreaterThanOrEqual(1);
    });
  });

  it('generates multi-stop itineraries with layovers', async () => {
    const offers = await provider.searchFlights({
      originCode: 'ALG',
      destinationCode: 'DXB',
      departureDate: '2026-09-20',
      adults: 1,
      children: 0,
      infants: 0,
      cabinClass: 'Economy',
    });

    const multiStop = offers.find((o) => o.outboundSegments.length >= 2);
    expect(multiStop).toBeDefined();
    expect(multiStop!.outboundSegments.length).toBeGreaterThanOrEqual(2);
  });
});
