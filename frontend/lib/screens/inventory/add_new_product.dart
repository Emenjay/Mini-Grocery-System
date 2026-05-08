// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // --- state variables ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _measureController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(); // added for stock logic

  String? selectedType;
  String? selectedCategory;
  String? selectedStatus;
  DateTime? expirationDate;
  DateTime? dateReceived;
  String generatedId = "SELECT CATEGORY";
  int currentProductCount = 124;

  // new velocity state
  bool isFastMoving = false; 
  bool _submittedOnce = false;

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

  bool get _isExpiredError {
    if (expirationDate == null || dateReceived == null) return false;
    return expirationDate!.isBefore(dateReceived!);
  }

  bool get _canSubmit {
    return _nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _measureController.text.isNotEmpty &&
        _stockController.text.isNotEmpty && // required for threshold check
        selectedType != null &&
        selectedCategory != null &&
        selectedStatus != null &&
        expirationDate != null &&
        dateReceived != null &&
        !_isExpiredError;
  }

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

  void _confirmAddProduct() {
    // backend integration note: calculate threshold here
    // int threshold = isFastMoving ? 50 : 15;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_task_rounded, color: Color(0xFF2D936C), size: 64),
              const SizedBox(height: 16),
              const Text("Confirm Product", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Add this item to the database with ID:", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF0F7F4), borderRadius: BorderRadius.circular(8)),
                child: Text(generatedId, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E5C51), fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { Navigator.pop(context); _showSuccessModal(); },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D936C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                    ),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF2D936C), size: 64),
              const SizedBox(height: 16),
              const Text("Product Added", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Product $generatedId has been saved successfully.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E5C51), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16)),
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF3E5C51))),
        child: child!,
      ),
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF3E5C51),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.keyboard_return, color: Color(0xFF3E5C51), size: 18),
                        ),
                      ),
                      const Expanded(
                        child: Text("Add New Product", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 35),
                  _buildTopField("Product Name", "e.g. Ligo Sardines", _nameController, showError: _nameController.text.isEmpty),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTopDropdown("Type", selectedType ?? "Select", ["Solid", "Liquid"], (val) => setState(() => selectedType = val), showError: selectedType == null)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTopField("Measurement", selectedType == "Liquid" ? "mL / L" : "g / kg", _measureController, showError: _measureController.text.isEmpty)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTopField("Price", "0.00", _priceController, isPrice: true, showError: _priceController.text.isEmpty)),
                    ],
                  ),
                ],
              ),
            ),

            // --- form ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSectionCard([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildBottomDropdown("Category", selectedCategory ?? "Select Category", categories, (val) => _updateId(val), showError: selectedCategory == null)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildDisplayField("Generated ID", generatedId)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // --- inventory velocity selector ---
                    const Text("Inventory Velocity", style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildVelocityToggle("Normal (15 Threshold)", !isFastMoving, () => setState(() => isFastMoving = false))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildVelocityToggle("Fast (50 Threshold)", isFastMoving, () => setState(() => isFastMoving = true))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildBottomDropdown("Stock Status", selectedStatus ?? "Status", ["In Stock", "Low Stock", "No Stock"], (val) => setState(() => selectedStatus = val), showError: selectedStatus == null)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTopField("Initial Stock", "0", _stockController, isPrice: true, showError: _stockController.text.isEmpty, isStock: true)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDateTile("Expiration Date", expirationDate, () => _pickDate(context, true), showError: expirationDate == null)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildDateTile("Date Received", dateReceived, () => _pickDate(context, false), showError: dateReceived == null)),
                      ],
                    ),
                    if (_isExpiredError)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                            SizedBox(width: 8),
                            Expanded(child: Text("Product cannot be added because it is expired", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionCard([
                    _buildBottomField("Description (Optional)", "Add details...", _descController, maxLines: 3),
                  ]),
                  
                  if (!_canSubmit && _submittedOnce)
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text("Please fill in all required fields.", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),

                  const SizedBox(height: 35),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Discard", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _submittedOnce = true);
                            if (_canSubmit) _confirmAddProduct();
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text("Save Product", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSubmit ? const Color(0xFF2D936C) : Colors.grey[600],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

  // --- helpers ---
  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  // velocity toggle helper
  Widget _buildVelocityToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3E5C51) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF3E5C51) : Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTopField(String label, String hint, TextEditingController controller, {bool isPrice = false, bool showError = false, bool isStock = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: isStock ? Colors.black87 : Colors.white70, fontSize: isStock ? 13 : 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        height: 48,
        decoration: BoxDecoration(
          color: isStock ? const Color(0xFFF8F9FA) : Colors.white.withOpacity(0.15), 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: (showError && _submittedOnce) ? Colors.redAccent : (isStock ? Colors.black12 : Colors.white.withOpacity(0.1)))
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isStock ? Colors.black87 : Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixText: (isPrice && !isStock) ? "₱ " : null, 
            prefixStyle: const TextStyle(color: Colors.white), 
            hintText: hint, 
            hintStyle: TextStyle(fontSize: 14, color: isStock ? Colors.black26 : Colors.white38), 
            border: InputBorder.none, 
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)
          ),
        ),
      ),
      if (showError && _submittedOnce) const Padding(padding: EdgeInsets.only(top: 4), child: Text("Required", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildTopDropdown(String label, String selected, List<String> items, Function(String?) onChanged, {bool showError = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: (showError && _submittedOnce) ? Colors.redAccent : Colors.white.withOpacity(0.1))),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          isExpanded: true, dropdownColor: const Color(0xFF3E5C51), value: items.contains(selected) ? selected : null,
          hint: Text(selected, style: const TextStyle(fontSize: 14, color: Colors.white38)),
          icon: const Icon(Icons.expand_more, color: Colors.white70),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 14)))).toList(),
          onChanged: onChanged,
        )),
      ),
      if (showError && _submittedOnce) const Padding(padding: EdgeInsets.only(top: 4), child: Text("Required", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildBottomDropdown(String label, String selected, List<String> items, Function(String?) onChanged, {bool showError = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: (showError && _submittedOnce) ? Colors.redAccent : Colors.black12)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          isExpanded: true, value: items.contains(selected) ? selected : null,
          hint: Text(selected, style: const TextStyle(fontSize: 13, color: Colors.black45)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        )),
      ),
    ]);
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap, {bool showError = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: (showError && _submittedOnce) ? Colors.redAccent : Colors.black12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(date == null ? "MM/DD/YYYY" : DateFormat('MMM dd, yyyy').format(date), style: TextStyle(fontSize: 11, color: date == null ? Colors.black26 : Colors.black87)),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black26),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildDisplayField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 14),
      Text(value, style: const TextStyle(color: Color(0xFF3E5C51), fontSize: 13, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildBottomField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
        child: TextField(controller: controller, maxLines: maxLines, style: const TextStyle(fontSize: 14), decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(12))),
      ),
    ]);
  }
}