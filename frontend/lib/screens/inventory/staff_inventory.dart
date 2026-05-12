// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../services/inventory_service.dart';
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
  final int itemsPerPage = 20; // matches backend default limit

  // original filter states
  String selectedCategory = 'Recently Added';
  String activeStockFilter = '';
  String activeExpiryFilter = '';
  String activeSortAlpha = '';
  String activeSortPrice = 'None';

  // logic for dashboard navigation
  String? _lastArguments;

  // backend data state
  List<Map<String, dynamic>> _products = [];
  int _totalPages = 1;
  int _totalItems = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // initial fetch happens after didChangeDependencies sets filters
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != _lastArguments) {
      _lastArguments = args;

      // set all filters inside one setState so _fetchProducts gets correct values
      setState(() {
        selectedCategory = 'Recently Added';
        activeExpiryFilter = '';
        activeSortAlpha = '';
        activeSortPrice = 'None';
        currentPage = 1;

        // reset stock filter first, then apply from argument
        activeStockFilter = '';

        if (args == 'Low Stock') {
          activeStockFilter = 'Low Stock';
        } else if (args == 'No Stock') {
          activeStockFilter = 'No Stock'; // must match _mapStockFilter key exactly
        } else if (args == 'Expired') {
          activeExpiryFilter = 'Expired';
        }
        // 'All' and null just leave filters empty — show everything
      });

      _fetchProducts();
    }
  }

  // fetch products from backend with current filter/search/page state
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // map frontend filter values to backend expected values
    final stockStatusParam = _mapStockFilter(activeStockFilter);
    final expiryParam = _mapExpiryFilter(activeExpiryFilter);
    final sortNameParam = activeSortAlpha;
    final sortPriceParam = activeSortPrice == 'Ascending'
        ? 'asc'
        : activeSortPrice == 'Descending'
        ? 'desc'
        : '';
    final isRecentlyAdded = selectedCategory == 'Recently Added';
    final categoryParam = isRecentlyAdded ? '' : selectedCategory;

    final result = await InventoryService.getProducts(
      search: searchQuery,
      category: categoryParam,
      stockStatus: stockStatusParam,
      expirationFilter: expiryParam,
      sortName: sortNameParam,
      sortPrice: sortPriceParam,
      page: currentPage,
      limit: itemsPerPage,
      recentlyAdded: isRecentlyAdded,
    );

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        // map backend product fields to the format the UI expects
        _products = (result['products'] as List)
            .map(
              (p) => {
                'id': p['product_id'],
                'name': p['product_name'],
                'category': p['category_name'],
                'stocks': p['stock_quantity'] ?? 0,
                // map backend stock_status to frontend display values
                'status': _mapStockStatus(p['stock_status']),
                'basePrice': double.tryParse(p['base_price'].toString()) ?? 0.0,
                'markup': double.tryParse(p['markup_price'].toString()) ?? 0.0,
                'retailPrice': p['retail_price'] ?? 0,
                'spoilageDate': p['spoilage_date'],
                'lastUpdated': p['last_updated'],
                'description': p['description'] ?? '',
                'unitMeasurement': p['unit_measurement'] ?? '',
                'isfastmoving': p['isfastmoving'] ?? false,
                'isApproved': p['is_approved'] ?? false,
                'receivedDate': p['received_date'],
                'categoryId': p['category_id'],
              },
            )
            .toList();
        _totalPages = result['pagination']['totalPages'] ?? 1;
        _totalItems = result['pagination']['total'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  // map frontend stock filter label to backend expected value
  String _mapStockFilter(String filter) {
    switch (filter) {
      case 'Available':
        return 'In Stock';
      case 'Low Stock':
        return 'Low Stock';
      case 'No Stock':
        return 'Out of Stock';
      default:
        return '';
    }
  }

  // updated — month filters pass through as-is (YYYY-MM format)
  // preset keywords kept for any existing dashboard navigation
  String _mapExpiryFilter(String filter) {
    if (filter.isEmpty) return '';
    // if it looks like a month key, pass it straight to backend
    if (RegExp(r'^\d{4}-\d{2}$').hasMatch(filter)) return filter;
    // legacy preset mappings kept for dashboard navigation compatibility
    switch (filter) {
      case 'Expired': return 'Expired';
      case 'Expiring Soon': return 'Expiring Soon';
      case 'Not Expiring Soon': return 'Not Expiring Soon';
      default: return '';
    }
  }

  // map backend stock_status to frontend display label
  String _mapStockStatus(String? status) {
    switch (status) {
      case 'In Stock':
        return 'In Stock';
      case 'Low Stock':
        return 'Low Stock';
      case 'Out of Stock':
        return 'No Stock';
      default:
        return 'No Stock';
    }
  }

  // handle delete - calls backend then refreshes list
  Future<void> _deleteProduct(Map<String, dynamic> item) async {
    final result = await InventoryService.deleteProduct(item['id']);
    if (!mounted) return;

    if (result['success']) {
      _showSuccessModal();
      _fetchProducts(); // refresh list after deletion
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to delete product'),
        ),
      );
    }
  }

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

  // expiry filter options matching backend preset options
  // generates the next 12 months dynamically from current month
  List<String> get _expiryMonthFilters {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final month = DateTime(now.year, now.month + i);
      // format as YYYY-MM for backend, display as Month YYYY
      return '${month.year}-${month.month.toString().padLeft(2, '0')}';
    });
  }

  // helper to display month filter as readable label (e.g. '2026-05' -> 'May 2026')
  String _formatMonthLabel(String yearMonth) {
    final parts = yearMonth.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  // sidebar builders
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
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 60, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkTeal,
                    ),
                  ),
                  // reset all filters button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Recently Added';
                        activeStockFilter = '';
                        activeExpiryFilter = '';
                        activeSortAlpha = '';
                        activeSortPrice = 'None';
                        currentPage = 1;
                      });
                      _fetchProducts(); // refetch with cleared filters
                    },
                    icon: const Icon(
                      Icons.restart_alt,
                      color: AppColors.primaryDarkTeal,
                      size: 28,
                    ),
                    tooltip: 'Reset filters',
                  ),
                ],
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
                            });
                            Navigator.pop(context);
                            _fetchProducts(); // refetch when category changes in drawer
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
                        onTap: () {
                          setState(() {
                            activeStockFilter = "Available";
                            currentPage = 1;
                          });
                          _fetchProducts();
                        },
                      ),
                      _buildDrawerLink(
                        "Low Stock",
                        isSelected: activeStockFilter == "Low Stock",
                        onTap: () {
                          setState(() {
                            activeStockFilter = "Low Stock";
                            currentPage = 1;
                          });
                          _fetchProducts();
                        },
                      ),
                      _buildDrawerLink(
                        "No Stock",
                        isSelected: activeStockFilter == "No Stock",
                        onTap: () {
                          setState(() {
                            activeStockFilter = "No Stock";
                            currentPage = 1;
                          });
                          _fetchProducts();
                        },
                      ),
                    ],
                  ),
                  _buildExpansionTile("Expiration Month", children: [
                    // dynamically generated months instead of hardcoded presets
                    ..._expiryMonthFilters.map((monthKey) => _buildDrawerLink(
                      _formatMonthLabel(monthKey), // display as 'May 2026'
                      isSelected: activeExpiryFilter == monthKey,
                      onTap: () {
                        setState(() { activeExpiryFilter = monthKey; currentPage = 1; });
                        _fetchProducts();
                      }
                    )),
                  ]),
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
                  _buildSortRadio("A - Z", "A-Z", activeSortAlpha, (val) {
                    setState(() {
                      activeSortAlpha = val!;
                      currentPage = 1;
                    });
                    _fetchProducts();
                  }),
                  _buildSortRadio("Z - A", "Z-A", activeSortAlpha, (val) {
                    setState(() {
                      activeSortAlpha = val!;
                      currentPage = 1;
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
                  _buildSortRadio("None", "None", activeSortPrice, (val) {
                    setState(() {
                      activeSortPrice = val!;
                      currentPage = 1;
                    });
                    _fetchProducts();
                  }),
                  _buildSortRadio("Ascending", "Ascending", activeSortPrice, (
                    val,
                  ) {
                    setState(() {
                      activeSortPrice = val!;
                      currentPage = 1;
                    });
                    _fetchProducts();
                  }),
                  _buildSortRadio("Descending", "Descending", activeSortPrice, (
                    val,
                  ) {
                    setState(() {
                      activeSortPrice = val!;
                      currentPage = 1;
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
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            ).then(
              (_) => _fetchProducts(),
            ), // refresh list when returning from add product
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
                          // fetch from backend on search change
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
                  _circleIcon(Icons.search, () => _fetchProducts()),
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
                          setState(() {
                            selectedCategory = cat;
                            currentPage = 1;
                          });
                          _fetchProducts(); // refetch when category chip changes
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
            // show pagination only if there are multiple pages
            if (_totalPages > 1) _buildPagination(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    ) // loading state
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ) // error state
                  : _products.isEmpty
                  ? const Center(child: Text("No items found")) // empty state
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) =>
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
    return Dismissible(
      key: Key(item['id'].toString()), // use backend product_id as key
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
        onTap: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productList: list, initialIndex: index),
              ),
            ).then(
              (_) => _fetchProducts(),
            ), // refresh after returning from product detail
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
                    // display name and unit measurement together if unit exists
                    Text(
                      item['unitMeasurement'] != null && item['unitMeasurement'].toString().isNotEmpty
                          ? '${item['name']} ${item['unitMeasurement']}'
                          : item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      item['category'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    // show product_id from backend
                    Text(
                      'ID: ${item['id']}',
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
                    "${item['stocks']} stocks",
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                  const SizedBox(height: 4),
                  _statusTag(item['status']),
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
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(item); // call backend delete then refresh
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF2D936C),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Deletion Successful",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "The item has been removed from inventory.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
