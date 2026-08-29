import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Pizza',
    'Burgers',
    'Drinks',
    'Chicken',
    'Rice',
  ];

  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Zunich Burgers',
      'restaurant': 'Zunich Kitchen, kano',
      'category': 'Burgers',
      'price': 8.99,
      'rating': 4.5,
      'distance': '0.5 km',
    },
    {
      'name': 'dominos Pizza',
      'restaurant': 'dominos & coldstone',
      'category': 'Pizza',
      'price': 12.50,
      'rating': 4.7,
      'distance': '1.2 km',
    },
    {
      'name': 'Chicken Republic Combo',
      'restaurant': 'Chicken Republic, kano',
      'category': 'Chicken',
      'price': 6.00,
      'rating': 4.3,
      'distance': '0.8 km',
    },
    {
      'name': 'Iced Lemonade',
      'restaurant': 'Amoon sips & bites',
      'category': 'Drinks',
      'price': 3.50,
      'rating': 4.6,
      'distance': '0.3 km',
    },
    {
      'name': 'Jollof Rice Special',
      'restaurant': 'Mama\'s Kitchen',
      'category': 'Rice',
      'price': 5.50,
      'rating': 4.8,
      'distance': '1.0 km',
    },
    // Added more items so "All" has a fuller feed to scroll through
    {
      'name': 'Cheese Burger Deluxe',
      'restaurant': 'Burger House',
      'category': 'Burgers',
      'price': 9.50,
      'rating': 4.4,
      'distance': '0.9 km',
    },
    {
      'name': 'Pepperoni Pizza',
      'restaurant': 'Roma Pizzeria',
      'category': 'Pizza',
      'price': 13.00,
      'rating': 4.6,
      'distance': '1.3 km',
    },
    {
      'name': 'Grilled Chicken Wrap',
      'restaurant': 'Chicken Republic',
      'category': 'Chicken',
      'price': 7.00,
      'rating': 4.2,
      'distance': '1.1 km',
    },
    {
      'name': 'Fresh Orange Juice',
      'restaurant': 'Juice Bar',
      'category': 'Drinks',
      'price': 3.00,
      'rating': 4.5,
      'distance': '0.4 km',
    },
    {
      'name': 'Fried Rice Special',
      'restaurant': 'Mama\'s Kitchen',
      'category': 'Rice',
      'price': 6.00,
      'rating': 4.7,
      'distance': '1.0 km',
    },
  ];
  @override
  Widget build(BuildContext coontext) {
    final filteredItems = _selectedCategory == 'All'
        ? _foodItems
        : _foodItems
              .where((item) => item['category'] == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, Ridwan',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFFFF7A00),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kano, Nigeria',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ), //google logic
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 49),

              // Horizontal scrollable row of category chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 24, height: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return GestureDetector(
                      // Tapping a chip updates _selectedCategory, which
                      // triggers the filteredItems computation above to rerun
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          // Selected chip is orange, unselected is light grey
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
                            // Text is white on the selected orange chip,
                            // dark grey on unselected chips
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Near you',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // Expanded lets this list take up all remaining vertical
              // space, and makes it scrollable independent of the header
              Expanded(
                child: ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      // Cards are now vertical: big image on top, details below,
                      // instead of the small horizontal row layout before
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full-width image area, much taller than before.
                          // Swap this Container for Image.network(item['imageUrl'])
                          // once real images are uploaded to Supabase Storage
                          Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  item['restaurant'],
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
                                      '${item['rating']}',
                                      style: GoogleFonts.roboto(fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      item['distance'],
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: Colors.grey[600],
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
            ],
          ),
        ),
      ),
    );
  }
}
