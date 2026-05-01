import 'package:flutter/material.dart';
import 'package:frontend/theme/text_styles.dart';
import '../../theme/colors.dart';
import '../admin/staff_info_screen.dart';
// import 'add_staff_screen.dart';
// import 'edit_staff_screen.dart';
// -- TODO: fix temporary placeholders for add staff & edit staff


class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  String searchQuery = '';

  // Search controller lets the search icon button read & submit the field
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
 
  // Filter state - 'All' means no filter applied
  String _filterRole  = 'All'; 
  String _filterDuty  = 'All';
 
 // dispose of controllers to prevent memory leaks when the widget is destroyed
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // mock data
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
      'address': 'Brgy. New Jenshan, California',
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
    return staffList.where((s) {
      // Search (matches name or role)
      final q = searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          s['name'].toString().toLowerCase().contains(q) ||
          s['role'].toString().toLowerCase().contains(q);

      // Role filter
      final matchesRole = _filterRole == 'All' ||
          s['role'].toString() == _filterRole;
 
      // Duty filter
      final matchesDuty = _filterDuty == 'All' ||
          (_filterDuty == 'On Duty'  &&  (s['onDuty'] as bool)) ||
          (_filterDuty == 'Off Duty' && !(s['onDuty'] as bool));
 
      return matchesSearch && matchesRole && matchesDuty;
    }).toList();
  }

  // Submits the search — called by keyboard submit
  void _submitSearch() {
    setState(() => searchQuery = _searchController.text);
    _searchFocus.unfocus();
  }

  // Filter bottom sheet — role + duty toggles.
  void _openFilter() {
    // Temp variables so user can cancel without applying.
    String tempRole = _filterRole;
    String tempDuty = _filterDuty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        
                  // filter - role
                  const Text('Filter Staff',
                    style: TextStyle(
                      fontFamily: AppFonts.figtree,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkTeal,
                    )),

                  const Divider(height: 24),

                  const Text('Role',
                    style: TextStyle(
                      fontFamily: AppFonts.figtree,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkTeal,
                    )),
                    
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: ['All', 'Inventory Staff', 'Cashier'].map((role) {
                      final selected = tempRole == role;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempRole = role),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                              ? AppColors.primaryDarkTeal
                              : AppColors.surfaceLightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(role,
                            style: const TextStyle(
                              fontFamily: AppFonts.avenir,
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // filter - duty status
                  const Text('Duty Status',
                    style: TextStyle(
                      fontFamily: AppFonts.figtree,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkTeal,
                    )),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: ['All', 'On Duty', 'Off Duty'].map((duty) {
                      final selected = tempDuty == duty;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempDuty = duty),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                              ? AppColors.primaryDarkTeal
                              : AppColors.surfaceLightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(duty,
                            style: const TextStyle(
                                fontFamily: AppFonts.avenir,
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  //  Apply & Reset buttons
                  Row(
                    children: [
                      // Reset
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _filterRole = 'All';
                              _filterDuty = 'All';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                            color: AppColors.primaryDarkTeal),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Reset',
                            style: TextStyle(
                            color: AppColors.primaryDarkTeal, 
                            fontFamily: AppFonts.avenir)
                          ),

                        ),
                      ),

                      const SizedBox(width: 12),

                      // Apply
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _filterRole = tempRole;
                              _filterDuty = tempDuty;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mutedGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Apply',
                          style: TextStyle(
                            color: Colors.white, fontFamily: 
                            AppFonts.avenir)
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Add and Edit staff 
  void _openAddNew() {
    // TODO: Navigate to AddStaffScreen when ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Staff... ')),
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
          Navigator.push(context,
          MaterialPageRoute(builder: (_) => StaffInfoScreen(staff: staff)));
        },
        onEdit: () {
          Navigator.pop(context);
          // TODO: Navigate to EditStaffScreen when ready
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Staff...')),
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
          setState(() => staffList.removeWhere((s) => s['id'] == staff['id']));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mutedGreen,

      // -- APP BAR --
      appBar: AppBar(
        backgroundColor: AppColors.mutedGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 56,
              errorBuilder: (_, __, ___) => const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 28,
                child: Icon(Icons.store, color: AppColors.mutedGreen),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              
              children: [
                Text('Hello,',
                  style: TextStyle(
                    color: Colors.white70, 
                    fontFamily: AppFonts.avenir,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  )
                ),     
                Text('Russel Marie!',
                  style: TextStyle(
                    color: AppColors.white, 
                    fontFamily: AppFonts.avenir,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 1, height: 40,
              color: Colors.white38,
              margin: const EdgeInsets.only(right: 16),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15)
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 24),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // ---- BODY ----
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4.5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ---- 'Employees' heading + "Add New" button 
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        const Text(
                          'Employees',
                          style: TextStyle(
                            fontFamily: AppFonts.avenir,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkTeal,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _openAddNew,
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          label: const Text(
                            'Add New',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mutedGreen,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- SEARCH BAR & FILTER ICON ----
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLightGray.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              textInputAction: TextInputAction.search,
                              onChanged: (v) => setState(() => searchQuery = v),
                              onSubmitted: (_) => _submitSearch(),

                              style: const TextStyle(
                                fontFamily: 'Avenir',   
                                fontSize: 14,
                              ),

                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                hintText: 'Search by name or role...',

                                hintStyle: TextStyle(
                                  fontFamily: 'Avenir',  
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.tune,
                              color: AppColors.primaryDarkTeal, size: 24),
                          onPressed: _openFilter,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // ---- STAFF CARD LIST ----
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Staff card ----
class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onMenuTap;

  const _StaffCard({required this.staff, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final bool onDuty = staff['onDuty'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryLightTeal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              staff['photo'].toString(),
              width: 110,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 110,
                height: 120,
                color: AppColors.surfaceMint.withValues(alpha: 0.4),
                child: const Icon(Icons.person, color: Colors.white60, size: 48),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    staff['name'].toString(),
                    style: const TextStyle(
                      fontFamily: AppFonts.figtree,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    staff['role'].toString(),
                    style: const TextStyle(
                      color: Colors.white60, 
                      fontFamily: AppFonts.avenir,
                      fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: onDuty
                              ? const Color(0xFF4CAF50)
                              : Colors.white38,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        onDuty ? 'On Duty' : 'Off Duty',
                        style: TextStyle(
                          color: onDuty ? Colors.white : Colors.white54,
                          fontFamily: AppFonts.avenir,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '• • •',
                    style: TextStyle(
                      color: AppColors.primaryDarkTeal,
                      fontFamily: AppFonts.poppins,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Staff Menu Sheet ----
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
          Text(
            staff['name'].toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryDarkTeal,
            ),
          ),
          const Divider(height: 20),
          _MenuOption(
            icon: Icons.visibility,
            label: 'View Staff Information',
            onTap: onView,
          ),
          _MenuOption(
            icon: Icons.edit,
            label: 'Edit Details',
            onTap: onEdit,
          ),
          _MenuOption(
            icon: Icons.swap_horiz,
            label: 'Toggle Duty',
            onTap: onToggleDuty,
          ),
          _MenuOption(
            icon: Icons.delete,
            label: 'Remove Staff',
            onTap: onRemove,
            isDestructive: true,
          ),
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
    final color = isDestructive ? Colors.red : AppColors.primaryDarkTeal;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(color: color, fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
