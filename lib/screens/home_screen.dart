import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zipbite/screens/food_detail_screen.dart';
import 'nav_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location off';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = 'Permission denied';
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _currentLocation = '${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to get location';
      });
    }
  }

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'pizza',
    'Burgers',
    'Drinks',
    'Rice',
  ];

  Future<int> _fetchOrderCount() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await Supabase.instance.client
        .from('orders')
        .select('id')
        .eq('user_id', userId);

    return response.length;
  }

  void _showProfileSheet(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final avatarUrl = metadata?['avatar_url'];
    final joinDate = user?.createdAt != null
        ? DateTime.parse(user!.createdAt).toString().substring(0, 10)
        : 'Unknown';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 36, color: Colors.black54)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _getUserName(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Joined',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        joinDate,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<int>(
                    future: _fetchOrderCount(),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Text(
                            'Orders',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.data ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    selectedTabIndex.value = 4;
                  },
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF7A00),
                    side: const BorderSide(color: Color(0xFFFF7A00)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchMenuItems() async {
    final response = await Supabase.instance.client
        .from('menu_items')
        .select(
          'id, name, price, image_url, description, restaurants(name, category, rating)',
        );
    debugPrint('RAW RESPONSE: $response');
    return List<Map<String, dynamic>>.from(response);
  }

  String _getUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;

    return metadata?['full_name'] ?? metadata?['name'] ?? 'there';
  }

  @override
  Widget build(BuildContext coontext) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A00),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi, ${_getUserName()}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ), //namae logic and location logic
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 19, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _currentLocation,
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                _showProfileSheet(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchMenuItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final allItems = snapshot.data ?? [];
            final filteredItems = _selectedCategory == 'All'
                ? allItems
                : allItems
                      .where(
                        (item) =>
                            item['restaurants']['category'] ==
                            _selectedCategory,
                      )
                      .toList();

            return Padding(
              padding: const EdgeInsets.all(42.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 47),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF7A00)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  Text(
                    'Suggestions for you',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final restaurant = item['restaurants'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodDetailScreen(item: item),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                  child: Image.network(
                                    item['image_url'],
                                    height: 190,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey[300],
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(17.5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['name'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${item['price']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFF7A00),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        restaurant['name'],
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Color(0xFFFF7A00),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${restaurant['rating']}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
