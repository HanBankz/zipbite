import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_success_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://hjlvjaburlidoovjnwmv.supabase.co/functions/v1/create-payment-intent',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': widget.totalAmount}),
      );

      final data = jsonDecode(response.body);

      if (data['client_secret'] == null) {
        throw Exception(data['error'] ?? 'Failed to create payment intent');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['client_secret'],
          merchantDisplayName: 'Zipbite',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Payment succeeded - clear cart and navigate next
      await _clearCartAndProceed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearCartAndProceed() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return;

    final cartItems = await Supabase.instance.client
        .from('cart_items')
        .select('menu_item_id, quantity, menu_items(price, restaurant_id)')
        .eq('user_id', userId);

    final orderResponse = await Supabase.instance.client
        .from('orders')
        .insert({
          'user_id': userId,
          'restaurant_id': cartItems.isNotEmpty
              ? cartItems[0]['menu_items']['restaurant_id']
              : null,
          'total': widget.totalAmount,
          'status': 'placed',
        })
        .select()
        .single();

    final orderId = orderResponse['id'];

    for (var item in cartItems) {
      await Supabase.instance.client.from('order_items').insert({
        'order_id': orderId,
        'menu_item_id': item['menu_item_id'],
        'quantity': item['quantity'],
        'price_at_purchase': item['menu_items']['price'],
      });
    }

    await Supabase.instance.client
        .from('cart_items')
        .delete()
        .eq('user_id', userId);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(orderId: orderId),
        ),
        (route) => false,
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A00),
        elevation: 0,
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF7A00),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Pay now',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

