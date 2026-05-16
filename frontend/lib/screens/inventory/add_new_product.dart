// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/inventory_service.dart';

// categories that are perishable - always use 15 (normal) threshold
// Fresh & Prepared, Pantry Staples, Frozen Goods are perishable and slower-moving
const perishableCategories = ['Fresh & Prepared', 'Pantry Staples', 'Frozen Goods'];

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _measureController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? selectedType;
  String? selectedCategoryName;
  int? selectedCategoryID;
  DateTime? expirationDate;
  DateTime? dateReceived;

  bool? isFastMoving = null;
  bool _submittedOnce = false;
  bool _isLoading = false;

  // REMOVED: selectedStatus - backend calculates stock status automatically

  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoading = true;
  

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_rebuild);
    _priceController.addListener(_rebuild);
    _measureController.addListener(_rebuild);
    _stockController.addListener(_rebuild);
    _loadCategories();
  }

  void _rebuild() => setState(() {});

  Future<void> _loadCategories() async {
    final result = await InventoryService.getCategories();
    if (!mounted) return;
    if (result['success']) {
      setState(() {
        _categories = List<Map<String, dynamic>>.from(result['categories']);
        _categoriesLoading = false;
      });
    } else {
      setState(() => _categoriesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load categories')),
      );
    }
  }

  bool get _isExpiredError {
    if (expirationDate == null || dateReceived == null) return false;
    return expirationDate!.isBefore(dateReceived!);
  }

  bool get _canSubmit {
    return _nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        // _measureController.text.isNotEmpty &&
        _stockController.text.isNotEmpty &&
        selectedType != null &&
        selectedCategoryID != null &&
        // REMOVED: selectedStatus check - not needed
        expirationDate != null &&
        dateReceived != null &&
        !_isExpiredError;
  }

  void _updateCategory(String? categoryName, int? categoryId) {
  setState(() {
    selectedCategoryName = categoryName;
    selectedCategoryID = categoryId;

    // pre-select None for perishable categories, but user can still change it
    if (categoryName != null && perishableCategories.contains(categoryName)) {
      isFastMoving = null; // pre-select None (no threshold)
    }
  });
}

  Future<void> _confirmAddProduct() async {
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
              const Text("Confirm Product",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Add this item to the database?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _submitProduct();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D936C),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text("Confirm",
                          style: TextStyle(color: Colors.white)),
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

  // submit product to backend
  Future<void> _submitProduct() async {
    setState(() => _isLoading = true);

    // combine product name and measurement into one field
    // if measurement is provided, append it to the name (e.g. "Ligo Sardines 155g") 
    // final measurement = _measureController.text.trim();
    // final fullProductName = measurement.isNotEmpty
    //   ? '${_nameController.text.trim()} $measurement'
    //   : _nameController.text.trim();

    final result = await InventoryService.addProduct(
    categoryID: selectedCategoryID!,
    productName: _nameController.text.trim(),
    basePrice: double.tryParse(_priceController.text) ?? 0.0,
    description: _descController.text.trim(),
    unitMeasurement: _measureController.text.trim(),
    stockQuantity: int.tryParse(_stockController.text) ?? 0,
    spoilageDate: expirationDate,
    isFastMoving: isFastMoving, // null = no threshold, false = Normal, true = Fast
    receivedDate: dateReceived,
  );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccessModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to add product')),
      );
    }
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
              const Icon(Icons.check_circle_outline,
                  color: Color(0xFF2D936C), size: 64),
              const SizedBox(height: 16),
              const Text("Product Added",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Product has been saved successfully.\nPending admin approval.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close success modal
                    Navigator.pop(context); // go back to staff inventory
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E5C51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("Done",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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
        data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFF3E5C51))),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isExpiration) {
          expirationDate = picked;
        } else {
          dateReceived = picked;
        }
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
            // header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF3E5C51),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.keyboard_return,
                              color: Color(0xFF3E5C51), size: 18),
                        ),
                      ),
                      const Expanded(
                        child: Text("Add New Product",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 35),
                  _buildTopField("Product Name", "e.g. Ligo Sardines",
                      _nameController,
                      showError: _nameController.text.isEmpty),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildTopDropdown(
                              "Type",
                              selectedType ?? "Select",
                              ["Solid", "Liquid"],
                              (val) => setState(() => selectedType = val),
                              showError: selectedType == null)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTopField(
                              "Measurement",
                              selectedType == "Liquid" ? "mL / L" : "g / kg",
                              _measureController,
                              showError: false)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTopField(
                              "Price", "0.00", _priceController,
                              isPrice: true,
                              showError: _priceController.text.isEmpty)),
                    ],
                  ),
                ],
              ),
            ),

            // form body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSectionCard([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _categoriesLoading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : _buildCategoryDropdown(),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildDisplayField(
                            "Pending Approval",
                            "Admin must set markup before product is visible to cashier",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Inventory Velocity — 3 options in one row, perishable pre-selects None but all are unlockable
                    const Text("Inventory Velocity",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildVelocityToggle(
                          "None",
                          isFastMoving == null,
                          () => setState(() => isFastMoving = null),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVelocityToggle(
                          "Normal\n(15)",
                          isFastMoving == false,
                          () => setState(() => isFastMoving = false),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVelocityToggle(
                          "Fast\n(50)",
                          isFastMoving == true,
                          () => setState(() => isFastMoving = true),
                        )),
                      ],
                    ),
                    if (perishableCategories.contains(selectedCategoryName))
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "Perishable category, None threshold pre-selected. You can still change it.",
                          style: TextStyle(fontSize: 10, color: Colors.black45, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // REMOVED: Stock Status dropdown
                    // stock status is now auto-calculated by backend

                    // initial stock field only
                    _buildTopField("Initial Stock", "0", _stockController,
                        isPrice: true,
                        showError: _stockController.text.isEmpty,
                        isStock: true),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildDateTile(
                                "Expiration Date", expirationDate,
                                () => _pickDate(context, true),
                                showError: expirationDate == null)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildDateTile(
                                "Date Received", dateReceived,
                                () => _pickDate(context, false),
                                showError: dateReceived == null)),
                      ],
                    ),
                    if (_isExpiredError)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.redAccent, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    "Product cannot be added because it is expired",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionCard([
                    _buildBottomField(
                        "Description (Optional)", "Add details...",
                        _descController,
                        maxLines: 3),
                  ]),

                  if (!_canSubmit && _submittedOnce)
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text("Please fill in all required fields.",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),

                  const SizedBox(height: 35),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Discard",
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() => _submittedOnce = true);
                                  if (_canSubmit) _confirmAddProduct();
                                },
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.add_circle_outline,
                                  color: Colors.white),
                          label: const Text("Save Product",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSubmit
                                ? const Color(0xFF2D936C)
                                : Colors.grey[600],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
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

  Widget _buildCategoryDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Category",
          style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: (_submittedOnce && selectedCategoryID == null)
                    ? Colors.redAccent
                    : Colors.black12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: selectedCategoryID,
            hint: const Text("Select Category",
                style: TextStyle(fontSize: 13, color: Colors.black45)),
            items: _categories
                .map((cat) => DropdownMenuItem<int>(
                      value: cat['category_id'] as int,
                      child: Text(cat['category_name'].toString(),
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              final cat =
                  _categories.firstWhere((c) => c['category_id'] == val);
              _updateCategory(cat['category_name'].toString(), val);
            },
          ),
        ),
      ),
      if (_submittedOnce && selectedCategoryID == null)
        const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text("Required",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

Widget _buildVelocityToggle(String label, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3E5C51) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF3E5C51) : Colors.black12,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          height: 1.3,
        ),
      ),
    ),
  );
}

  Widget _buildTopField(
      String label, String hint, TextEditingController controller,
      {bool isPrice = false,
      bool showError = false,
      bool isStock = false}) {
    final keyboardType =
        (isPrice || isStock) ? TextInputType.number : TextInputType.text;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              color: isStock ? Colors.black87 : Colors.white70,
              fontSize: isStock ? 13 : 12,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        height: 48,
        decoration: BoxDecoration(
            color: isStock
                ? const Color(0xFFF8F9FA)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: (showError && _submittedOnce)
                    ? Colors.redAccent
                    : (isStock
                        ? Colors.black12
                        : Colors.white.withOpacity(0.1)))),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
              color: isStock ? Colors.black87 : Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixText: (isPrice && !isStock) ? "₱ " : null,
            prefixStyle: const TextStyle(color: Colors.white),
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 14,
                color: isStock ? Colors.black26 : Colors.white38),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ),
      if (showError && _submittedOnce)
        const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text("Required",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildTopDropdown(String label, String selected, List<String> items,
      Function(String?) onChanged,
      {bool showError = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: (showError && _submittedOnce)
                    ? Colors.redAccent
                    : Colors.white.withOpacity(0.1))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: const Color(0xFF3E5C51),
            value: items.contains(selected) ? selected : null,
            hint: Text(selected,
                style:
                    const TextStyle(fontSize: 14, color: Colors.white38)),
            icon: const Icon(Icons.expand_more, color: Colors.white70),
            items: items
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
      if (showError && _submittedOnce)
        const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text("Required",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap,
      {bool showError = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: (showError && _submittedOnce)
                      ? Colors.redAccent
                      : Colors.black12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  date == null
                      ? "MM/DD/YYYY"
                      : DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(
                      fontSize: 11,
                      color:
                          date == null ? Colors.black26 : Colors.black87)),
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.black26),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildDisplayField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(value,
          style: const TextStyle(
              color: Color(0xFF3E5C51),
              fontSize: 11,
              fontStyle: FontStyle.italic)),
    ]);
  }

  Widget _buildBottomField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12)),
        child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12))),
      ),
    ]);
  }
}