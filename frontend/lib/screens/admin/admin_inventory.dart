import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import 'admin_product_detail.dart';

class AdminInventoryScreen extends StatefulWidget {
  final bool isSubPage;
  const AdminInventoryScreen({super.key, this.isSubPage = false});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Set<String> selectedCategories = {'Recently Added'};
  String searchQuery = '';
  Set<String> selectedStockStatuses = {};
  Set<String> selectedExpirationFilters = {};
  String? selectedSort; // Combined sort state: 'A-Z', 'Z-A', 'Price-Asc', 'Price-Desc'

  final List<String> categories = [
    'Recently Added',
    'Beverages',
    'Liquor & Tobacco',
    'Snacks & Sweets',
    'Fresh Foods',
    'Prepared Foods',
    'Frozen Goods',
    'Personal Care',
    'Household Care',
    'Miscellaneous',
  ];

  List<Map<String, dynamic>> adminProducts = [
    {
      'id': 1, 
      'name': 'Malunggay Lotion 500mL', 
      'category': 'Personal Care', 
      'basePrice': 150.00, 
      'markup': 20.00, 
      'stocks': 0, 
      'status': 'No Stock',
      'description': 'nourishing lotion with cocoa extract and vitamin e.',
      'expiry': 'August 2, 2028'
    },
    {
      'id': 2, 
      'name': 'Malunggay Juice 80mL', 
      'category': 'Beverages', 
      'basePrice': 45.00, 
      'markup': 10.00, 
      'stocks': 12, 
      'status': 'Low Stock',
      'description': 'freshly squeezed malunggay extract with a hint of lemon.',
      'expiry': 'September 15, 2026'
    },
    {
      'id': 3, 
      'name': 'Malunggay Chips 20g', 
      'category': 'Snacks & Sweets', 
      'basePrice': 30.00, 
      'markup': 5.00, 
      'stocks': 100, 
      'status': 'In Stock',
      'description': 'crispy malunggay flavored crackers.',
      'expiry': 'October 20, 2026'
    },
    {
      'id': 4, 
      'name': 'Frozen Malunggay', 
      'category': 'Frozen Goods', 
      'basePrice': 80.00, 
      'markup': 15.00, 
      'stocks': 45, 
      'status': 'In Stock',
      'description': 'frozen fresh malunggay leaves.',
      'expiry': 'January 10, 2027'
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> filtered = adminProducts.where((p) {
      final matchesCategory = selectedCategories.contains('Recently Added') || selectedCategories.contains(p['category']);
      final matchesSearch = p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStock = selectedStockStatuses.isEmpty || selectedStockStatuses.contains(p['status']);
      return matchesCategory && matchesSearch && matchesStock;
    }).toList();

    if (selectedSort != null) {
      filtered.sort((a, b) {
        if (selectedSort == 'A-Z') return a['name'].compareTo(b['name']);
        if (selectedSort == 'Z-A') return b['name'].compareTo(a['name']);
        
        double priceA = (a['basePrice'] + a['markup']).toDouble();
        double priceB = (b['basePrice'] + b['markup']).toDouble();
        if (selectedSort == 'Price-Asc') return priceA.compareTo(priceB);
        if (selectedSort == 'Price-Desc') return priceB.compareTo(priceA);
        
        return 0;
      });
    }

    return filtered;
  }

  void _showActionSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(color: Color(0xFF76BA1B), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
              const SizedBox(height: 25),
              SizedBox(
                width: 120, height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF35524A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: Text("OK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteProduct(int id) {
    setState(() => adminProducts.removeWhere((p) => p['id'] == id));
    _showActionSuccess("Product deleted successfully!");
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    Widget mainContent = Column(
      children: [
        // Search and Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => searchQuery = v),
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none, 
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.search, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: const Icon(Icons.tune, color: Colors.black, size: 28)
              ),
            ],
          ),
        ),
        // Category List
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategories.contains(cat);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (cat == 'Recently Added') {
                        selectedCategories = {'Recently Added'};
                      } else {
                        selectedCategories = {cat};
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2F3E46) : const Color(0xFF9E9E9E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat, 
                      style: GoogleFonts.poppins(
                        fontSize: 12, 
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      )
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Colors.black12),
        // Product List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminProductDetailScreen(
                        productList: filteredProducts,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Dismissible(
                  key: Key(product['id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (dir) => _deleteProduct(product['id']),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
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
                                product['name'], 
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18,
                                  color: const Color(0xFF2F3E46),
                                )
                              ),
                              Text(
                                product['category'], 
                                style: GoogleFonts.poppins(
                                  fontSize: 12, 
                                  color: Colors.black45, 
                                  fontStyle: FontStyle.italic
                                )
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.arrow_forward, size: 16, color: Colors.black45),
                            const SizedBox(height: 12),
                            _buildStatusTag(product['status']),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: _buildFilterSidebar(),
      body: Column(
        children: [
          // Header with Logo and Gradient
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E8B7F), Color(0xFF35524A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(width: 15),
                // Inventory Label
                Text(
                  'Inventory',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Content Area (Combined with header)
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: mainContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter Products',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2F3E46),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategories = {'Recently Added'};
                        selectedStockStatuses = {};
                        selectedExpirationFilters = {};
                        selectedSort = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterSectionTitle('Categories'),
                  const SizedBox(height: 8),
                  ...categories.map((cat) {
                    bool isChecked = selectedCategories.contains(cat);
                    return Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            if (cat == 'Recently Added') {
                              selectedCategories = {'Recently Added'};
                            } else {
                              if (value == true) {
                                selectedCategories.remove('Recently Added');
                                selectedCategories.add(cat);
                              } else {
                                selectedCategories.remove(cat);
                                if (selectedCategories.isEmpty) {
                                  selectedCategories.add('Recently Added');
                                }
                              }
                            }
                          });
                        },
                        title: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isChecked ? const Color(0xFF2F3E46) : Colors.black54,
                            fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF35524A),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildExpandableChecklistFilter(
                    'Stock Status',
                    ['In Stock', 'Low Stock', 'No Stock'],
                    selectedStockStatuses,
                    (val) {
                      setState(() {
                        if (selectedStockStatuses.contains(val)) {
                          selectedStockStatuses.remove(val);
                        } else {
                          selectedStockStatuses.add(val);
                        }
                      });
                    }
                  ),
                  _buildExpandableChecklistFilter(
                    'Expiration Date',
                    ['Expiring Soon', 'Fresh'],
                    selectedExpirationFilters,
                    (val) {
                      setState(() {
                        if (selectedExpirationFilters.contains(val)) {
                          selectedExpirationFilters.remove(val);
                        } else {
                          selectedExpirationFilters.add(val);
                        }
                      });
                    }
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  _buildFilterSectionTitle('Sort Alphabetically'),
                  const SizedBox(height: 5),
                  _buildRadioSortOption('A-Z', 'A-Z'),
                  _buildRadioSortOption('Z-A', 'Z-A'),
                  const SizedBox(height: 15),
                  _buildFilterSectionTitle('Price'),
                  const SizedBox(height: 5),
                  _buildRadioSortOption('Ascending', 'Price-Asc'),
                  _buildRadioSortOption('Descending', 'Price-Desc'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35524A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF35524A),
      ),
    );
  }

  Widget _buildRadioSortOption(String label, String value) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.grey,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedSort,
        onChanged: (String? newValue) {
          setState(() => selectedSort = newValue);
        },
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: selectedSort == value ? const Color(0xFF2F3E46) : Colors.black54,
            fontWeight: selectedSort == value ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        activeColor: const Color(0xFF35524A),
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildExpandableChecklistFilter(String title, List<String> options, Set<String> selectedValues, Function(String) onToggle) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF35524A),
        ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 10),
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
      children: options.map((opt) {
        bool isChecked = selectedValues.contains(opt);
        return Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          child: CheckboxListTile(
            value: isChecked,
            onChanged: (bool? value) => onToggle(opt),
            title: Text(
              opt,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isChecked ? const Color(0xFF2F3E46) : Colors.black54,
                fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF35524A),
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor = status == 'In Stock' ? const Color(0xFF2D936C) : (status == 'Low Stock' ? const Color(0xFFF2A65A) : const Color(0xFFEF5350));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
