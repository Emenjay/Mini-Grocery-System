// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../theme/colors.dart';
import 'add_new_product.dart'; 
import 'product_detail.dart'; 

class InventoryStaffScreen extends StatefulWidget {
  const InventoryStaffScreen({super.key});

  @override
  State<InventoryStaffScreen> createState() => _InventoryStaffScreenState();
}

class _InventoryStaffScreenState extends State<InventoryStaffScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 
  String searchQuery = '';
  int currentPage = 1;
  final int itemsPerPage = 4; 

  // synchronization with inventory_screen states
  String selectedCategory = 'Recently Added';
  String activeStockFilter = '';
  String activeExpiryFilter = '';
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

  final List<Map<String, dynamic>> staffItems = [
    {'id': 'PER-202604-0001', 'name': 'Malunggay Lotion 500mL', 'category': 'Personal Care', 'stocks': 0, 'status': 'No Stock', 'basePrice': 150.0, 'markup': 20.0, 'expiryStatus': 'Fresh'},
    {'id': 'BEV-202604-0002', 'name': 'Malunggay Juice 80mL', 'category': 'Beverages', 'stocks': 13, 'status': 'Low Stock', 'basePrice': 45.0, 'markup': 10.0, 'expiryStatus': 'Expiring Soon'},
    {'id': 'SNA-202604-0003', 'name': 'Malunggay Chips 20g', 'category': 'Snacks & Sweets', 'stocks': 80, 'status': 'In Stock', 'basePrice': 30.0, 'markup': 5.0, 'expiryStatus': 'Fresh'},
    {'id': 'FRO-202604-0004', 'name': 'Frozen Malunggay', 'category': 'Frozen Goods', 'stocks': 45, 'status': 'In Stock', 'basePrice': 80.0, 'markup': 15.0, 'expiryStatus': 'Fresh'},
    {'id': 'SNA-202604-0005', 'name': 'Corn Chips 50g', 'category': 'Snacks & Sweets', 'stocks': 100, 'status': 'In Stock', 'basePrice': 25.0, 'markup': 5.0, 'expiryStatus': 'Expiring Soon'},
  ];

  // filter logic
  List<Map<String, dynamic>> get _filteredItems {
    List<Map<String, dynamic>> filtered = staffItems.where((item) {
      final matchesCategory = selectedCategory == 'Recently Added' || item['category'] == selectedCategory;
      final matchesSearch = item['name'].toLowerCase().contains(searchQuery.toLowerCase()) || 
                           item['id'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStock = activeStockFilter.isEmpty || 
                          (activeStockFilter == "Available" && item['status'] == "In Stock") ||
                          item['status'] == activeStockFilter;
      
      return matchesCategory && matchesSearch && matchesStock;
    }).toList();

    // alphabetical sort
    filtered.sort((a, b) {
      int cmp = a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase());
      return activeSortAlpha == 'A-Z' ? cmp : -cmp;
    });

    // price sort
    if (activeSortPrice != 'None') {
      filtered.sort((a, b) {
        double pA = (a['basePrice'] ?? 0) + (a['markup'] ?? 0);
        double pB = (b['basePrice'] ?? 0) + (b['markup'] ?? 0);
        return activeSortPrice == 'Ascending' ? pA.compareTo(pB) : pB.compareTo(pA);
      });
    }
    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedItems {
    final filtered = _filteredItems;
    int start = (currentPage - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  int get _totalPages => (_filteredItems.length / itemsPerPage).ceil();

  // sidebar methods from inventory_screen.dart
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

  @override
  Widget build(BuildContext context) {
    final itemsToShow = _paginatedItems;
    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: Colors.white,
      
      // exact drawer from inventory_screen.dart
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
                        setState(() {
                          selectedCategory = cat;
                          currentPage = 1;
                        });
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
        backgroundColor: const Color(0xFF004D40), 
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                        decoration: const InputDecoration(
                          hintText: "Search name or ID...",
                          hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleIcon(Icons.search, () {}),
                  const SizedBox(width: 6),
                  _circleIcon(Icons.tune, () => _scaffoldKey.currentState?.openEndDrawer()),
                ],
              ),
            ),
            
            // horizontal category chips
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
                      onSelected: (val) => setState(() { 
                        if (val) selectedCategory = cat;
                        currentPage = 1; 
                      }),
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
            if (_filteredItems.isNotEmpty) _buildPagination(),
            const SizedBox(height: 10),
            Expanded(
              child: itemsToShow.isEmpty 
                ? const Center(child: Text("No items found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) => _buildProductCard(itemsToShow, index),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(List<Map<String, dynamic>> list, int index) {
    final item = list[index];
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _showDeleteConfirmation(context, item);
        return false; 
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productList: list, initialIndex: index))),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15),
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
                    Text(item['id'], style: const TextStyle(fontSize: 10, color: Color(0xFF3E5C51), fontWeight: FontWeight.bold)),
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
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text("Remove ${item['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
            setState(() => staffItems.removeWhere((e) => e['id'] == item['id']));
            Navigator.pop(context);
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

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

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageBtn(Icons.chevron_left, currentPage > 1 ? () => setState(() => currentPage--) : null),
        for (int i = 1; i <= _totalPages; i++)
          _pageNum(i.toString(), currentPage == i, _totalPages > 1, () => setState(() => currentPage = i)),
        _pageBtn(Icons.chevron_right, currentPage < _totalPages ? () => setState(() => currentPage++) : null),
      ],
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: onTap != null ? const Color(0xFF3E5C51) : Colors.grey[400], borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _pageNum(String txt, bool active, bool interactive, VoidCallback onTap) {
    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: active ? const Color(0xFFB2DFDB) : Colors.black12, borderRadius: BorderRadius.circular(4)),
        child: Text(txt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statusTag(String status) {
    Color color = (status == 'In Stock' || status == 'Available') ? const Color(0xFF2D936C) : (status == 'Low Stock' ? Colors.orange : Colors.redAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}