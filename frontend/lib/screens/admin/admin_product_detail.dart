import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productList;
  final int initialIndex;

  const AdminProductDetailScreen({
    super.key, 
    required this.productList, 
    required this.initialIndex
  });

  @override
  State<AdminProductDetailScreen> createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  late int _currentIndex;
  bool _isMarkupEditing = false;
  late TextEditingController _markupController;
  final FocusNode _markupFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadProductData();
  }

  void _loadProductData() {
    // casual check for markup in your data map
    double markup = widget.productList[_currentIndex]['markup'] ?? 0.0;
    _markupController = TextEditingController(text: markup.toStringAsFixed(2));
  }

  void _navigate(int direction) {
    setState(() {
      _isMarkupEditing = false; 
      _currentIndex = (_currentIndex + direction) % widget.productList.length;
      if (_currentIndex < 0) _currentIndex = widget.productList.length - 1;
      _loadProductData();
    });
  }

  double get _retailPrice {
    final p = widget.productList[_currentIndex];
    // supports both 'basePrice' and 'price' keys
    double base = (p['basePrice'] ?? p['price'] ?? 0.0).toDouble();
    double markup = double.tryParse(_markupController.text) ?? 0.0;
    return base + markup;
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = widget.productList[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // dark teal header
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
                    )
                  ],
                ),
                const SizedBox(height: 35),
                Text(currentProduct['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(height: 1, width: 200, color: Colors.white38),
                const SizedBox(height: 8),
                Text(currentProduct['category'], style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Retail Price", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                      Text("₱ ${_retailPrice.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // product body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Description"),
                  const Divider(thickness: 1, height: 10),
                  const SizedBox(height: 8),
                  Text(currentProduct['description'] ?? "no description available.", style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 25),
                  _readOnlyTile(Icons.badge_outlined, "Product Number / ID", currentProduct['id'].toString()),
                  _readOnlyTile(Icons.sell_outlined, "Base Price", "₱ ${(currentProduct['basePrice'] ?? currentProduct['price'] ?? 0.0).toStringAsFixed(2)}"),
                  _readOnlyTile(Icons.inventory_2_outlined, "Available Stocks", (currentProduct['stocks'] ?? 0).toString()),
                  _readOnlyTile(Icons.calendar_month_outlined, "Expiration Date", currentProduct['expiry'] ?? "n/a"),
                  const SizedBox(height: 10),
                  // markup editor card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isMarkupEditing ? const Color(0xFF3E5C51) : Colors.black12, width: _isMarkupEditing ? 2 : 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Markup Price:", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51))),
                        Row(
                          children: [
                            Text("₱ ", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                            SizedBox(
                              width: 85,
                              child: TextField(
                                controller: _markupController,
                                focusNode: _markupFocusNode,
                                enabled: _isMarkupEditing,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: _isMarkupEditing ? const Color(0xFF3E5C51) : Colors.black87),
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMarkupEditing = !_isMarkupEditing;
                                  if (_isMarkupEditing) {
                                    _markupFocusNode.requestFocus();
                                  } else {
                                    widget.productList[_currentIndex]['markup'] = double.tryParse(_markupController.text) ?? 0.0;
                                    _markupFocusNode.unfocus();
                                  }
                                });
                              },
                              child: Icon(_isMarkupEditing ? Icons.check_circle : Icons.edit, size: 22, color: _isMarkupEditing ? const Color(0xFF3E5C51) : Colors.black38),
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
          Row(children: [Icon(icon, size: 20, color: const Color(0xFF3E5C51)), const SizedBox(width: 8), Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51)))]),
          const Divider(thickness: 1, height: 12),
          Padding(padding: const EdgeInsets.only(left: 4, top: 2), child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3E5C51)));

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF3E5C51), size: 20)),
    );
  }
}