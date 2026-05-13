import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'staff_info_screen.dart';
import 'add_staff_screen.dart';
import '../../services/staff_service.dart';

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
  String? selectedStatus; // 'On Duty', 'Off Duty'
  String? selectedSort; // 'A-Z', 'Z-A'

  final List<String> availableRoles = ['Inventory Staff', 'Cashier'];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);

    String roleParam = '';
    if (selectedRoles.length == 1) {
      final r = selectedRoles.first;
      roleParam = (r == 'Inventory Staff') ? 'Inventory' : 'Cashier';
    }

    final result = await StaffService.getAllStaff(
      search: searchQuery,
      role: roleParam,
    );

    if (!mounted) return;
    if (result['success']) {
      setState(() {
        _staffList = List<Map<String, dynamic>>.from(result['users'] ?? []);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'];
        _isLoading = false;
      });
    }
  }

  bool _isOnDuty(Map<String, dynamic> staff) {
    final val = staff['is_on_duty'];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val == '1' || val.toLowerCase() == 'true';
    return false;
  }

  List<Map<String, dynamic>> get filteredStaff {
    List<Map<String, dynamic>> filtered = _staffList.where((s) {
      if (selectedStatus == null) return true;
      final bool onDuty = _isOnDuty(s);
      return (selectedStatus == 'On Duty' && onDuty) ||
             (selectedStatus == 'Off Duty' && !onDuty);
    }).toList();

    if (selectedSort == 'A-Z') {
      filtered.sort((a, b) => (a['full_name'] ?? '').compareTo(b['full_name'] ?? ''));
    } else if (selectedSort == 'Z-A') {
      filtered.sort((a, b) => (b['full_name'] ?? '').compareTo(a['full_name'] ?? ''));
    }
    return filtered;
  }

  void _submitSearch() {
    setState(() => searchQuery = _searchController.text);
    _searchFocus.unfocus();
    _fetchStaff();
  }

  void _openAddNew() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffScreen(onStaffAdded: (_) => _fetchStaff())));
  }

  void _showStaffMenu(BuildContext context, Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _StaffMenuSheet(
        staff: staff,
        onView: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => StaffInfoScreen(staff: staff)))
              .then((_) => _fetchStaff()); // refresh after returning (e.g. after edit)
        },
        onEdit: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => StaffInfoScreen(staff: staff, initialIsEditing: true)))
              .then((_) => _fetchStaff());
        },
        onToggleDuty: () {
          Navigator.pop(context);
          setState(() {
            final i = _staffList.indexWhere((s) => s['user_id'] == staff['user_id']);
            if (i != -1) {
              _staffList[i]['is_on_duty'] = _isOnDuty(_staffList[i]) ? 0 : 1;
            }
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
                const Text("Remove Staff", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Are you sure you want to remove ${staff['full_name'] ?? ''} from the staff list?",
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await StaffService.deactivateStaff(staff['user_id']);
                        if (!mounted) return;
                        if (result['success']) {
                          _fetchStaff();
                          _showRemoveSuccess(context, staff['full_name'] ?? '');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'] ?? 'Failed to remove staff')),
                          );
                        }
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _staffList.removeWhere((s) => s['user_id'] == staff['user_id']));
                        _showRemoveSuccess(context, staff['full_name'] ?? '');
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
                const Text("Staff Removed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("$name has been successfully removed.", textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
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
                ),
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
              const Text('Employees', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF2E4F4F))),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openAddNew,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B7F),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    onSubmitted: (_) => _submitSearch(),
                    controller: _searchController,
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
              _CircleIconButton(icon: Icons.search, onTap: _submitSearch),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3E5C51)))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : filteredStaff.isEmpty
                        ? const Center(child: Text("No staff found"))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                            itemCount: filteredStaff.length,
                            itemBuilder: (context, index) {
                              final staff = filteredStaff[index];
                              return _StaffCard(
                                staff: staff,
                                onDuty: _isOnDuty(staff),
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
                child: const CircleAvatar(radius: 22, backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/logo.png')),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hello,', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400)),
                  Text('Russel Marie!', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                      child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
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
          Container(height: topPadding + 110, decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF2E8B7F), Color(0xFF35524A)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          )),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              child: mainContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar() {
    Set<String> tempRoles = Set.from(selectedRoles);
    String? tempStatus = selectedStatus;
    String? tempSort = selectedSort;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
      ),
      child: StatefulBuilder(
        builder: (context, setDrawerState) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filters", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF35524A))),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedRoles = {};
                            selectedStatus = null;
                            selectedSort = null;
                          });
                          setDrawerState(() {
                            tempRoles = {};
                            tempStatus = null;
                            tempSort = null;
                          });
                          _fetchStaff();
                        },
                        child: Text("Reset", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterSectionTitle('Roles'),
                      const SizedBox(height: 8),
                      ...availableRoles.map((role) => CheckboxListTile(
                        value: tempRoles.contains(role),
                        onChanged: (value) {
                          setDrawerState(() {
                            if (value == true) tempRoles.add(role);
                            else tempRoles.remove(role);
                          });
                        },
                        title: Text(role, style: GoogleFonts.poppins(fontSize: 14,
                          color: tempRoles.contains(role) ? const Color(0xFF2F3E46) : Colors.black54,
                          fontWeight: tempRoles.contains(role) ? FontWeight.bold : FontWeight.w500)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF35524A),
                        dense: true,
                      )),
                      const SizedBox(height: 10),
                      _buildFilterSectionTitle('Status'),
                      _buildRadioOption('All', null, tempStatus, (val) => setDrawerState(() => tempStatus = val)),
                      _buildRadioOption('On Duty', 'On Duty', tempStatus, (val) => setDrawerState(() => tempStatus = val)),
                      _buildRadioOption('Off Duty', 'Off Duty', tempStatus, (val) => setDrawerState(() => tempStatus = val)),
                      const SizedBox(height: 30),
                      const Divider(),
                      _buildFilterSectionTitle('Sort Alphabetically'),
                      const SizedBox(height: 5),
                      _buildRadioOption('A-Z', 'A-Z', tempSort, (val) => setDrawerState(() => tempSort = val)),
                      _buildRadioOption('Z-A', 'Z-A', tempSort, (val) => setDrawerState(() => tempSort = val)),
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
                      onPressed: () {
                        setState(() {
                          selectedRoles = tempRoles;
                          selectedStatus = tempStatus;
                          selectedSort = tempSort;
                        });
                        _fetchStaff();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35524A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Apply Filters', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF35524A)));

  Widget _buildRadioOption(String label, String? value, String? groupValue, Function(String?) onChanged) {
    return RadioListTile<String?>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label, style: GoogleFonts.poppins(fontSize: 15,
        color: groupValue == value ? const Color(0xFF2F3E46) : Colors.black54,
        fontWeight: groupValue == value ? FontWeight.bold : FontWeight.w500)),
      activeColor: const Color(0xFF35524A),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

// ---- Staff card ----
class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onMenuTap;
  final bool onDuty;

  const _StaffCard({required this.staff, required this.onMenuTap, required this.onDuty});

  @override
  Widget build(BuildContext context) {
    // Determine photo source (profile_picture from backend, or photo from UI)
    String? photoPath = staff['profile_picture'] ?? staff['photo'];
    Widget photoWidget;
    if (photoPath != null && photoPath.isNotEmpty) {
      if (photoPath.startsWith('assets/')) {
        photoWidget = Image.asset(photoPath, width: 100, height: 100, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderPhoto());
      } else if (File(photoPath).existsSync()) {
        photoWidget = Image.file(File(photoPath), width: 100, height: 100, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderPhoto());
      } else {
        photoWidget = _buildPlaceholderPhoto();
      }
    } else {
      photoWidget = _buildPlaceholderPhoto();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 125,
      decoration: BoxDecoration(
        color: const Color(0xFF35524A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: photoWidget),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(staff['full_name'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(staff['role_name'] ?? '', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: onDuty ? const Color(0xFF4CAF50) : Colors.white38)),
                          const SizedBox(width: 6),
                          Text(onDuty ? 'On Duty' : 'Off Duty', style: GoogleFonts.poppins(color: onDuty ? Colors.white : Colors.white54, fontSize: 11)),
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
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.more_horiz, color: Color(0xFF2E4F4F), size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(width: 100, height: 100, color: Colors.white.withOpacity(0.1),
      child: const Icon(Icons.person, color: Colors.white24, size: 40));
  }
}

class _StaffMenuSheet extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onToggleDuty;
  final VoidCallback onRemove;

  const _StaffMenuSheet({required this.staff, required this.onView, required this.onEdit, required this.onToggleDuty, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(staff['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E4F4F))),
          const Divider(height: 20),
          _MenuOption(icon: Icons.visibility, label: 'View Staff Information', onTap: onView),
          _MenuOption(icon: Icons.edit, label: 'Edit Details', onTap: onEdit),
          _MenuOption(icon: Icons.swap_horiz, label: 'Toggle Duty', onTap: onToggleDuty),
          _MenuOption(icon: Icons.delete, label: 'Remove Staff', onTap: onRemove, isDestructive: true),
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

  const _MenuOption({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

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
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12), color: Colors.white),
        child: Icon(icon, color: const Color(0xFF2E4F4F), size: 20),
      ),
    );
  }
}