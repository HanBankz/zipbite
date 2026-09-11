import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav_controller.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<Map<String, dynamic>>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _fetchCartItems();

    selectedTabIndex.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (selectedTabIndex.value == 2 && mounted) {
      setState(() {
        _cartFuture = _fetchCartItems();
      });
    }
  }

  @override
  void dispose() {
    selectedTabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return [];

    final response = await Supabase.instance.client
        .from('cart_items')
        .select('id, quantity, menu_items(id, name, price, image_url)')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
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
          'My Cart',
          style: GoogleFonts.puppiesPlay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty',
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          double total = 0;
          for (var item in cartItems) {
            final menuItem = item['menu_items'];
            total += (menuItem['price'] as num) * (item['quantity'] as int);
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFFF7A00),
                  onRefresh: () async {
                    setState(() {
                      _cartFuture = _fetchCartItems();
                    });
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final menuItem = cartItem['menu_items'];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                menuItem['image_url'],
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          menuItem['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await Supabase.instance.client
                                              .from('cart_items')
                                              .delete()
                                              .eq('id', cartItem['id']);

                                          setState(() {
                                            _cartFuture = _fetchCartItems();
                                          });
                                        },
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 45,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${menuItem['price']}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (cartItem['quantity'] > 1) {
                                            await Supabase.instance.client
                                                .from('cart_items')
                                                .update({
                                                  'quantity':
                                                      cartItem['quantity'] - 1,
                                                })
                                                .eq('id', cartItem['id']);

                                            setState(() {
                                              _cartFuture = _fetchCartItems();
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          '${cartItem['quantity']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await Supabase.instance.client
                                              .from('cart_items')
                                              .update({
                                                'quantity':
                                                    cartItem['quantity'] + 1,
                                              })
                                              .eq('id', cartItem['id']);

                                          setState(() {
                                            _cartFuture = _fetchCartItems();
                                          });
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF7A00),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF7A00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PaymentScreen(totalAmount: total),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Checkout',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
