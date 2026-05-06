// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../services/product_service.dart';
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
  final int itemsPerPage = 20;

  // live data from backend
  List<Map<String, dynamic>> staffItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  // pagination info from backend
  int _totalItems = 0;
  int _totalPages = 1;

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

  @override
  void initState() {
    super.initState();
    // load products from backend on screen init
    _loadProducts();
  }

  // --- ꜰᴇᴛᴄʜ ᴘʀᴏᴅᴜᴄᴛꜱ ꜰʀᴏᴍ ʙᴀᴄᴋᴇɴᴅ ---
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // map 'Recently Added' tab to no category filter
    final categoryFilter = selectedCategory == 'Recently Added' ? '' : selectedCategory;

    final result = await ProductService.getProducts(
      search: searchQuery,
      category: categoryFilter,
      page: currentPage,
      limit: itemsPerPage,
    );

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      final List<dynamic> products = data['products'];

      setState(() {
        // map backend fields to the shape the UI expects
        staffItems = products.map((p) => {
          'id': p['product_id'],           // int from backend
          'name': p['product_name'],
          'category': p['category_name'],
          'stocks': p['stock_quantity'] ?? 0,
          'status': p['stock_status'] ?? 'Out of Stock',
        }).toList();

        // update pagination from backend response
        _totalItems = data['pagination']['total'];
        _totalPages = data['pagination']['totalPages'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  // call delete api then refresh list
  Future<void> _deleteProduct(Map<String, dynamic> item) async {
    final result = await ProductService.deleteProduct(item['id']);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessModal();
      // refresh list after deletion
      await _loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to delete product')),
      );
    }
  }

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
                      onPressed: () async {
                        Navigator.pop(context); // close confirm dialog
                        await _deleteProduct(item); // call delete api
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
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // go to add product screen, refresh list when returning
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
          _loadProducts();
        },
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
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          // reset to page 1 and reload on search change
                          setState(() {
                            searchQuery = val;
                            currentPage = 1;
                          });
                          _loadProducts();
                        },
                        decoration: const InputDecoration(
                          hintText: "Search name or ID...",
                          hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleIcon(Icons.search, _loadProducts),
                  const SizedBox(width: 6),
                  // filter button - logic herer
                  _circleIcon(Icons.tune, () {}),
                ],
              ),
            ),

            // category filter chips
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
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        // reset page and reload when category changes
                        setState(() {
                          selectedCategory = cat;
                          currentPage = 1;
                        });
                        _loadProducts();
                      },
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

            // pagination controls
            if (_totalItems > 0) _buildPagination(),

            const SizedBox(height: 10),

            // product list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF35524A)))
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                      : staffItems.isEmpty
                          ? const Center(child: Text("No items found"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: staffItems.length,
                              itemBuilder: (context, index) => _buildProductCard(staffItems, index),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    bool hasMultiplePages = _totalPages > 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageBtn(
          Icons.chevron_left,
          (hasMultiplePages && currentPage > 1)
              ? () {
                  setState(() => currentPage--);
                  _loadProducts();
                }
              : null,
        ),
        for (int i = 1; i <= _totalPages; i++)
          _pageNum(
            i.toString(),
            currentPage == i,
            hasMultiplePages,
            () {
              if (hasMultiplePages) {
                setState(() => currentPage = i);
                _loadProducts();
              }
            },
          ),
        _pageBtn(
          Icons.chevron_right,
          (hasMultiplePages && currentPage < _totalPages)
              ? () {
                  setState(() => currentPage++);
                  _loadProducts();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildProductCard(List<Map<String, dynamic>> list, int index) {
    final item = list[index];

    return Dismissible(
      // use product_id as key since dummy string ids are gone
      key: Key(item['id'].toString()),
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
        onTap: () async {
          // go to product detail, refresh list on return in case edits were made
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                productList: list,
                initialIndex: index,
              ),
            ),
          );
          _loadProducts();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(item['category'], style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic)),
                    // display product id from backend
                    Text('#${item['id']}', style: const TextStyle(fontSize: 10, color: Color(0xFF3E5C51), fontWeight: FontWeight.bold)),
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
        width: 36,
        height: 36,
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
          borderRadius: BorderRadius.circular(4),
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
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(txt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statusTag(String status) {
    Color color = (status == 'In Stock')
        ? const Color(0xFF2D936C)
        : (status == 'Low Stock' ? Colors.orange : Colors.redAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}