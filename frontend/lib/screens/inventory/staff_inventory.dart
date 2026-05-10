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

// This screen is for staff users to view and manage inventory. It includes search, filters, pagination, and product cards with swipe-to-delete functionality.
class _InventoryStaffScreenState extends State<InventoryStaffScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchQuery = '';
  int currentPage = 1;
  final int itemsPerPage = 4;

  // original filter states
  String selectedCategory = 'Recently Added';
  String activeStockFilter = '';
  String activeExpiryFilter = '';
  String activeSortAlpha = 'A-Z';
  String activeSortPrice = 'None';

  // logic for dashboard navigation
  bool _hasInitialFilterApplied = false;

  // data states
  List<Map<String, dynamic>> _products = [];
  int _totalPages = 1;
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // don't treat as recentlyAdded if any filter is active
    final bool isRecentlyAdded =
        selectedCategory == 'Recently Added' &&
        activeStockFilter.isEmpty &&
        activeExpiryFilter.isEmpty &&
        searchQuery.isEmpty &&
        activeSortPrice == 'None';

    final String categoryParam =
        (isRecentlyAdded || selectedCategory == 'Recently Added')
        ? ''
        : selectedCategory;

    // fix stock status mapping
    String stockStatusParam = '';
    if (activeStockFilter == 'Available') {
      stockStatusParam = 'In Stock';
    } else if (activeStockFilter == 'Out of Stock') {
      stockStatusParam = 'Out of Stock';
    } else if (activeStockFilter == 'Low Stock') {
      stockStatusParam = 'Low Stock';
    }

    final result = await ProductService.getAllProducts(
      search: searchQuery,
      category: categoryParam,
      stockStatus: stockStatusParam,
      expirationFilter: activeExpiryFilter,
      sortName: activeSortAlpha == 'A-Z'
          ? 'A-Z'
          : activeSortAlpha == 'Z-A'
          ? 'Z-A'
          : '',
      sortPrice: activeSortPrice == 'Ascending'
          ? 'asc'
          : activeSortPrice == 'Descending'
          ? 'desc'
          : '',
      page: currentPage,
      limit: itemsPerPage,
      recentlyAdded: isRecentlyAdded,
    );

    if (!mounted) return;
    if (result['success']) {
      final data = result['data'];
      setState(() {
        _products = List<Map<String, dynamic>>.from(data['products'] ?? []);
        _totalPages = data['pagination']?['totalPages'] ?? 1;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'];
        _isLoading = false;
      });
    }
  }

  // lifecycle methods
  @override
  void initState() {
    super.initState();
  }

  // apply initial filter from dashboard navigation only once
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialFilterApplied) {
      _hasInitialFilterApplied = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        if (args == 'All') {
          activeStockFilter = '';
          selectedCategory = 'Recently Added';
        } else if (args == 'Low Stock') {
          activeStockFilter = 'Low Stock';
        } else if (args == 'No Stock') {
          activeStockFilter = 'Out of Stock'; // ← fixed
        } else if (args == 'Expired') {
          activeExpiryFilter = 'Expired';
        }
      }
      _fetchProducts();
    }
  }

  void _onFilterChanged({String? newCategory}) {
    if (newCategory != null) selectedCategory = newCategory;
    setState(() => currentPage = 1);
    _fetchProducts();
  }

  // API calls and filter/sort options
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

  final List<String> expirationMonths = [
    'May 2026',
    'June 2026',
    'July 2026',
    'August 2026',
    'September 2026',
    'October 2026',
    'November 2026',
    'December 2026',
  ];

  // UI components for filters, sorting, pagination, and product cards
  Widget _buildSortRadio(
    String title,
    String value,
    String groupValue,
    Function(String?) onChanged,
  ) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(color: Colors.black54, fontSize: 15),
      ),
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
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryDarkTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildDrawerLink(
    String text, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
            decoration: isSelected
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 60, 20, 20),
              child: Text(
                "Filters",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkTeal,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildExpansionTile(
                    "Categories",
                    children: [
                      ...categories.map(
                        (cat) => _buildDrawerLink(
                          cat,
                          isSelected: selectedCategory == cat,
                          onTap: () {
                            setState(() {
                              selectedCategory = cat;
                              currentPage = 1;
                              _fetchProducts();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildExpansionTile(
                    "Stock Status",
                    children: [
                      _buildDrawerLink(
                        "Available",
                        isSelected: activeStockFilter == "Available",
                        // Available
                        onTap: () {
                          setState(() => activeStockFilter = "Available");
                          _fetchProducts();
                        },
                      ),
                      _buildDrawerLink(
                        "Low Stock",
                        isSelected: activeStockFilter == "Low Stock",
                        // Low Stock
                        onTap: () {
                          setState(() => activeStockFilter = "Low Stock");
                          _fetchProducts();
                        },
                      ),
                      _buildDrawerLink(
                        "Out of Stock",
                        isSelected: activeStockFilter == "Out of Stock",
                        // Out of Stock
                        onTap: () {
                          setState(() => activeStockFilter = "Out of Stock");
                          _fetchProducts();
                        },
                      ),
                    ],
                  ),
                  _buildExpansionTile(
                    "Expiration Date",
                    children: [
                      ...expirationMonths.map(
                        (month) => _buildDrawerLink(
                          month,
                          isSelected: activeExpiryFilter == month,
                          // Expiry months
                          onTap: () {
                            setState(() => activeExpiryFilter = month);
                            _fetchProducts();
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 40,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      "Alphabetical Sort",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkTeal,
                      ),
                    ),
                  ),
                  // add this BEFORE A-Z radio
                  _buildSortRadio("None", "None", activeSortAlpha, (val) {
                    setState(() {
                      activeSortAlpha = val!;
                    });
                    _fetchProducts();
                  }),
                  _buildSortRadio("A - Z", "A-Z", activeSortAlpha, (val) {
                    setState(() {
                      activeSortAlpha = val!;
                      if (selectedCategory == 'Recently Added')
                        selectedCategory = '';
                    });
                    _fetchProducts();
                  }),
                  _buildSortRadio("Z - A", "Z-A", activeSortAlpha, (val) {
                    setState(() {
                      activeSortAlpha = val!;
                      if (selectedCategory == 'Recently Added')
                        selectedCategory = '';
                    });
                    _fetchProducts();
                  }),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      "Price Sort",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkTeal,
                      ),
                    ),
                  ),
                  _buildSortRadio("Ascending", "Ascending", activeSortPrice, (
                    val,
                  ) {
                    setState(() {
                      activeSortPrice = val!;
                      activeSortAlpha = 'None';
                      if (selectedCategory == 'Recently Added')
                        selectedCategory = '';
                    });
                    _fetchProducts();
                  }),
                  _buildSortRadio("Descending", "Descending", activeSortPrice, (
                    val,
                  ) {
                    setState(() {
                      activeSortPrice = val!;
                      activeSortAlpha = 'None';
                      if (selectedCategory == 'Recently Added')
                        selectedCategory = '';
                    });
                    _fetchProducts();
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (added == true) _fetchProducts();
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
                  _circleIcon(
                    Icons.keyboard_return,
                    () => Navigator.pop(context),
                  ),
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
                          setState(() {
                            searchQuery = val;
                            currentPage = 1;
                          });
                          _fetchProducts();
                        },
                        decoration: const InputDecoration(
                          hintText: "Search name or ID...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black26,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleIcon(Icons.search, () {}),
                  const SizedBox(width: 6),
                  _circleIcon(
                    Icons.tune,
                    () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
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
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          _onFilterChanged(newCategory: cat);
                        }
                      },
                      selectedColor: AppColors.primaryDarkTeal,
                      backgroundColor: AppColors.surfaceLightGray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24),
            if (_totalPages > 1) _buildPagination(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3E5C51),
                      ),
                    )
                  : _products.isEmpty
                  ? const Center(child: Text("No items found"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _products.length,
                      itemBuilder: (_, index) =>
                          _buildProductCard(_products, index),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(List<Map<String, dynamic>> list, int index) {
    final item = list[index];
    final name = item['product_name'] ?? item['name'] ?? '';
    final category = item['category_name'] ?? item['category'] ?? '';
    final id = item['product_id']?.toString() ?? item['id'] ?? '';
    final stocks = item['stock_quantity'] ?? item['stocks'] ?? 0;
    final status = item['stock_status'] ?? item['status'] ?? '';
    return Dismissible(
      key: Key(
        item['product_id']?.toString() ??
            item['id']?.toString() ??
            index.toString(),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _showDeleteConfirmation(context, item);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_forever_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productList: list, initialIndex: index),
          ),
        ),
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
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      item['category_name'] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      item['product_id']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF3E5C51),
                        fontWeight: FontWeight.bold,
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
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    () {
                      final raw = item['retail_price'];
                      if (raw != null) {
                        final price = double.tryParse(raw.toString()) ?? 0;
                        return '₱ ${price.toStringAsFixed(0)}';
                      }
                      return '';
                    }(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3E5C51),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['stock_quantity'] ?? 0} stocks',
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                  const SizedBox(height: 4),
                  _statusTag(item['stock_status'] ?? ''),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text("Remove ${item['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ProductService.deleteProduct(
                item['product_id'],
              );
              if (result['success']) {
                _fetchProducts();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to delete'),
                    ),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryDarkTeal),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageBtn(
          Icons.chevron_left,
          currentPage > 1
              ? () {
                  setState(() => currentPage--);
                  _fetchProducts();
                }
              : null,
        ),
        for (int i = 1; i <= _totalPages; i++)
          _pageNum(i.toString(), currentPage == i, _totalPages > 1, () {
            setState(() => currentPage = i);
            _fetchProducts();
          }),
        _pageBtn(
          Icons.chevron_right,
          currentPage < _totalPages
              ? () {
                  setState(() => currentPage++);
                  _fetchProducts();
                }
              : null,
        ),
      ],
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

  Widget _pageNum(
    String txt,
    bool active,
    bool interactive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFB2DFDB) : Colors.black12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          txt,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _statusTag(String status) {
    Color color = (status == 'In Stock' || status == 'Available')
        ? const Color(0xFF2D936C)
        : (status == 'Low Stock' ? Colors.orange : Colors.redAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
