import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/inventory_service.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productList;
  final int initialIndex;

  const AdminProductDetailScreen({
    super.key,
    required this.productList,
    required this.initialIndex,
  });

  @override
  State<AdminProductDetailScreen> createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  late int _currentIndex;
  bool _isMarkupEditing = false;
  bool _isSavingMarkup = false;

  // replaced hardcoded list with a free-form text controller
  // admin can enter any markup percentage
  final TextEditingController _markupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadProductData();
  }

  @override
  void dispose() {
    _markupController.dispose();
    super.dispose();
  }

  void _loadProductData() {
    final product = widget.productList[_currentIndex];
    // load existing markup_price into the text field
    final existingMarkup = double.tryParse(product['markup_price']?.toString() ?? '0') ?? 0;
    _markupController.text = existingMarkup == 0 ? '' : existingMarkup.toStringAsFixed(0);
  }

  void _navigate(int direction) {
    setState(() {
      _isMarkupEditing = false;
      _currentIndex = (_currentIndex + direction) % widget.productList.length;
      if (_currentIndex < 0) _currentIndex = widget.productList.length - 1;
      _loadProductData();
    });
  }

  // markup amount = base_price * markup_percentage / 100
  double get _markupPercent => double.tryParse(_markupController.text) ?? 0;

  double get _calculatedMarkupAmount {
    final p = widget.productList[_currentIndex];
    final double base = double.tryParse(p['base_price']?.toString() ?? '0') ?? 0;
    return (base * _markupPercent / 100).ceilToDouble();
  }

  double get _retailPrice {
    final p = widget.productList[_currentIndex];
    final double base = double.tryParse(p['base_price']?.toString() ?? '0') ?? 0;
    return (base * (1 + _markupPercent / 100)).ceilToDouble();
  }

  // save markup via PUT /api/inventory/:id - also approves the product
  Future<void> _saveMarkup() async {
    final percent = double.tryParse(_markupController.text);
    if (percent == null || percent < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid markup percentage')),
      );
      return;
    }

    setState(() => _isSavingMarkup = true);

    final product = widget.productList[_currentIndex];
    final result = await InventoryService.updateProduct(
      productId: product['product_id'],
      markupPrice: percent,
    );

    if (!mounted) return;
    setState(() => _isSavingMarkup = false);

    if (result['success']) {
      // update local product data so retail price recalculates immediately without refetch
      widget.productList[_currentIndex]['markup_price'] = percent;
      widget.productList[_currentIndex]['is_approved'] = true;
      setState(() => _isMarkupEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Markup updated. Product approved for sale.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update markup')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = widget.productList[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // header — unchanged styling
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            color: const Color(0xFF3E5C51),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(Icons.keyboard_return, () => Navigator.pop(context)),
                    Row(
                      children: [
                        _circleBtn(Icons.arrow_back, () => _navigate(-1)),
                        const SizedBox(width: 10),
                        _circleBtn(Icons.arrow_forward, () => _navigate(1)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Text(currentProduct['product_name'] ?? '',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(height: 1, width: 200, color: Colors.white38),
                const SizedBox(height: 8),
                Text(currentProduct['category_name'] ?? '',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Retail Price",
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                      // retail price updates live as markup is typed
                      Text("₱ ${_retailPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Description"),
                  const Divider(thickness: 1, height: 10),
                  const SizedBox(height: 8),
                  Text(currentProduct['description'] ?? "No description available.",
                    style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 25),
                  _readOnlyTile(Icons.badge_outlined, "Product ID", currentProduct['product_id'].toString()),
                  _readOnlyTile(Icons.sell_outlined, "Base Price",
                    "₱ ${double.tryParse(currentProduct['base_price']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}"),
                  // unit measurement now shown — was missing before
                  if ((currentProduct['unit_measurement']?.toString() ?? '').isNotEmpty)
                    _readOnlyTile(Icons.straighten_outlined, "Unit Measurement",
                      currentProduct['unit_measurement'].toString()),
                  _readOnlyTile(Icons.inventory_2_outlined, "Available Stocks",
                    (currentProduct['stock_quantity'] ?? 0).toString()),
                  _readOnlyTile(Icons.calendar_month_outlined, "Expiration Date",
                    currentProduct['spoilage_date']?.toString() ?? "n/a"),
                  const SizedBox(height: 10),

                  // markup card — now uses free-form text field instead of dropdown
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isMarkupEditing ? const Color(0xFF3E5C51) : Colors.black12,
                        width: _isMarkupEditing ? 2 : 1,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Markup:",
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51)),
                            ),
                            Row(
                              children: [
                                _isMarkupEditing
                                  // free-form markup input — admin types any percentage
                                  ? SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: _markupController,
                                        keyboardType: TextInputType.number,
                                        autofocus: true,
                                        onChanged: (_) => setState(() {}), // live retail price update
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51), fontSize: 16),
                                        decoration: InputDecoration(
                                          suffixText: '%',
                                          filled: true,
                                          fillColor: const Color(0xFFF1F1F1),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _markupPercent > 0
                                        ? "${_markupPercent.toStringAsFixed(0)}% (₱ ${_calculatedMarkupAmount.toStringAsFixed(0)})"
                                        : "Not set",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16, fontWeight: FontWeight.bold,
                                        color: _markupPercent > 0 ? Colors.black87 : Colors.orange,
                                      ),
                                    ),
                                const SizedBox(width: 10),
                                // edit/confirm button
                                _isSavingMarkup
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3E5C51)))
                                  : GestureDetector(
                                      onTap: () {
                                        if (_isMarkupEditing) {
                                          _saveMarkup(); // confirm saves to backend
                                        } else {
                                          setState(() => _isMarkupEditing = true);
                                        }
                                      },
                                      child: Icon(
                                        _isMarkupEditing ? Icons.check_circle : Icons.edit,
                                        size: 22,
                                        color: _isMarkupEditing ? const Color(0xFF2D936C) : Colors.black38,
                                      ),
                                    ),
                                // cancel button — only shown while editing
                                if (_isMarkupEditing) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      _loadProductData(); // reset to original value
                                      setState(() => _isMarkupEditing = false);
                                    },
                                    child: const Icon(Icons.close, size: 22, color: Colors.redAccent),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        // approval status note
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              (currentProduct['is_approved'] == true || currentProduct['is_approved'] == 1)
                                ? Icons.check_circle_outline : Icons.pending_outlined,
                              size: 14,
                              color: (currentProduct['is_approved'] == true || currentProduct['is_approved'] == 1)
                                ? const Color(0xFF2D936C) : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (currentProduct['is_approved'] == true || currentProduct['is_approved'] == 1)
                                ? "Approved — visible to cashier"
                                : "Pending — set markup to approve",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: (currentProduct['is_approved'] == true || currentProduct['is_approved'] == 1)
                                  ? const Color(0xFF2D936C) : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: const Color(0xFF3E5C51)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51))),
          ]),
          const Divider(thickness: 1, height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) =>
    Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51)));

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF3E5C51), size: 20),
      ),
    );
  }
}