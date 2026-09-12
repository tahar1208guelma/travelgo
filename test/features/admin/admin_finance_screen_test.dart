import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/features/admin/presentation/pages/admin_finance_screen.dart';
import 'package:travelgo/features/admin/presentation/pages/withdrawal_request_modal.dart';
import 'package:travelgo/features/admin/presentation/pages/booking_financial_details_sheet.dart';

void main() {
  group('Admin Finance & Commission System Widget Tests', () {
    testWidgets('AdminFinanceScreen renders isolated multi-currency wallets and pipeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminFinanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and titles
      expect(find.text('TravelGo • Merchant Financial Wallet'), findsOneWidget);
      expect(find.text('Platform Owner Earnings Wallet'), findsOneWidget);
      expect(find.text('TravelGo 9-Stage Financial Security Pipeline'), findsOneWidget);

      // Verify isolated currency wallets
      expect(find.text('EUR Merchant Wallet'), findsOneWidget);
      expect(find.text('USD Merchant Wallet'), findsOneWidget);
      expect(find.text('DZD Merchant Wallet'), findsOneWidget);
      expect(find.text('GBP Merchant Wallet'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Wallets'), findsOneWidget);
      expect(find.text('Commissions'), findsOneWidget);
      expect(find.text('Ledger'), findsOneWidget);
      expect(find.text('Payouts'), findsOneWidget);
    });

    testWidgets('WithdrawalRequestModal enforces minimum withdrawal thresholds', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool requestSubmitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WithdrawalRequestModal(
              availableBalances: const {
                'EUR': 125.50,
                'USD': 80.00,
                'DZD': 24500.0,
                'GBP': 65.0,
              },
              bankAccounts: const [
                {
                  'id': 'bank-dz-01',
                  'bankName': 'Société Générale Algérie',
                  'accountHolderName': 'Platform Owner',
                  'iban': 'DZ5002100012345678901234',
                  'maskedIban': 'DZ****1234',
                  'swiftBic': 'SGEADZAL',
                  'country': 'Algeria',
                }
              ],
              onRequestSubmitted: (cur, amt, bankId) {
                requestSubmitted = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request Commission Payout'), findsOneWidget);
      expect(find.text('Destination Bank Account'), findsOneWidget);

      // Try entering an amount below minimum (< 50 EUR)
      final amountField = find.byType(TextFormField);
      await tester.enterText(amountField, '20');
      await tester.pumpAndSettle();

      final submitBtn = find.text('Submit Payout Request');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Should show validation error and NOT submit
      expect(find.textContaining('Minimum withdrawal for EUR is'), findsOneWidget);
      expect(requestSubmitted, isFalse);
    });

    testWidgets('BookingFinancialDetailsSheet renders 0.75% commission breakdown and security note', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookingFinancialDetailsSheet(
              bookingReference: 'BK-TEST-9988',
              providerReference: 'AH-PNR-7712',
              basePrice: 400.00,
              taxes: 50.00,
              commissionRate: 0.0075,
              commissionAmount: 3.00,
              totalPrice: 453.00,
              currency: 'EUR',
              status: 'confirmed',
              commissionStatus: 'available',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking Financial Audit'), findsOneWidget);
      expect(find.text('Ref: BK-TEST-9988'), findsOneWidget);
      expect(find.text('Commission Available'), findsOneWidget);
      expect(find.text('TravelGo Commission (0.75%)'), findsOneWidget);
      expect(find.textContaining('Commission Security Protocol'), findsOneWidget);
    });
  });
}
