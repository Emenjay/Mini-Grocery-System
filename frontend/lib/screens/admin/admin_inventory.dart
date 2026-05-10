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
  Set<String> selectedCategories = {'Recently Added'};
  String searchQuery = '';
  Set<String> selectedStockStatuses = {};
  Set<String> selectedExpirationFilters = {};
  String? selectedSort;

  // backend data state
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> categories = [
    'Recently Added', 'Beverages', 'Liquor & Tobacco', 'Snacks & Sweets',
    'Fresh Foods', 'Prepared Foods', 'Frozen Goods', 'Personal Care',
    'Household Care', 'Miscellaneous',
  ];

  final List<String> expirationChoices = [
    'Expired', 'Exipiring Soon', 'Not Expiring Soon',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // fetch all products from backend — admin sees all products including unapproved
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isRecentlyAdded = selectedCategories.contains('Recently Added');
    final categoryParam = isRecentlyAdded ? '' : selectedCategories.first;

    // map sort state to backend sort params
    String sortName = '';
    String sortPrice = '';
    if (selectedSort == 'A-Z')        sortName = 'A-Z';
    if (selectedSort == 'Z-A')        sortName = 'Z-A';
    if (selectedSort == 'Price-Asc')  sortPrice = 'asc';
    if (selectedSort == 'Price-Desc') sortPrice = 'desc';

    // map stock status filter to backend expected value
    String stockStatus = '';
    if (selectedStockStatuses.isNotEmpty) {
      stockStatus = selectedStockStatuses.first;
    }

    final result = await InventoryService.getProducts(
      search: searchQuery,
      category: categoryParam,
      stockStatus: stockStatus,
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

  // delete product via backend then remove from local list on success
  Future<void> _deleteProduct(int productId) async {
    final result = await InventoryService.deleteProduct(productId);
    if (!mounted) return;

    if (result['success']) {
      setState(() => _products.removeWhere((p) => p['product_id'] == productId));
      _showActionSuccess("Product deleted successfully!");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to delete product')),
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
              Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 120, height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35524A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("OK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // map backend stock_status to display label
  String _getStatusLabel(String? status) {
    switch (status) {
      case 'Out of Stock': return 'No Stock';
      case 'Low Stock':    return 'Low Stock';
      case 'In Stock':     return 'In Stock';
      default:             return status ?? 'Unknown';
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
                      _fetchProducts(); // re-fetch with updated search
                    },
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
              final isSelected = selectedCategories.contains(cat);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedCategories = {cat});
                    _fetchProducts(); // re-fetch when category changes
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2F3E46) : const Color(0xFF9E9E9E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat,
                      style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      )),
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
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
              : _products.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final statusLabel = _getStatusLabel(product['stock_status']);
                      return GestureDetector(
                        onTap: () async {
                          // navigate to detail screen and refresh on return in case markup was updated
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminProductDetailScreen(
                                productList: _products,
                                initialIndex: index,
                              ),
                            ),
                          );
                          _fetchProducts(); // refresh after returning from detail
                        },
                        child: Dismissible(
                          key: Key(product['product_id'].toString()),
                          direction: DismissDirection.endToStart,
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
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
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
                                      Text(product['category_name'] ?? '',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45, fontStyle: FontStyle.italic),
                                      ),
                                      // show unapproved badge so admin knows which products need markup
                                      if (product['is_approved'] == false || product['is_approved'] == 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text('Pending Approval',
                                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange.shade800),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.arrow_forward, size: 16, color: Colors.black45),
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
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                const SizedBox(width: 15),
                Text('Inventory',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600),
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

  Widget _buildFilterSidebar() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 60, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filters", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF35524A))),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategories = {'Recently Added'};
                      selectedStockStatuses = {};
                      selectedExpirationFilters = {};
                      selectedSort = null;
                    });
                    _fetchProducts();
                  },
                  child: Text("Reset", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildExpansionTile("Categories", children: [
                  ...categories.map((cat) => _buildDrawerLink(
                    cat,
                    isSelected: selectedCategories.contains(cat),
                    onTap: () {
                      setState(() => selectedCategories = {cat});
                      Navigator.pop(context);
                      _fetchProducts();
                    },
                  )),
                ]),
                _buildExpansionTile("Stock Status", children: [
                  _buildDrawerLink("In Stock",    isSelected: selectedStockStatuses.contains("In Stock"),    onTap: () => setState(() => selectedStockStatuses = {"In Stock"})),
                  _buildDrawerLink("Low Stock",   isSelected: selectedStockStatuses.contains("Low Stock"),   onTap: () => setState(() => selectedStockStatuses = {"Low Stock"})),
                  _buildDrawerLink("Out of Stock",isSelected: selectedStockStatuses.contains("Out of Stock"),onTap: () => setState(() => selectedStockStatuses = {"Out of Stock"})),
                ]),
                _buildExpansionTile("Expiration Date", children: [
                  ...expirationChoices.map((choice) => _buildDrawerLink(
                    choice,
                    isSelected: selectedExpirationFilters.contains(choice),
                    onTap: () => setState(() => selectedExpirationFilters = {choice}),
                  )),
                ]),
                const Divider(height: 40, thickness: 1, indent: 15, endIndent: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("Alphabetical Sort", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF35524A))),
                ),
                _buildSortRadio("A - Z", "A-Z"),
                _buildSortRadio("Z - A", "Z-A"),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("Price Sort", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF35524A))),
                ),
                _buildSortRadio("None", null),
                _buildSortRadio("Ascending",  "Price-Asc"),
                _buildSortRadio("Descending", "Price-Desc"),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRadio(String title, String? value) {
    return RadioListTile<String?>(
      title: Text(title, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 15)),
      value: value,
      groupValue: selectedSort,
      activeColor: const Color(0xFF35524A),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      onChanged: (val) {
        setState(() => selectedSort = val);
        _fetchProducts();
      },
    );
  }

  Widget _buildExpansionTile(String title, {required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: GoogleFonts.poppins(color: const Color(0xFF35524A), fontWeight: FontWeight.bold)),
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
        child: Text(text,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFF35524A) : Colors.black54,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
          )),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor = status == 'In Stock'
        ? const Color(0xFF2D936C)
        : (status == 'Low Stock' ? const Color(0xFFF2A65A) : const Color(0xFFEF5350));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}