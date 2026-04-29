// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productList;
  final int initialIndex;

  const ProductDetailScreen({
    super.key, 
    required this.productList, 
    required this.initialIndex
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _currentIndex;
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
    _currentIndex = widget.initialIndex;
    _initProductControllers();
  }

  void _initProductControllers() {
    final product = widget.productList[_currentIndex];
    _nameController = TextEditingController(text: product['name']);
    _descController = TextEditingController(text: "Nourishing Lotion with Cocoa Extract and Vitamin E. Wonderful extract with papaya tidbits and peanut butter.");
    _basePriceController = TextEditingController(text: "150.00");
    _stocksController = TextEditingController(text: product['stocks'].toString());
    _selectedCategory = product['category'];
    _selectedExpirationDate = DateTime(2028, 8, 2);
  }

  void _navigate(int direction) {
    setState(() {
      isEditing = false;
      _currentIndex = (_currentIndex + direction) % widget.productList.length;
      if (_currentIndex < 0) _currentIndex = widget.productList.length - 1;
      _initProductControllers();
    });
  }

  // ʜᴀɴᴅʟᴇꜱ ᴄᴏɴꜰɪʀᴍᴀᴛɪᴏɴ ʙᴇꜰᴏʀᴇ ꜱᴀᴠɪɴɢ ᴇᴅɪᴛᴇᴅ ᴄʜᴀɴɢᴇꜱ
  void _confirmSave() {
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
                const Icon(Icons.help_outline_rounded, color: Color(0xFF2D936C), size: 60),
                const SizedBox(height: 16),
                const Text("Save Changes?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Are you sure you want to update this product's information?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ʟᴏɢɪᴄ ᴛᴏ ᴜᴘᴅᴀᴛᴇ ᴛʜᴇ ᴀᴄᴛᴜᴀʟ ʟɪꜱᴛ ᴅᴀᴛᴀ ᴡᴏᴜʟᴅ ɢᴏ ʜᴇʀᴇ
                        Navigator.pop(context); // ᴄʟᴏꜱᴇ ᴄᴏɴꜰɪʀᴍ ᴍᴏᴅᴀʟ
                        _showSuccessModal("Product Updated", "The changes have been saved successfully.");
                        setState(() => isEditing = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D936C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // ʜᴀɴᴅʟᴇꜱ ᴅᴇʟᴇᴛɪᴏɴ ᴄᴏɴꜰɪʀᴍᴀᴛɪᴏɴ
  void _confirmDelete() {
    final currentItem = widget.productList[_currentIndex];
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
                  "Are you sure you want to delete ${currentItem['name']}? This action cannot be undone.",
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.productList.removeAt(_currentIndex);
                        Navigator.pop(context); 
                        _showSuccessModal("Deletion Successful", "The item has been removed from inventory.", isDelete: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // ɢᴇɴᴇʀɪᴄ ꜱᴜᴄᴄᴇꜱꜱ ᴘᴏᴘ-ᴜᴘ ꜰᴏʀ ʙᴏᴛʜ ꜱᴀᴠɪɴɢ ᴀɴᴅ ᴅᴇʟᴇᴛɪɴɢ
  void _showSuccessModal(String title, String message, {bool isDelete = false}) {
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
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2D936C), size: 60),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // ᴄʟᴏꜱᴇ ꜱᴜᴄᴄᴇꜱꜱ ᴍᴏᴅᴀʟ
                      if (isDelete) Navigator.pop(context); // ᴇxɪᴛ ᴅᴇᴛᴀɪʟꜱ ꜱᴄʀᴇᴇɴ ɪꜰ ᴅᴇʟᴇᴛᴇᴅ
                    },
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedExpirationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.productList.isEmpty 
        ? {'id': 'N/A', 'name': 'Deleted', 'category': 'N/A', 'stocks': 0}
        : widget.productList[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                if (!isEditing) ...[
                  Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white38, thickness: 1, endIndent: 100),
                  Text(_selectedCategory ?? "", style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic)),
                ] else ...[
                  _headerInput("Product Name", _nameController),
                  const SizedBox(height: 10),
                  _headerDropdown(),
                ],
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Retail Price", style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                      Text("₱ 170.00", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isEditing)
                      ElevatedButton.icon(
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: isEditing ? _confirmSave : () => setState(() => isEditing = true),
                      icon: Icon(isEditing ? Icons.check_circle : Icons.edit, size: 16),
                      label: Text(isEditing ? "Confirm Changes" : "Edit Product"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D936C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                )
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
                  const SizedBox(height: 10),
                  isEditing 
                    ? _editBox(_descController, maxLines: 4)
                    : Text(_descController.text, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
                  
                  const SizedBox(height: 30),
                  _infoTile(Icons.badge_outlined, "Product Number / ID", currentItem['id'], editable: false),
                  
                  _infoTile(Icons.sell_outlined, "Base Price", "₱ ${_basePriceController.text}", 
                    controller: _basePriceController, isEditing: isEditing, isPrice: true),
                  
                  _infoTile(Icons.inventory_2_outlined, "Available Stocks", _stocksController.text, 
                    controller: _stocksController, isEditing: isEditing),
                  
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

  // ʜᴇʟᴘᴇʀ ᴜɪ ᴍᴇᴛʜᴏᴅꜱ ʀᴇᴛᴀɪɴᴇᴅ ꜰᴏʀ ᴄᴏɴꜱɪꜱᴛᴇɴᴄʏ
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