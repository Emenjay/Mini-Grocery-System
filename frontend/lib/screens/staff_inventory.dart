// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'add_new_product.dart'; 

class InventoryStaffScreen extends StatefulWidget {
  const InventoryStaffScreen({super.key});

  @override
  State<InventoryStaffScreen> createState() => _InventoryStaffScreenState();
}

class _InventoryStaffScreenState extends State<InventoryStaffScreen> {
  String selectedCategory = 'Recently Added';
  String searchQuery = '';
  int currentPage = 1;
  final int itemsPerPage = 4; // keeping it low to test paging easily

  // updated category list
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

  // dummy data for testing
  final List<Map<String, dynamic>> staffItems = [
    {'id': '# 2026PC0001', 'name': 'Malunggay Lotion 500mL', 'category': 'Personal Care', 'stocks': 0, 'status': 'No Stock'},
    {'id': '# 2026B0002',  'name': 'Malunggay Juice 80mL',    'category': 'Beverages',     'stocks': 13, 'status': 'Low Stock'},
    {'id': '# 2026S0003',  'name': 'Malunggay Chips 20g',     'category': 'Snacks & Sweets', 'stocks': 80, 'status': 'In Stock'},
    {'id': '# 2026F0004',  'name': 'Frozen Malunggay',        'category': 'Frozen Goods',   'stocks': 45, 'status': 'In Stock'},
    {'id': '# 2026S0005',  'name': 'Corn Chips 50g',          'category': 'Snacks & Sweets', 'stocks': 100, 'status': 'In Stock'},
  ];

  // filter logic
  List<Map<String, dynamic>> get _filteredItems {
    return staffItems.where((item) {
      final matchesCategory = selectedCategory == 'Recently Added' || item['category'] == selectedCategory;
      final matchesSearch = item['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // paginate the filtered list
  List<Map<String, dynamic>> get _paginatedItems {
    final filtered = _filteredItems;
    int start = (currentPage - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  int get _totalPages => (_filteredItems.length / itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final itemsToShow = _paginatedItems;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
        backgroundColor: const Color(0xFF004D40), 
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // top search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  _circleIcon(Icons.keyboard_return, () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(color: AppColors.surfaceLightGray.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        onChanged: (val) => setState(() { searchQuery = val; currentPage = 1; }),
                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleIcon(Icons.search, () {}),
                  const SizedBox(width: 6),
                  _circleIcon(Icons.tune, () {}),
                ],
              ),
            ),

            // category scroll
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  bool isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontSize: 12)),
                      selected: isSelected,
                      onSelected: (val) => setState(() { selectedCategory = cat; currentPage = 1; }),
                      selectedColor: AppColors.primaryDarkTeal,
                      backgroundColor: AppColors.surfaceLightGray,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 24),

            // pagination shows up but color changes if only 1 page
            if (_filteredItems.isNotEmpty) _buildPagination(),

            const SizedBox(height: 10),

            // product list
            Expanded(
              child: itemsToShow.isEmpty 
                ? const Center(child: Text("no items in this category"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) => _buildProductCard(itemsToShow[index]),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // pagination row with conditional coloring
  Widget _buildPagination() {
    int total = _totalPages;
    bool hasMultiplePages = total > 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // prev btn
        _pageBtn(Icons.chevron_left, (hasMultiplePages && currentPage > 1) ? () => setState(() => currentPage--) : null),
        
        // number buttons
        for (int i = 1; i <= total; i++)
          _pageNum(
            i.toString(), 
            currentPage == i, 
            hasMultiplePages, // pass this to handle the color
            () => hasMultiplePages ? setState(() => currentPage = i) : null
          ),

        if (total > 3 && currentPage < total - 1) _pageNum("...", false, hasMultiplePages, () {}),

        // next btn
        _pageBtn(Icons.chevron_right, (hasMultiplePages && currentPage < total) ? () => setState(() => currentPage++) : null),
      ],
    );
  }

  // product card design
  Widget _buildProductCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(item['category'], style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic)),
                Text(item['id'], style: const TextStyle(fontSize: 10, color: Colors.black26)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_forward, size: 14, color: Colors.black45),
              const SizedBox(height: 12),
              Text("${item['stocks']} stocks", style: const TextStyle(fontSize: 12, color: Colors.black38)),
              const SizedBox(height: 4),
              _statusTag(item['status']),
            ],
          )
        ],
      ),
    );
  }

  // small helper UI functions
  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
        child: Icon(icon, size: 18, color: AppColors.primaryDarkTeal),
      ),
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: onTap != null ? const Color(0xFF3E5C51) : Colors.grey[400], // greyed out if disabled
          borderRadius: BorderRadius.circular(4)
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _pageNum(String txt, bool active, bool isInteractive, VoidCallback onTap) {
    // if only one page, the "active" color becomes a neutral grey instead of light blue
    Color activeColor = isInteractive ? const Color(0xFFB2DFDB) : Colors.grey[300]!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.black12, 
          borderRadius: BorderRadius.circular(4)
        ),
        child: Text(txt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statusTag(String status) {
    Color color = (status == 'In Stock') ? const Color(0xFF2D936C) : (status == 'Low Stock' ? Colors.orange : Colors.redAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}