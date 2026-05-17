// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../services/inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  // product IDs passed from PosScreen so greyed-out state
  // persists when the cashier re-opens inventory mid-transaction
  final Set<int> addedProductIds;
  const InventoryScreen({super.key, this.addedProductIds = const {}});

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
  String activeSortAlpha = '';
  String activeSortPrice = 'None';

  // backend data state
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // tracks which product_ids have been added to cart to grey out their button
  final Set<int> _addedProductIds = {};

  final List<String> categories = [
    'Recently Added', 'Beverages', 'Liquor & Tobacco', 'Snacks & Sweets',
    'Fresh & Prepared', 'Pantry Staples', 'Frozen Goods', 'Personal Care',
    'Household Care', 'Miscellaneous',
  ];

  // expiry filter options matching backend preset options
  final List<String> expiryFilters = [
    'Expired',
    'Expiring Soon',
    'Not Expiring Soon',
  ];

  @override
  void initState() {
    super.initState();
    // seed with IDs already in the POS cart so they show greyed out on re-open
    _addedProductIds.addAll(widget.addedProductIds);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isRecentlyAdded = selectedCategory == 'Recently Added';
    final categoryParam = isRecentlyAdded ? '' : selectedCategory;

    final result = await InventoryService.getCashierProducts(
      search: searchQuery,
      category: categoryParam,
    );

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _products = (result['products'] as List).map((p) => {
          'id': p['product_id'],
          'name': p['product_name'],
          'category': p['category_name'],
          // retail price computed by backend - cashier only sees final price
          'price': (p['retail_price'] ?? 0).toDouble(),
          'stock_quantity': p['stock_quantity'] ?? 0,
          'stock_status': p['stock_status'] ?? 'Out of Stock',
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  // filter and sort products locally since all are already fetched
  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> list = _products.where((p) {
      final matchesSearch = p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      // stock filter - hide out of stock products from cashier view
      final matchesStock = p['stock_status'] != 'Out of Stock';
      return matchesSearch && matchesStock;
    }).toList();

    // alphabetical sort
    if (activeSortAlpha == 'A-Z') {
      list.sort((a, b) => a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase()));
    } else if (activeSortAlpha == 'Z-A') {
      list.sort((a, b) => b['name'].toString().toLowerCase().compareTo(a['name'].toString().toLowerCase()));
    }

    // price sort
    if (activeSortPrice == 'Ascending') {
      list.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
    } else if (activeSortPrice == 'Descending') {
      list.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
    }

    return list;
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
                        _quantityBtn(Icons.add, () {
                          // prevent adding more than available stock
                          if (quantity < product['stock_quantity']) {
                            setDialogState(() => quantity++);
                          }
                        }),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _priceRow("Retail Price:", "₱ ${(product['price'] as double).toStringAsFixed(2)}"),
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
                              // mark product as added locally so the button greys out in the list
                              setState(() => _addedProductIds.add(product['id']));

                              // close the dialog first
                              Navigator.pop(context);

                              // then pop InventoryScreen itself back to PosScreen with the selected item
                              // PosScreen's _openInventory is awaiting this result
                              Navigator.pop(context, {
                                'product_id': product['id'],
                                'name': product['name'],
                                'price': product['price'],
                                'quantity': quantity,
                              });
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
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 60, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal),
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
                      });
                      _fetchProducts();
                    },
                    icon: const Icon(Icons.restart_alt, color: AppColors.primaryDarkTeal, size: 28),
                    tooltip: 'Reset filters',
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
                      isSelected: selectedCategory == cat,
                      onTap: () {
                        setState(() => selectedCategory = cat);
                        Navigator.pop(context);
                        _fetchProducts();
                      }
                    )),
                  ]),
                  _buildExpansionTile("Expiration Date", children: [
                    // preset options matching backend
                    ...expiryFilters.map((filter) => _buildDrawerLink(
                      filter,
                      isSelected: activeExpiryFilter == filter,
                      onTap: () => setState(() => activeExpiryFilter = filter),
                    )),
                  ]),

                  const Divider(height: 40, thickness: 1, indent: 15, endIndent: 15),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Alphabetical Sort", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  ),
                  _buildSortRadio("None", "", activeSortAlpha, (val) => setState(() => activeSortAlpha = val!)),
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
        actions: [const SizedBox.shrink()],
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_return,
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
                              onChanged: (v) {
                                setState(() => searchQuery = v);
                                // search filters locally since all products already fetched
                              },
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
                            onTap: () {
                              setState(() => selectedCategory = cat);
                              _fetchProducts();
                            },
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
                  // loading, error, empty, and product list states
                  Expanded(
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                        ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                        : filteredProducts.isEmpty
                          ? const Center(child: Text("No products found"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                // check if this product has already been added to cart
                                final isAdded = _addedProductIds.contains(product['id']);
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
                                                // show retail price only - base price and markup hidden from cashier
                                                Align(alignment: Alignment.bottomRight, child: Text('₱ ${(product['price'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // prevent adding already-added product again
                                            if (!isAdded) _showAddToCartDialog(product);
                                          },
                                          child: Container(
                                            width: 56,
                                            constraints: const BoxConstraints(minHeight: 70),
                                            decoration: BoxDecoration(
                                              // grey out button if already added
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