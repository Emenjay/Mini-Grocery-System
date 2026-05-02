import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../admin/staff_info_screen.dart';

class StaffListScreen extends StatefulWidget {
  final bool isSubPage;
  const StaffListScreen({super.key, this.isSubPage = false});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  // Filter states
  Set<String> selectedRoles = {};
  Set<String> selectedStatuses = {};
  String? selectedSort; // 'A-Z', 'Z-A'

  final List<String> availableRoles = [
    'Inventory Staff',
    'Cashier',
  ];

  final List<Map<String, dynamic>> staffList = [
    {
      'id': 1,
      'name': 'Lyra Bellah Buenavista',
      'role': 'Inventory Staff',
      'onDuty': true,
      'photo': 'assets/images/staff_1.png',
      'contactNumber': '+639941790960',
      'address': 'Brgy. New Jenshan, California',
      'username': 'DinglePM_Buenavista',
      'shifts': [
        {'type': 'Log out', 'time': '6:30 PM', 'date': 'March 11, 2026'},
        {'type': 'Log in',  'time': '7:30 AM', 'date': 'March 11, 2026'},
        {'type': 'Log out', 'time': '6:30 PM', 'date': 'March 10, 2026'},
      ],
    },
    {
      'id': 2,
      'name': 'Michael John Ramos',
      'role': 'Cashier',
      'onDuty': true,
      'photo': 'assets/images/staff_2.png',
      'contactNumber': '+639511698350',
      'address': 'Brgy. Idk, Idc City',
      'username': 'DinglePM_Ramos',
      'shifts': [],
    },
    {
      'id': 3,
      'name': 'Gwen Tricia Lingling',
      'role': 'Cashier',
      'onDuty': false,
      'photo': 'assets/images/staff_3.png',
      'contactNumber': '+639123456789',
      'address': 'Brgy. New Jenshan, California',
      'username': 'DinglePM_Lingling',
      'shifts': [],
    },
    {
      'id': 4,
      'name': 'Gwen Tricia Aman',
      'role': 'Cashier',
      'onDuty': false,
      'photo': 'assets/images/staff_4.png',
      'contactNumber': '+639123456780',
      'address': 'Brgy. New Jenshan, California',
      'username': 'DinglePM_Aman',
      'shifts': [],
    },
  ];

  List<Map<String, dynamic>> get filteredStaff {
    List<Map<String, dynamic>> filtered = staffList.where((s) {
      final q = searchQuery.toLowerCase();
      final matchesSearch = s['name'].toString().toLowerCase().contains(q) ||
          s['role'].toString().toLowerCase().contains(q);

      final matchesRole = selectedRoles.isEmpty || selectedRoles.contains(s['role']);

      final status = s['onDuty'] == true ? 'On Duty' : 'Off Duty';
      final matchesStatus = selectedStatuses.isEmpty || selectedStatuses.contains(status);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();

    if (selectedSort != null) {
      filtered.sort((a, b) {
        if (selectedSort == 'A-Z') return a['name'].compareTo(b['name']);
        if (selectedSort == 'Z-A') return b['name'].compareTo(a['name']);
        return 0;
      });
    }

    return filtered;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openAddNew() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Staff'),
        content: const Text('Coming soon!!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStaffMenu(BuildContext context, Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _StaffMenuSheet(
        staff: staff,
        onView: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffInfoScreen(staff: staff),
            ),
          );
        },
        onEdit: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffInfoScreen(staff: staff, initialIsEditing: true),
            ),
          );
        },
        onToggleDuty: () {
          Navigator.pop(context);
          setState(() {
            final i = staffList.indexWhere((s) => s['id'] == staff['id']);
            if (i != -1) staffList[i]['onDuty'] = !staffList[i]['onDuty'];
          });
        },
        onRemove: () {
          Navigator.pop(context);
          _showRemoveConfirmation(context, staff);
        },
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context, Map<String, dynamic> staff) {
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
                const Icon(Icons.help_outline_rounded, color: Color(0xFF35524A), size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Remove Staff",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Are you sure you want to remove ${staff['name']} from the staff list?",
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
                        Navigator.pop(context);
                        setState(() => staffList.removeWhere((s) => s['id'] == staff['id']));
                        _showRemoveSuccess(context, staff['name'].toString());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35524A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showRemoveSuccess(BuildContext context, String name) {
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
                const Text(
                  "Staff Removed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "$name has been successfully removed.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
          child: Row(
            children: [
              const Text(
                'Employees',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E4F4F),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openAddNew,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text(
                  'Add New',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B7F),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => searchQuery = v),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: 'Search staff...',
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleIconButton(icon: Icons.search, onTap: () {}),
              const SizedBox(width: 8),
              _CircleIconButton(icon: Icons.tune, onTap: () => _scaffoldKey.currentState?.openEndDrawer()),
            ],
          ),
        ),
        Expanded(
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            thumbColor: const Color(0xFF2E4F4F).withOpacity(0.2),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
              itemCount: filteredStaff.length,
              itemBuilder: (context, index) {
                final staff = filteredStaff[index];
                return _StaffCard(
                  staff: staff,
                  onMenuTap: () => _showStaffMenu(context, staff),
                );
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      endDrawer: _buildFilterSidebar(),
      endDrawerEnableOpenDragGesture: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: const [SizedBox.shrink()],
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
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
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hello,',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400)),
                  Text('Russel Marie!',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Container(width: 1, height: 25, color: Colors.white38),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                    ),
                    Positioned(
                      top: 8, right: 10,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: topPadding + 110, // Increased height for more space
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E8B7F), Color(0xFF35524A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
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
                      'Filter Staff',
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
                        selectedRoles = {};
                        selectedStatuses = {};
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
                  _buildFilterSectionTitle('Roles'),
                  const SizedBox(height: 8),
                  ...availableRoles.map((role) {
                    bool isChecked = selectedRoles.contains(role);
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
                            if (value == true) {
                              selectedRoles.add(role);
                            } else {
                              selectedRoles.remove(role);
                            }
                          });
                        },
                        title: Text(
                          role,
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
                    'Status',
                    ['On Duty', 'Off Duty'],
                    selectedStatuses,
                    (val) {
                      setState(() {
                        if (selectedStatuses.contains(val)) {
                          selectedStatuses.remove(val);
                        } else {
                          selectedStatuses.add(val);
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
}

class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onMenuTap;

  const _StaffCard({required this.staff, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final bool onDuty = staff['onDuty'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 125,
      decoration: BoxDecoration(
        color: const Color(0xFF35524A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: staff['photo'].toString().isNotEmpty && staff['photo'].toString().startsWith('assets')
                    ? Image.asset(
                        staff['photo'].toString(),
                        width: 100, height: 100, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
                      )
                    : _buildPlaceholderPhoto(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(staff['name'].toString(),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(staff['role'].toString(),
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: onDuty ? const Color(0xFF4CAF50) : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(onDuty ? 'On Duty' : 'Off Duty',
                            style: GoogleFonts.poppins(
                              color: onDuty ? Colors.white : Colors.white54,
                              fontSize: 11
                            )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onMenuTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.more_horiz, color: Color(0xFF2E4F4F), size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      width: 100, height: 100,
      color: Colors.white.withOpacity(0.1),
      child: const Icon(Icons.person, color: Colors.white24, size: 40),
    );
  }
}

class _StaffMenuSheet extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onToggleDuty;
  final VoidCallback onRemove;

  const _StaffMenuSheet({
    required this.staff,
    required this.onView,
    required this.onEdit,
    required this.onToggleDuty,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(staff['name'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E4F4F))),
          const Divider(height: 20),
          _MenuOption(icon: Icons.visibility, label: 'View Staff Information', onTap: onView),
          _MenuOption(icon: Icons.edit,       label: 'Edit Details', onTap: onEdit),
          _MenuOption(icon: Icons.swap_horiz, label: 'Toggle Duty',  onTap: onToggleDuty),
          _MenuOption(icon: Icons.delete,     label: 'Remove Staff', onTap: onRemove, isDestructive: true),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : const Color(0xFF2E4F4F);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 14)),
      onTap: onTap,
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
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
          color: Colors.white
        ),
        child: Icon(icon, color: const Color(0xFF2E4F4F), size: 20),
      ),
    );
  }
}
