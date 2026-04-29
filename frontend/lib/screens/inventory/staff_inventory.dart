// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import 'add_new_product.dart'; 
import 'product_detail.dart'; 

class InventoryStaffScreen extends StatefulWidget {
  const InventoryStaffScreen({super.key});

  @override
  State<InventoryStaffScreen> createState() => _InventoryStaffScreenState();
}

class _InventoryStaffScreenState extends State<InventoryStaffScreen> {
  String selectedCategory = 'Recently Added';
  String searchQuery = '';
  int currentPage = 1;
  final int itemsPerPage = 4; 

  // --- ᴍᴀᴘᴘɪɴɢ ꜰᴏʀ ɪᴅ ᴄᴏɴꜱɪꜱᴛᴇɴᴄʏ ---
  final Map<String, String> categoryCodes = {
    'Beverages': 'BEV',
    'Liquor & Tobacco': 'LIQ',
    'Snacks & Sweets': 'SNA',
    'Fresh & Prepared': 'FRE',
    'Pantry Staples': 'PAN',
    'Frozen Goods': 'FRO',
    'Personal Care': 'PER',
    'Household Care': 'HOU',
    'Miscellaneous': 'MIS',
  };

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

  // ᴜᴘᴅᴀᴛᴇᴅ ɪᴛᴇᴍ ʟɪꜱᴛ ᴡɪᴛʜ ᴛʜᴇ ɴᴇᴡ ᴅᴀᴛᴀʙᴀꜱᴇ-ꜱᴛʏʟᴇ ɪᴅ ꜰᴏʀᴍᴀᴛ
  final List<Map<String, dynamic>> staffItems = [
    {'id': 'PER-202604-0001', 'name': 'Malunggay Lotion 500mL', 'category': 'Personal Care', 'stocks': 0, 'status': 'No Stock'},
    {'id': 'BEV-202604-0002', 'name': 'Malunggay Juice 80mL', 'category': 'Beverages', 'stocks': 13, 'status': 'Low Stock'},
    {'id': 'SNA-202604-0003', 'name': 'Malunggay Chips 20g', 'category': 'Snacks & Sweets', 'stocks': 80, 'status': 'In Stock'},
    {'id': 'FRO-202604-0004', 'name': 'Frozen Malunggay', 'category': 'Frozen Goods', 'stocks': 45, 'status': 'In Stock'},
    {'id': 'SNA-202604-0005', 'name': 'Corn Chips 50g', 'category': 'Snacks & Sweets', 'stocks': 100, 'status': 'In Stock'},
  ];

  List<Map<String, dynamic>> get _filteredItems {
    return staffItems.where((item) {
      final matchesCategory = selectedCategory == 'Recently Added' || item['category'] == selectedCategory;
      final matchesSearch = item['name'].toLowerCase().contains(searchQuery.toLowerCase()) || 
                           item['id'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> get _paginatedItems {
    final filtered = _filteredItems;
    int start = (currentPage - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  int get _totalPages => (_filteredItems.length / itemsPerPage).ceil();

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 60),
                const SizedBox(height: 16),
                const Text("Are you deleting?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "Are you sure you want to delete ${item['name']}?\n(ID: ${item['id']})",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          staffItems.removeWhere((element) => element['id'] == item['id']);
                        });
                        Navigator.pop(context); 
                        _showSuccessModal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2D936C), size: 60),
                const SizedBox(height: 16),
                const Text("Deletion Successful", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("The item has been removed from inventory.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

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
                  _circleIcon(Icons.tune, () {}),
                ],
              ),
            ),

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

  Widget _buildPagination() {
    int total = _totalPages;
    bool hasMultiplePages = total > 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageBtn(Icons.chevron_left, (hasMultiplePages && currentPage > 1) ? () => setState(() => currentPage--) : null),
        for (int i = 1; i <= total; i++)
          _pageNum(i.toString(), currentPage == i, hasMultiplePages, () => hasMultiplePages ? setState(() => currentPage = i) : null),
        _pageBtn(Icons.chevron_right, (hasMultiplePages && currentPage < total) ? () => setState(() => currentPage++) : null),
      ],
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                productList: list, 
                initialIndex: index,
              ),
            ),
          );
        },
        child: Container(
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
                    // ᴅɪꜱᴘʟᴀʏ ɴᴇᴡ ꜰᴏʀᴍᴀᴛᴛᴇᴅ ɪᴅ
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
          color: onTap != null ? const Color(0xFF3E5C51) : Colors.grey[400], 
          borderRadius: BorderRadius.circular(4)
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _pageNum(String txt, bool active, bool isInteractive, VoidCallback onTap) {
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