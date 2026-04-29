// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
// ignore: unused_import
import '../../../theme/colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // --- ꜱᴛᴀᴛᴇ ᴠᴀʀɪᴀʙʟᴇꜱ ꜰᴏʀ ᴅʙ ɪɴᴛᴇɢʀᴀᴛɪᴏɴ ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _measureController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String? selectedType; 
  String? selectedCategory;
  String? selectedStatus;
  DateTime? expirationDate;
  DateTime? dateReceived;
  
  // ᴅᴇꜰᴀᴜʟᴛ ᴘʟᴀᴄᴇʜᴏʟᴅᴇʀ ꜰᴏʀ ɪᴅ ʙᴇꜰᴏʀᴇ ᴄᴀᴛᴇɢᴏʀʏ ꜱᴇʟᴇᴄᴛɪᴏɴ
  String generatedId = "SELECT CATEGORY";
  
  // ᴍᴏᴄᴋ ᴅᴀᴛᴀ ᴛᴏ ꜱɪᴍᴜʟᴀᴛᴇ ᴅᴀᴛᴀʙᴀꜱᴇ ɪɴᴄʀᴇᴍᴇɴᴛ
  int currentProductCount = 124; 

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
    'Beverages', 'Liquor & Tobacco', 'Snacks & Sweets', 'Fresh & Prepared',
    'Pantry Staples', 'Frozen Goods', 'Personal Care', 'Household Care', 'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_rebuild);
    _priceController.addListener(_rebuild);
    _measureController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  // ᴠᴀʟɪᴅᴀᴛᴇꜱ ᴅᴀᴛᴇ ʟᴏɢɪᴄ ᴛᴏ ᴘʀᴇᴠᴇɴᴛ ᴇxᴘɪʀᴇᴅ ᴇɴᴛʀɪᴇꜱ
  bool get _isExpiredError {
    if (expirationDate == null || dateReceived == null) return false;
    return expirationDate!.isBefore(dateReceived!);
  }

  // ʙᴜᴛᴛᴏɴ ꜱᴛᴀᴛᴇ ʟᴏɢɪᴄ
  bool get _canSubmit {
    return _nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _measureController.text.isNotEmpty &&
        selectedType != null &&
        selectedCategory != null &&
        selectedStatus != null &&
        expirationDate != null &&
        dateReceived != null &&
        !_isExpiredError;
  }

  // ɢᴇɴᴇʀᴀᴛᴇꜱ ᴀ ꜰᴏʀᴍᴀᴛᴛᴇᴅ ɪᴅ ꜱɪᴍɪʟᴀʀ ᴛᴏ ᴅᴀᴛᴀʙᴀꜱᴇ ꜱᴇʀɪᴀʟ ɴᴜᴍʙᴇʀꜱ
  // ꜰᴏʀᴍᴀᴛ: [ᴄᴀᴛᴇɢᴏʀʏ]-[ʏᴇᴀʀ][ᴍᴏɴᴛʜ]-[ɪɴᴄʀᴇᴍᴇɴᴛᴀʟ ɪᴅ]
  void _updateId(String? category) {
    if (category == null) return;
    
    String prefix = categoryCodes[category] ?? 'GEN';
    String datePart = DateFormat('yyyyMM').format(DateTime.now());
    String rankString = (currentProductCount + 1).toString().padLeft(4, '0');
    
    setState(() {
      selectedCategory = category;
      generatedId = "$prefix-$datePart-$rankString"; 
    });
  }

  // ᴄᴏɴꜰɪʀᴍᴀᴛɪᴏɴ ꜰʟᴏᴡ ʙᴇꜰᴏʀᴇ "ꜱᴀᴠɪɴɢ"
  void _confirmAddProduct() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_task_rounded, color: Color(0xFF2D936C), size: 60),
              const SizedBox(height: 16),
              const Text("Confirm Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Add this item to the database with ID:", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54)),
              Text(generatedId, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E5C51))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black12)),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      _showSuccessModal();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D936C)),
                    child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF2D936C), size: 60),
              const SizedBox(height: 16),
              const Text("Product Added", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Product $generatedId has been saved.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E5C51)),
                  child: const Text("Done", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isExpiration) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpiration) expirationDate = picked;
        else dateReceived = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ʜᴇᴀᴅᴇʀ ꜱᴇᴄᴛɪᴏɴ ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              color: const Color(0xFF3E5C51),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.keyboard_return, color: Color(0xFF3E5C51)),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Add New Product",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildTopField("Product Name:", "Enter Product Name", _nameController),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _buildTopDropdown("Product Type:", selectedType ?? "Solid/Liquid", ["Solid", "Liquid"], (val) {
                        setState(() => selectedType = val);
                      })),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTopField(
                        "Measurement:", 
                        selectedType == "Liquid" ? "mL / L" : (selectedType == "Solid" ? "g / kg" : "300 mL/ 60g"), 
                        _measureController
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTopField("Base Price:", "0.00", _priceController, isPrice: true)),
                    ],
                  ),
                ],
              ),
            ),

            // --- ꜰᴏʀᴍ ꜱᴇᴄᴛɪᴏɴ ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildBottomDropdown("Category:", selectedCategory ?? "Choose Category", categories, (val) => _updateId(val))),
                      const SizedBox(width: 20),
                      Expanded(child: _buildDisplayField("Product ID:", generatedId)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildBottomDropdown("Available Stocks", selectedStatus ?? "Choose Status", ["In Stock", "Low Stock", "No Stock"], (val) => setState(() => selectedStatus = val))),
                      const SizedBox(width: 20),
                      Expanded(child: _buildDateTile("Expiration Date:", expirationDate, () => _pickDate(context, true))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDateTile("Date Received:", dateReceived, () => _pickDate(context, false)),
                  
                  if (_isExpiredError)
                    const Padding(
                      padding: EdgeInsets.only(top: 5, left: 5),
                      child: Text(
                        "Product cannot be added because it is expired",
                        style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  
                  const SizedBox(height: 15),
                  _buildBottomField("Description (Optional):", "Enter Description", _descController, maxLines: 3),
                  const SizedBox(height: 40),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3E5C51)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Cancel", style: TextStyle(color: Color(0xFF3E5C51), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _canSubmit ? _confirmAddProduct : null,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text("Add Product"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D936C),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ᴜɪ ʜᴇʟᴘᴇʀꜱ ---

  Widget _buildTopField(String label, String hint, TextEditingController controller, {bool isPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            keyboardType: isPrice ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              prefixText: isPrice ? "₱ " : null,
              hintText: hint, 
              hintStyle: const TextStyle(fontSize: 12, color: Colors.black26), 
              border: InputBorder.none, 
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDropdown(String label, String selected, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(selected) ? selected : null,
              hint: Text(selected, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black26),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDropdown(String label, String selected, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: Colors.black12.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(selected) ? selected : null,
              hint: Text(selected, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.black12.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null ? "MM/DD/YYYY" : DateFormat('MM/dd/yyyy').format(date),
                  style: TextStyle(fontSize: 12, color: date == null ? Colors.black26 : Colors.black87),
                ),
                const Icon(Icons.calendar_month, size: 18, color: Colors.black26),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // ꜰᴏɴᴛ ꜱɪᴢᴇ ꜱʟɪɢʜᴛʟʏ ʀᴇᴅᴜᴄᴇᴅ ᴛᴏ ꜰɪᴛ ʟᴏɴɢᴇʀ ꜱᴛʀɪɴɢꜱ
        Text(value, style: const TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: Colors.black12.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 12, color: Colors.black26), border: InputBorder.none, contentPadding: const EdgeInsets.all(10)),
          ),
        ),
      ],
    );
  }
}