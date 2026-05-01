// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedCategory = 'Recently Added';
  String searchQuery = '';
  
  String activeStockFilter = '';
  String activeExpiryFilter = '';
  
  // SORTING STATES
  String activeSortAlpha = 'A-Z'; 
  String activeSortPrice = 'None'; 

  final List<String> categories = [
    'Recently Added', 'Beverages', 'Liquor & Tobacco', 'Snacks & Sweets',
    'Fresh & Prepared', 'Pantry Staples', 'Frozen Goods', 'Personal Care',
    'Household Care', 'Miscellaneous',
  ];

  final List<String> expirationMonths = [
    'May 2026', 'June 2026', 'July 2026', 'August 2026',
    'September 2026', 'October 2026', 'November 2026', 'December 2026'
  ];

  List<Map<String, dynamic>> products = [
    {'id': 1, 'name': 'Malunggay Lotion 500mL', 'category': 'Personal Care', 'price': 170.00, 'added': true},
    {'id': 2, 'name': 'Malunggay Juice 80mL', 'category': 'Beverages', 'price': 55.00, 'added': false},
    {'id': 3, 'name': 'Malunggay Chips 20g', 'category': 'Snacks', 'price': 35.00, 'added': false},
    {'id': 4, 'name': 'Frozen Malunggay', 'category': 'Frozen Goods', 'price': 90.00, 'added': false},
    {'id': 5, 'name': 'Malunggay Facewash 30mL', 'category': 'Personal Care', 'price': 120.00, 'added': false},
  ];

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> list = products.where((p) {
      final matchesCategory = selectedCategory == 'Recently Added' || p['category'] == selectedCategory;
      final matchesSearch = p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    list.sort((a, b) {
      int cmp = a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase());
      return activeSortAlpha == 'A-Z' ? cmp : -cmp;
    });

    if (activeSortPrice != 'None') {
      list.sort((a, b) {
        int cmp = (a['price'] as double).compareTo(b['price'] as double);
        return activeSortPrice == 'Ascending' ? cmp : -cmp;
      });
    }

    return list;
  }

  void _toggleAdd(int productId) {
    setState(() {
      final index = products.indexWhere((p) => p['id'] == productId);
      if (index != -1) products[index]['added'] = true;
    });
  }

  void _showAddToCartDialog(Map<String, dynamic> product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Add to Cart", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                    const Divider(height: 30),
                    Text(product['name'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _quantityBtn(Icons.remove, () {
                          if (quantity > 1) setDialogState(() => quantity--);
                        }),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: AppColors.surfaceLightGray.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                          child: Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        _quantityBtn(Icons.add, () => setDialogState(() => quantity++)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _priceRow("Retail Price:", "₱ ${product['price'].toStringAsFixed(2)}"),
                    _priceRow("Total Price:", "₱ ${(product['price'] * quantity).toStringAsFixed(2)}", isTotal: true),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryDarkTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text("Cancel", style: TextStyle(color: AppColors.primaryDarkTeal)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _toggleAdd(product['id']);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mutedGreen,

      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 60, 20, 20),
              child: Text(
                "Filters",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildExpansionTile("Categories", children: [
                    ...categories.map((cat) => _buildDrawerLink(
                      cat, 
                      isSelected: selectedCategory == cat,
                      onTap: () {
                        setState(() => selectedCategory = cat);
                        Navigator.pop(context);
                      }
                    )),
                  ]),
                  _buildExpansionTile("Stock Status", children: [
                    _buildDrawerLink("Available", isSelected: activeStockFilter == "Available", onTap: () => setState(() => activeStockFilter = "Available")),
                    _buildDrawerLink("Low Stock", isSelected: activeStockFilter == "Low Stock", onTap: () => setState(() => activeStockFilter = "Low Stock")),
                    _buildDrawerLink("No Stock", isSelected: activeStockFilter == "No Stock", onTap: () => setState(() => activeStockFilter = "No Stock")),
                  ]),
                  _buildExpansionTile("Expiration Date", children: [
                    ...expirationMonths.map((month) => _buildDrawerLink(
                      month, 
                      isSelected: activeExpiryFilter == month,
                      onTap: () => setState(() => activeExpiryFilter = month),
                    )),
                  ]),
                  
                  const Divider(height: 40, thickness: 1, indent: 15, endIndent: 15),

                  // SORTING SECTION - ALWAYS VISIBLE AT BOTTOM
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Alphabetical Sort", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  ),
                  _buildSortRadio("A - Z", "A-Z", activeSortAlpha, (val) => setState(() => activeSortAlpha = val!)),
                  _buildSortRadio("Z - A", "Z-A", activeSortAlpha, (val) => setState(() => activeSortAlpha = val!)),
                  
                  const SizedBox(height: 15),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Price Sort", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  ),
                  _buildSortRadio("None", "None", activeSortPrice, (val) => setState(() => activeSortPrice = val!)),
                  _buildSortRadio("Ascending", "Ascending", activeSortPrice, (val) => setState(() => activeSortPrice = val!)),
                  _buildSortRadio("Descending", "Descending", activeSortPrice, (val) => setState(() => activeSortPrice = val!)),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),

appBar: AppBar(
        backgroundColor: AppColors.mutedGreen,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, 
        leadingWidth: 70, 
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8), // Match your example's padding
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_return, // Points LEFT by default
                  color: AppColors.primaryDarkTeal, 
                  size: 22,
                ),
              ),
            ),
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

      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4.5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 29,
                            decoration: BoxDecoration(color: AppColors.surfaceLightGray.withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
                            child: TextField(
                              onChanged: (v) => setState(() => searchQuery = v),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(icon: Icons.search, onTap: () {}),
                        const SizedBox(width: 6),
                        _CircleIconButton(
                          icon: Icons.tune,
                          onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
                        ),
                      ],
                    ),
                  ),
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
                              decoration: BoxDecoration(color: isSelected ? AppColors.primaryDarkTeal : AppColors.surfaceLightGray, borderRadius: BorderRadius.circular(18)),
                              child: Text(cat, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isAdded = product['added'] as bool;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.surfaceLightGray.withOpacity(0.6)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                        const SizedBox(height: 2),
                                        Text(product['category'].toString(), style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic)),
                                        const Spacer(),
                                        Align(alignment: Alignment.bottomRight, child: Text('₱ ${(product['price'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (!isAdded) _showAddToCartDialog(product);
                                  },
                                  child: Container(
                                    width: 56,
                                    constraints: const BoxConstraints(minHeight: 70),
                                    decoration: BoxDecoration(
                                      color: isAdded ? Colors.grey[400] : AppColors.mutedGreen,
                                      borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 28),
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
        ],
      ),
    );
  }

  Widget _buildSortRadio(String title, String value, String groupValue, Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 15)),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primaryDarkTeal,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      onChanged: onChanged,
    );
  }

  Widget _buildExpansionTile(String title, {required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(color: AppColors.primaryDarkTeal, fontWeight: FontWeight.bold)),
        children: children,
      ),
    );
  }

  Widget _buildDrawerLink(String text, {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        child: Text(
          text, 
          style: TextStyle(
            color: isSelected ? AppColors.primaryDarkTeal : Colors.black54, 
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
            decorationThickness: 2,
          )
        ),
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryDarkTeal, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14, color: isTotal ? Colors.black : Colors.black87)),
        ],
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
        width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceLightGray), color: Colors.white),
        child: Icon(icon, color: AppColors.primaryDarkTeal, size: 20),
      ),
    );
  }
}