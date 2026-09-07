import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Future<Map<String, dynamic>> _fetchOrderInfo() async {
    final order = await Supabase.instance.client
        .from('orders')
        .select('status, restaurants(name)')
        .eq('id', widget.orderId)
        .single();

    return order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A00),
        elevation: 0,
        title: Text(
          'Track Order',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchOrderInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data!;
          final restaurant = order['restaurants'];
          final status = order['status'];

          const restaurantLocation = LatLng(11.9914, 8.5317);
          const userLocation = LatLng(12.0022, 8.5920);

          return Column(
            children: [
              SizedBox(
                height: 250,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: restaurantLocation,
                    zoom: 12,
                  ),
                  markers: {
                    const Marker(
                      markerId: MarkerId('restaurant'),
                      position: restaurantLocation,
                      infoWindow: InfoWindow(title: 'Restaurant'),
                    ),
                    Marker(
                      markerId: MarkerId('user'),
                      position: userLocation,
                      infoWindow: InfoWindow(title: 'You'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                    ),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant != null ? restaurant['name'] : 'Restaurant',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatusStep('Order placed', true),
                    _buildStatusStep(
                      'Preparing',
                      status == 'preparing' ||
                          status == 'out_for_delivery' ||
                          status == 'delivered',
                    ),
                    _buildStatusStep(
                      'Out for delivery',
                      status == 'out_for_delivery' || status == 'delivered',
                    ),
                    _buildStatusStep('Delivered', status == 'delivered'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? const Color(0xFFFF7A00) : Colors.grey[400],
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              color: isDone ? Colors.black : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
