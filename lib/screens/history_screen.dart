import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zipbite/screens/order_success_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return [];

    final response = await Supabase.instance.client
        .from('orders')
        .select('id, total, status, created_at, restaurants(name, image_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A00),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFFFF7A00),
              onRefresh: () async {
                setState(() {
                  _ordersFuture = _fetchOrders();
                });
              },
              child: ListView(
                children: [
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Text(
                        'No orders yet',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFFF7A00),
            onRefresh: () async {
              setState(() {
                _ordersFuture = _fetchOrders();
              });
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                final restaurant = order['restaurants'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderSuccessScreen(orderId: order['id']),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            restaurant != null
                                ? restaurant['image_url'] ?? ''
                                : '',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.storefront,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${order['total']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF7A00),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                order['created_at'].toString().substring(0, 16),
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: order['status'] == 'delivered'
                                          ? Colors.green[100]
                                          : const Color(0xFFFFE4CC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order['status']
                                          .toString()
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                      style: GoogleFonts.roboto(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: order['status'] == 'delivered'
                                            ? Colors.green[800]
                                            : const Color(0xFFFF7A00),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${order['total']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFF7A00),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
