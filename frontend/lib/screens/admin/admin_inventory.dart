import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../services/inventory_service.dart';
import 'admin_product_detail.dart';

class AdminInventoryScreen extends StatefulWidget {
  final bool isSubPage;
  const AdminInventoryScreen({super.key, this.isSubPage = false});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String searchQuery = '';
  String? selectedStockStatus;
  Set<String> selectedExpirations = {};
  String? selectedSortName;
  String? selectedSortPrice;

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // predefined categories and expiration filters for the sidebar
  final List<String> categories = [
    'Recently Added', 'Beverages', 'Liquor & Tobacco', 'Snacks & Sweets',
    'Fresh & Prepared', 'Pantry Staples', 'Frozen Goods', 'Personal Care',
    'Household Care', 'Miscellaneous',
  ];

  List<String> get expirationChoices {
    final now = DateTime.now();
    final List<String> months = [];
    final List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add('${monthNames[date.month - 1]} ${date.year}');
    }
    return months;
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isRecentlyAdded = selectedCategory == 'Recently Added';
    final categoryParam = isRecentlyAdded ? '' : selectedCategory;

    String sortName = selectedSortName ?? '';
    String sortPrice = '';
    if (selectedSortPrice == 'Price-Asc')  sortPrice = 'asc';
    if (selectedSortPrice == 'Price-Desc') sortPrice = 'desc';

    String stockStatus = selectedStockStatus ?? '';
    String expirationFilter = selectedExpirations.join(',');

    final result = await InventoryService.getProducts(
      search: searchQuery,
      category: categoryParam,
      stockStatus: stockStatus,
      expirationFilter: expirationFilter,
      sortName: sortName,
      sortPrice: sortPrice,
      recentlyAdded: isRecentlyAdded,
      all: true, // admin sees all products without pagination
    );

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _products = (result['products'] as List)
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final result = await InventoryService.deleteProduct(productId);
    if (!mounted) return;

    if (result['success']) {
      setState(
        () => _products.removeWhere((p) => p['product_id'] == productId),
      );
      _showActionSuccess("Product deleted successfully!");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to delete product'),
        ),
      );
    }
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
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkTeal,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 120, height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35524A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'Out of Stock':
        return 'No Stock';
      case 'Low Stock':
        return 'Low Stock';
      case 'In Stock':
        return 'In Stock';
      default:
        return status ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    Widget mainContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _fetchProducts();
                    },
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.black26, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.search, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: const Icon(Icons.tune, color: Colors.black, size: 28),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    _fetchProducts();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2F3E46)
                          : const Color(0xFF9E9E9E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Colors.black12),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : _products.isEmpty
              ? const Center(child: Text('No products found'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final statusLabel = _getStatusLabel(
                      product['stock_status'],
                    );
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminProductDetailScreen(
                              productList: _products,
                              initialIndex: index,
                            ),
                          );
                          _fetchProducts(); // refresh after returning from detail
                        },
                        child: Dismissible(
                          key: Key(product['product_id'].toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            // show confirmation before deleting
                            bool confirmed = false;
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Product?"),
                                content: Text("Remove ${product['product_name']}?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                  TextButton(
                                    onPressed: () { confirmed = true; Navigator.pop(ctx); },
                                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            return confirmed;
                          },
                          onDismissed: (dir) => _deleteProduct(product['product_id']),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15)),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product['product_name'] ?? '',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF2F3E46)),
                                      ),
                                    ),
                                    Text(
                                      product['category_name'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black45,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      // show pending approval badge for unapproved products
                                      if (product['is_approved'] == false || product['is_approved'] == 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                                            child: Text('Pending Approval',
                                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange.shade800),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatusTag(statusLabel),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // sidebar filter — same structure as staff_inventory
      endDrawer: _buildFilterSidebar(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E8B7F), Color(0xFF35524A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 22, backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                const SizedBox(width: 15),
                Text(
                  'Inventory',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: mainContent,
            ),
          ),
        ],
      ),
    );
  }

  // sidebar filter
  Widget _buildFilterSidebar() {
    Set<String> tempCategories = Set.from(selectedCategories);
    String? tempStockStatus = selectedStockStatus;
    Set<String> tempExpirations = Set.from(selectedExpirations);
    String? tempSortName = selectedSortName;
    String? tempSortPrice = selectedSortPrice;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
      ),
      child: StatefulBuilder(
        builder: (context, setDrawerState) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filters", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF35524A))),
                      TextButton(
                        onPressed: () {
                          setDrawerState(() {
                            tempCategories = {'Recently Added'};
                            tempStockStatus = null;
                            tempExpirations = {};
                            tempSortName = null;
                            tempSortPrice = null;
                          });
                        },
                        child: Text("Reset", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildExpansionChecklist(
                        'Categories',
                        categories,
                        tempCategories,
                        (cat) => setDrawerState(() {
                          if (tempCategories.contains(cat)) {
                            tempCategories.remove(cat);
                          } else {
                            tempCategories.add(cat);
                          }
                        }),
                      ),
                      const SizedBox(height: 10),
                      _buildFilterSectionTitle('Stock Status'),
                      _buildRadioOption('All', null, tempStockStatus, (val) => setDrawerState(() => tempStockStatus = val)),
                      _buildRadioOption('In Stock', 'In Stock', tempStockStatus, (val) => setDrawerState(() => tempStockStatus = val)),
                      _buildRadioOption('Low Stock', 'Low Stock', tempStockStatus, (val) => setDrawerState(() => tempStockStatus = val)),
                      _buildRadioOption('Out of Stock', 'Out of Stock', tempStockStatus, (val) => setDrawerState(() => tempStockStatus = val)),
                      const SizedBox(height: 10),
                      _buildExpansionChecklist(
                        'Expiration Date',
                        expirationChoices,
                        tempExpirations,
                        (choice) => setDrawerState(() {
                          if (tempExpirations.contains(choice)) {
                            tempExpirations.remove(choice);
                          } else {
                            tempExpirations.add(choice);
                          }
                        }),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      _buildFilterSectionTitle('Sort Alphabetically'),
                      _buildRadioOption('None', null, tempSortName, (val) => setDrawerState(() => tempSortName = val)),
                      _buildRadioOption('A-Z', 'A-Z', tempSortName, (val) => setDrawerState(() => tempSortName = val)),
                      _buildRadioOption('Z-A', 'Z-A', tempSortName, (val) => setDrawerState(() => tempSortName = val)),
                      const SizedBox(height: 15),
                      _buildFilterSectionTitle('Sort by Price'),
                      _buildRadioOption('None', null, tempSortPrice, (val) => setDrawerState(() => tempSortPrice = val)),
                      _buildRadioOption('Ascending', 'Price-Asc', tempSortPrice, (val) => setDrawerState(() => tempSortPrice = val)),
                      _buildRadioOption('Descending', 'Price-Desc', tempSortPrice, (val) => setDrawerState(() => tempSortPrice = val)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategories = tempCategories;
                          selectedStockStatus = tempStockStatus;
                          selectedExpirations = tempExpirations;
                          selectedSortName = tempSortName;
                          selectedSortPrice = tempSortPrice;
                        });
                        _fetchProducts();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35524A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Apply Filters', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF35524A))),
  );

  Widget _buildExpansionChecklist(String title, List<String> options, Set<String> selectedValues, Function(String) onToggle) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF35524A))),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 10),
        children: options.map((opt) => CheckboxListTile(
          value: selectedValues.contains(opt),
          onChanged: (value) => onToggle(opt),
          title: Text(opt, style: GoogleFonts.poppins(fontSize: 14,
            color: selectedValues.contains(opt) ? const Color(0xFF2F3E46) : Colors.black54,
            fontWeight: selectedValues.contains(opt) ? FontWeight.bold : FontWeight.w500)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF35524A),
          dense: true,
        )).toList(),
      ),
    );
  }

  Widget _buildRadioOption(String label, String? value, String? groupValue, Function(String?) onChanged, {bool isSortPrice = false}) {
    return RadioListTile<String?>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label, style: GoogleFonts.poppins(fontSize: 15,
        color: groupValue == value ? const Color(0xFF2F3E46) : Colors.black54,
        fontWeight: groupValue == value ? FontWeight.bold : FontWeight.w500)),
      activeColor: const Color(0xFF35524A),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor = status == 'In Stock'
        ? const Color(0xFF2D936C)
        : (status == 'Low Stock'
              ? const Color(0xFFF2A65A)
              : const Color(0xFFEF5350));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
