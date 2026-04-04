// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import 'admin_product_detail.dart'; // keeps the connection active

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  String selectedCategory = 'Recently Added';
  String searchQuery = '';

  final List<String> categories = [
    'Recently Added',
    'Beverages',
    'Liquor & Tobacco',
    'Snacks & Sweets',
    'Fresh & Prepared',
    'Pantry Staples',
    'Frozen Goods',
    'Personal Care',
    'Household Care',
    'Miscellaneous',
  ];

  // expanded data to support the detail view fields
  List<Map<String, dynamic>> adminProducts = [
    {
      'id': 1, 
      'name': 'Malunggay Lotion 500mL', 
      'category': 'Personal Care', 
      'basePrice': 150.00, 
      'markup': 20.00, 
      'stocks': 550, 
      'status': 'No Stock',
      'description': 'nourishing lotion with cocoa extract and vitamin e.',
      'expiry': 'August 2, 2028'
    },
    {
      'id': 2, 
      'name': 'Malunggay Juice 80mL', 
      'category': 'Beverages', 
      'basePrice': 45.00, 
      'markup': 10.00, 
      'stocks': 12, 
      'status': 'Low Stock',
      'description': 'freshly squeezed malunggay extract with a hint of lemon.',
      'expiry': 'September 15, 2026'
    },
    {
      'id': 3, 
      'name': 'Malunggay Chips 20g', 
      'category': 'Snacks & Sweets', 
      'basePrice': 30.00, 
      'markup': 5.00, 
      'stocks': 100, 
      'status': 'In Stock',
      'description': 'crispy malunggay flavored crackers.',
      'expiry': 'October 20, 2026'
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return adminProducts.where((p) {
      final matchesCategory = selectedCategory == 'Recently Added' || p['category'] == selectedCategory;
      final matchesSearch = p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showActionSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(color: Color(0xFF76BA1B), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
              const SizedBox(height: 25),
              SizedBox(
                width: 120, height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mutedGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteProduct(int id) {
    setState(() => adminProducts.removeWhere((p) => p['id'] == id));
    _showActionSuccess("Product deleted successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mutedGreen,
      appBar: AppBar(
        backgroundColor: AppColors.mutedGreen,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png'),
        ),
        title: const Text('Inventory', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4.5),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  // search bar section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(color: AppColors.surfaceLightGray.withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
                            child: TextField(
                              onChanged: (v) => setState(() => searchQuery = v),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(icon: Icons.search, onTap: () {}),
                        const SizedBox(width: 6),
                        _CircleIconButton(icon: Icons.tune, onTap: () {}),
                      ],
                    ),
                  ),
                  // category chips
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
                            onTap: () => setState(() => selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryDarkTeal : AppColors.surfaceLightGray,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(cat, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 20),
                  // your original product card layout
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminProductDetailScreen(
                                  productList: filteredProducts,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Dismissible(
                            key: Key(product['id'].toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (dir) => _deleteProduct(product['id']),
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: AppColors.surfaceLightGray.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(product['category'], style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
                                      const SizedBox(height: 10),
                                      _buildStatusTag(product['status']),
                                    ],
                                  )
                                ],
                              ),
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
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor = status == 'In Stock' ? const Color(0xFF2D936C) : (status == 'Low Stock' ? const Color(0xFFF2A65A) : const Color(0xFFEF5350));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
        width: 35, height: 35,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceLightGray), color: AppColors.white),
        child: Icon(icon, color: AppColors.primaryDarkTeal, size: 18),
      ),
    );
  }
}