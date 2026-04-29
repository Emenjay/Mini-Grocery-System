import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class StaffListScreen extends StatefulWidget {
  final bool isSubPage;
  const StaffListScreen({super.key, this.isSubPage = false});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  String searchQuery = '';

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
    if (searchQuery.isEmpty) return staffList;
    return staffList.where((s) {
      final q = searchQuery.toLowerCase();
      return s['name'].toString().toLowerCase().contains(q) ||
          s['role'].toString().toLowerCase().contains(q);
    }).toList();
  }

  void _openAddNew() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add New Staff', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Coming soon!!', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
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
        },
        onEdit: () => Navigator.pop(context),
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
    Widget content = Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Text(
                        'Employees',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLightTeal,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _openAddNew,
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: Text(
                          'Add New',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mutedGreen,
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLightGray.withAlpha(102),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => searchQuery = v),
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              hintText: 'Search staff...',
                              hintStyle: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.primaryDarkTeal, size: 24),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.tune, color: AppColors.primaryDarkTeal, size: 24),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    );

    if (widget.isSubPage) {
      return Scaffold(
        backgroundColor: AppColors.mutedGreen,
        body: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mutedGreen,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello,',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14,
                         fontWeight: FontWeight.w400)),
                Text('Russel Marie!',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20,
                         fontWeight: FontWeight.bold)),
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
                    color: Colors.white.withAlpha(38),
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
      body: content,
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
      margin: const EdgeInsets.only(bottom: 12),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryLightTeal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20),
          blurRadius: 6, offset: const Offset(0, 2)),
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
              width: 110, height: 120, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 110, height: 120,
                color: AppColors.surfaceMint.withAlpha(102),
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
                  Text(staff['name'].toString(),
                  style: GoogleFonts.poppins(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(staff['role'].toString(),
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: onDuty
                                ? const Color(0xFF4CAF50)
                                : Colors.white38,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(onDuty ? 'On Duty' : 'Off Duty',
                        style: GoogleFonts.poppins(
                        color: onDuty ? Colors.white : Colors.white54,
                        fontSize: 12)),
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
                  child: Text('• • •',
                    style: GoogleFonts.poppins(color: AppColors.primaryDarkTeal,
                        fontSize: 10, fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                ),
              ),
            ),
          ),
        ],
      ),
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
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold,
            fontSize: 16, color: AppColors.primaryDarkTeal)),
          const Divider(height: 20),
          _MenuOption(icon: Icons.visibility, label: 'View Profile', onTap: onView),
          _MenuOption(icon: Icons.edit,       label: 'Edit Details', onTap: onEdit),
          _MenuOption(icon: Icons.swap_horiz, label: 'Toggle Duty',  onTap: onToggleDuty),
          _MenuOption(icon: Icons.delete,     label: 'Remove Staff', onTap: onRemove,
          isDestructive: true),
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
      title: Text(label, style: GoogleFonts.poppins(color: color, fontSize: 14)),
      onTap: onTap,
    );
  }
}
