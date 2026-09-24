import { StripePaymentProvider } from '../src/providers/stripe.payment.provider';
import { ApiError } from '../src/errors/api.error';
import { ENV } from '../src/config/env';

// Mock Stripe library
jest.mock('stripe', () => {
  return jest.fn().mockImplementation(() => ({
    webhooks: {
      constructEvent: jest.fn(),
    },
  }));
});

import Stripe from 'stripe';

describe('StripePaymentProvider', () => {
  let provider: StripePaymentProvider;
  let mockStripeInstance: any;

  beforeEach(() => {
    // Clear mocks before each test
    jest.clearAllMocks();

    // We need to instantiate the provider *after* the mock is set up.
    // However, it's already instantiated during import in most cases.
    // Since Stripe is instantiated inside the class using `new Stripe()`, we can just create a new instance.
    provider = new StripePaymentProvider();

    // Get the mocked instance to setup return values
    // Since we just mocked it globally, any `new Stripe()` will return our mock object
    // We need to extract the mock instance returned by `new Stripe()`
    mockStripeInstance = (Stripe as unknown as jest.Mock).mock.results[0].value;
  });

  describe('verifyWebhookSignature', () => {
    const mockRawBody = '{"id":"evt_test","type":"payment_intent.succeeded"}';
    const mockSignature = 't=123,v1=test_sig';
    const mockSecret = ENV.STRIPE_WEBHOOK_SECRET;

    it('should return the parsed event when signature is valid', async () => {
      const mockEvent = { id: 'evt_test', type: 'payment_intent.succeeded' };

      // Setup the mock to return successfully
      mockStripeInstance.webhooks.constructEvent.mockReturnValue(mockEvent);

      const result = await provider.verifyWebhookSignature(mockRawBody, mockSignature);

      expect(mockStripeInstance.webhooks.constructEvent).toHaveBeenCalledWith(
        mockRawBody,
        mockSignature,
        mockSecret
      );
      expect(result).toEqual(mockEvent);
    });

    it('should throw an ApiError when signature verification fails', async () => {
      // Setup the mock to throw an error
      const mockError = new Error('No signatures found matching the expected signature for payload.');
      mockStripeInstance.webhooks.constructEvent.mockImplementation(() => {
        throw mockError;
      });

      await expect(
        provider.verifyWebhookSignature(mockRawBody, mockSignature)
      ).rejects.toThrow(ApiError);

      try {
        await provider.verifyWebhookSignature(mockRawBody, mockSignature);
      } catch (err: any) {
        expect(err.statusCode).toBe(400);
        expect(err.message).toContain('Webhook Error');
        expect(err.message).toContain(mockError.message);
      }
    });
  });
});
