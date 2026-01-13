//import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
//import 'package:http/http.dart' as http;
import 'revenue_service.dart';

//// stripe deploy succeed, fix it = false
const bool kEnableStripeBackend = true;

class PaymentService {
  // static const String _paymentIntentUrl =  'https://asia-southeast1-phinom-coffee.cloudfunctions.net/createPaymentIntent';

  //// PROCESS PAYMENT
  Future<bool> processPayment({
    required double amount,
    required String orderId,
  }) async {
    try {
      if (kEnableStripeBackend) {
        final clientSecret = await _createPaymentIntent(
          amount: amount,
          currency: 'vnd',
        );

        if (clientSecret == null) {
          throw Exception('No client secret');
        }

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Coffee App',
          ),
        );

        await Stripe.instance.presentPaymentSheet();
      } else {
        // DEMO MODE
        await Future.delayed(const Duration(seconds: 2));
      }

      await RevenueService.saveRevenue(
        amount: amount,
        orderId: orderId,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  //// CREATE PAYMENT INTENT (DEMO)
  Future<String?> _createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    throw UnimplementedError(
      'Stripe backend not enabled (demo mode)',
    );
  }
}
