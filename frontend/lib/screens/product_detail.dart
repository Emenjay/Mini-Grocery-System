import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _basePriceController;
  late TextEditingController _stocksController;
  
  DateTime? _selectedExpirationDate;
  String? _selectedCategory;

  final List<String> categories = [
    'Beverages', 'Liquor & Tobacco', 'Snacks & Sweets', 'Fresh & Prepared',
    'Pantry Staples', 'Frozen Goods', 'Personal Care', 'Household Care', 'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descController = TextEditingController(text: "Nourishing Lotion with Cocoa Extract and Vitamin E. Wonderful extract with papaya tidbits and peanut butter.");
    _basePriceController = TextEditingController(text: "150.00");
    _stocksController = TextEditingController(text: widget.product['stocks'].toString());
    _selectedCategory = widget.product['category'];
    _selectedExpirationDate = DateTime(2028, 8, 2);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedExpirationDate = picked; // Updates the UI with the chosen date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- Dark Green Header ---
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
                        _circleBtn(Icons.arrow_back, () {}),
                        const SizedBox(width: 10),
                        _circleBtn(Icons.arrow_forward, () {}),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 35),
                if (!isEditing) ...[
                  Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white38, thickness: 1, endIndent: 100),
                  Text(_selectedCategory ?? "", style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic)),
                ] else ...[
                  _headerInput("Product Name", _nameController),
                  const SizedBox(height: 10),
                  // Fixed Category Dropdown
                  _headerDropdown(),
                ],
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Retail Price", style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                      const Text("₱ 170.00", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => isEditing = !isEditing),
                    icon: Icon(isEditing ? Icons.check_circle : Icons.edit, size: 16),
                    label: Text(isEditing ? "Confirm Changes" : "Edit Product"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D936C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                )
              ],
            ),
          ),

          // --- Body ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Description"),
                  const Divider(thickness: 1, height: 10),
                  const SizedBox(height: 10),
                  isEditing 
                    ? _editBox(_descController, maxLines: 4)
                    : Text(_descController.text, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
                  
                  const SizedBox(height: 30),
                  _infoTile(Icons.badge_outlined, "Product Number / ID", widget.product['id'], editable: false),
                  
                  // Base Price with Peso sign
                  _infoTile(Icons.sell_outlined, "Base Price", "₱ ${_basePriceController.text}", 
                    controller: _basePriceController, isEditing: isEditing, isPrice: true),
                  
                  _infoTile(Icons.inventory_2_outlined, "Available Stocks", _stocksController.text, 
                    controller: _stocksController, isEditing: isEditing),
                  
                  // Expiration Date with Calendar Logic
                  _infoTile(Icons.calendar_month_outlined, "Expiration Date", 
                    DateFormat('MMMM d, yyyy').format(_selectedExpirationDate!), 
                    isEditing: isEditing, onDateTap: _pickDate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDropdown() {
    return Container(
      height: 45,
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: categories.contains(_selectedCategory) ? _selectedCategory : null,
          hint: const Text("Choose Category", style: TextStyle(fontSize: 14, color: Colors.black54)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black26),
          items: categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {bool isEditing = false, bool editable = true, bool isPrice = false, TextEditingController? controller, VoidCallback? onDateTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF3E5C51)),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF3E5C51))),
            ],
          ),
          const Divider(thickness: 1, height: 15),
          const SizedBox(height: 5),
          if (isEditing && editable)
            onDateTap != null 
              ? GestureDetector(
                  onTap: onDateTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: Colors.black12.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MM/dd/yyyy').format(_selectedExpirationDate!), style: const TextStyle(fontSize: 14)),
                        const Icon(Icons.calendar_month, color: Colors.black26, size: 20),
                      ],
                    ),
                  ),
                )
              : _editBox(controller!, isPrice: isPrice)
          else
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black54)),
            ),
        ],
      ),
    );
  }

  Widget _editBox(TextEditingController controller, {int maxLines = 1, bool isPrice = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.black12.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPrice ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixText: isPrice ? "₱ " : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _headerInput(String hint, TextEditingController controller) {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF3E5C51)));
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF3E5C51), size: 22),
      ),
    );
  }
}