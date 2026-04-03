import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String selectedCategory = 'Recently Added';
  String searchQuery = '';

  final List<String> categories = [
    'Recently Added',
    'Beverages',
    'Snacks',
    'Frozen Foods',
    'Personal Care',
  ];

  // 'added' = true. gray '+' button = already in cart
  List<Map<String, dynamic>> products = [
    {'id': 1, 'name': 'Malunggay Lotion 500mL',  'category': 'Personal Care',  'price': 170.00, 'added': true},
    {'id': 2, 'name': 'Malunggay Juice 80mL',     'category': 'Beverages',      'price': 55.00,  'added': false},
    {'id': 3, 'name': 'Malunggay Chips 20g',      'category': 'Snacks',         'price': 35.00,  'added': false},
    {'id': 4, 'name': 'Frozen Malunggay',         'category': 'Frozen Foods',   'price': 90.00,  'added': false},
    {'id': 5, 'name': 'Malunggay Facewash 30mL',  'category': 'Personal Care',  'price': 120.00, 'added': false},
  ];

  // Filter by active chip and search text.
  List<Map<String, dynamic>> get filteredProducts {
    return products.where((p) {
      final matchesCategory =
        selectedCategory == 'Recently Added' ||
        p['category'] == selectedCategory;
      final matchesSearch = p['name']
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // toggle using unique id
  void _toggleAdd(int productId) {
    setState(() {
      final index = products.indexWhere((p) => p['id'] == productId);
      if (index != -1) {
        products[index]['added'] = !(products[index]['added'] as bool);
      }
    });
  }

  // ------ Navigate to the 'Add Product' screen.
  void _openAddNew() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mutedGreen,

      // ---- APP BAR 
      appBar: AppBar(
        backgroundColor: AppColors.mutedGreen,
        elevation: 0,
        
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
          ),
        ),
        
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      // ---- BODY 
      body: Column(
        children: [
          // --- white card
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4.5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [

                  // ----- SEARCH BAR 
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 29,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLightGray.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: TextField(
                              onChanged: (v) =>
                              setState(() => searchQuery = v),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),      
                              ),
                              
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // search button 
                        _CircleIconButton(
                          icon: Icons.search,
                          onTap: () {

                          },
                        ),

                        const SizedBox(width: 6),

                        // filter button 
                        _CircleIconButton(
                          icon: Icons.tune,
                          onTap: () {

                          },
                        ),
                      ],
                    ),
                  ),

                  // ----- CATEGORY CHIPS
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            
                            onTap: () =>
                                setState(() => selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                
                                color: isSelected
                                ? AppColors.primaryDarkTeal : AppColors.surfaceLightGray,
                                
                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Text(
                                cat,
                                style: const TextStyle(
                                  fontSize: 12,
                                
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 16),

                  // ---- PRODUCT LIST
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isAdded = product['added'] as bool;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.surfaceLightGray.withValues(alpha:0.6)),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [

                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
    
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // --- Product info 
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14, 12, 8, 12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          product['name'].toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),

                                        Text(
                                          product['category'].toString(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),

                                        // spacer pushes price to the bottom
                                        const Spacer(),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            '₱ ${(product['price'] as double).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // --- ADD button. navigates to 'Add Product screen'
                                GestureDetector(
                                  onTap: _openAddNew,
                                  child: Container(
                                    width: 56,
                                    constraints: const BoxConstraints(
                                      minHeight: 70),
                                    decoration: BoxDecoration(
                                      color: isAdded
                                        ? Colors.grey[400] : AppColors.mutedGreen,
            
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),

                                    child: const Icon(
                                      Icons.add,

                                      color: Colors.white,
                                      size: 28,
                                    ),
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
            ),
          ),

          // TODO: add bottom nav bar



        ],
      ),
    );
  }
}

// ------ placeholder for 'Add Product' screen
class AddNewScreen extends StatelessWidget {
  const AddNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: AppColors.primaryDarkTeal,
      appBar: AppBar(
        backgroundColor: AppColors.mutedGreen,
        elevation: 0,
        
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: const Center(
        child: Text(
          'hai hello',
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceLightGray),
          color: AppColors.white,
        ),
        child: Icon(icon, color: AppColors.primaryDarkTeal, size: 20),
      ),
    );
  }
}