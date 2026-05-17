import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../services/staff_service.dart';
import '../../utils/app_state.dart';
import '../../utils/constants.dart';

class StaffInfoScreen extends StatefulWidget {
  final Map<String, dynamic> staff;
  final bool initialIsEditing;

  const StaffInfoScreen({
    super.key,
    required this.staff,
    this.initialIsEditing = false,
  });

  @override
  State<StaffInfoScreen> createState() => _StaffInfoScreenState();
}

class _StaffInfoScreenState extends State<StaffInfoScreen> {
  late bool _isEditing;
  List<dynamic> _attendance = [];
  bool _loadingAttendance = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  final TextEditingController _newPinController = TextEditingController();
  bool _showPin = false; // toggles PIN visibility

  File? _pickedPhoto;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialIsEditing;
    _nameController = TextEditingController(text: widget.staff['full_name'] ?? '');

    final rawContact = widget.staff['contact_number']?.toString() ?? '';
    final contactDigits = rawContact.startsWith('+639')
        ? rawContact.substring(4)
        : rawContact.startsWith('639')
            ? rawContact.substring(3)
            : rawContact;
    _contactController = TextEditingController(text: contactDigits);
    _addressController = TextEditingController(text: widget.staff['address'] ?? '');
    _loadAttendance();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  // resolves profile photo — handles relative backend paths, full URLs, local files
  ImageProvider? _resolvePhoto(dynamic photoValue) {
    final String? path = photoValue?.toString();
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    // relative path from backend e.g. 'uploads/profiles/profile-123.jpg'
    if (path.startsWith('uploads/')) {
      return NetworkImage('${AppConstants.baseUrl}/$path');
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (File(path).existsSync()) {
      return FileImage(File(path));
    }
    return null;
  }

  Future<void> _loadAttendance() async {
    final result = await StaffService.getStaffByID(widget.staff['user_id']);
    if (!mounted) return;
    setState(() {
      _attendance = result['attendance'] ?? [];
      _loadingAttendance = false;
    });
  }

  Future<void> _updateStaff() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final result = await StaffService.updateStaff(
      id: widget.staff['user_id'],
      fullName: _nameController.text.trim(),
      contactNumber: '+639${_contactController.text.trim()}',
      address: _addressController.text.trim(),
      // only send password if admin typed a new PIN
      password: _newPinController.text.trim().isNotEmpty
          ? _newPinController.text.trim()
          : null,
      profilePicture: _pickedPhoto,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success']) {
      final updatedStaff = {
        ...widget.staff,
        'full_name': _nameController.text.trim(),
        'contact_number': '+639${_contactController.text.trim()}',
        'address': _addressController.text.trim(),
        if (_pickedPhoto != null) 'profile_picture': _pickedPhoto!.path,
      };
      _newPinController.clear(); // clear PIN field after save
      _showUpdateSuccess(context, updatedStaff);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update')),
      );
    }
  }

  void _toggleEdit() async {
    if (_isEditing) {
      await _updateStaff();
    } else {
      setState(() => _isEditing = true);
    }
  }

  Future<void> _pickPhoto() async {
    if (!_isEditing) return;
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2E8B7F)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) setState(() => _pickedPhoto = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2E8B7F)),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (picked != null) setState(() => _pickedPhoto = File(picked.path));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUpdateSuccess(BuildContext context, Map<String, dynamic> updatedStaff) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2D936C), size: 60),
                const SizedBox(height: 16),
                const Text("Update Successful", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Staff information has been successfully updated.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _isEditing = false);
                      Navigator.pop(context, updatedStaff);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  bool _parseOnDuty() {
    final val = widget.staff['is_on_duty'];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val == '1' || val.toLowerCase() == 'true';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool onDuty = _parseOnDuty();
    final List shifts = _attendance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B7F),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
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
                  Text('Hello,', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w400)),
                  Text('${AppState.userName}!', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── gradient header ──────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E8B7F), Color(0xFF35524A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 45),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38, height: 38,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back, color: Color(0xFF2E4F4F), size: 20),
                            ),
                          ),
                          Row(
                            children: [
                              Text(onDuty ? 'On Duty' : 'Off Duty',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: onDuty ? const Color(0xFF7BF07F) : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 5),
                      Text('Edit Staff Information',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 15),

                    // profile photo
                    GestureDetector(
                      onTap: _isEditing ? _pickPhoto : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white24,
                            backgroundImage: _pickedPhoto != null
                                ? FileImage(_pickedPhoto!) as ImageProvider
                                : _resolvePhoto(widget.staff['profile_picture']),
                            child: (_pickedPhoto == null &&
                                    _resolvePhoto(widget.staff['profile_picture']) == null)
                                ? const Icon(Icons.person, color: Colors.white38, size: 50)
                                : null,
                          ),
                          if (_isEditing)
                            Container(
                              width: 130, height: 130,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, color: Colors.white, size: 30),
                                  Text(_pickedPhoto != null ? 'Change Photo' : 'Profile Photo',
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // name (editable inline when editing)
                    if (_isEditing)
                      Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                          decoration: const InputDecoration(
                              border: InputBorder.none, isDense: true, hintText: 'Full Name'),
                        ),
                      )
                    else
                      Text(_nameController.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),

                    const SizedBox(height: 4),
                    Text(widget.staff['role_name']?.toString() ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color.fromARGB(153, 236, 233, 233),
                            fontFamily: AppFonts.avenir,
                            fontSize: 14)),
                    const SizedBox(height: 15),
                  ],
                ),
              ),

              // ── white card body ──────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                transform: Matrix4.translationValues(0, -30, 0),
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // edit / confirm button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _toggleEdit,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Icon(_isEditing ? Icons.check : Icons.edit,
                                    size: 14, color: Colors.white),
                            label: Text(
                              _isSaving
                                  ? 'Saving...'
                                  : (_isEditing ? 'Confirm' : 'Edit Account'),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8B7F),
                              disabledBackgroundColor:
                                  const Color(0xFF2E8B7F).withOpacity(0.5),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // contact number
                    const _SectionLabel(label: 'Contact Number:'),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      _ContactNumberField(controller: _contactController)
                    else
                      _SectionValue(value: '+639${_contactController.text}'),

                    const SizedBox(height: 18),

                    // address
                    const _SectionLabel(label: 'Full Address:'),
                    const SizedBox(height: 4),
                    if (_isEditing)
                      TextFormField(
                        controller: _addressController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontFamily: AppFonts.poppins,
                            fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          hintText: 'Enter Full Address',
                          hintStyle: const TextStyle(
                              color: Colors.black38,
                              fontFamily: AppFonts.avenir,
                              fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.redAccent)),
                        ),
                      )
                    else
                      _SectionValue(value: _addressController.text),

                    const SizedBox(height: 32),

                    // ── login credentials card ────────────────────────────
                    const Text(
                      'LOGIN CREDENTIALS',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // username row — read-only (admin changes username via their own profile)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.person_outline_rounded,
                                      size: 16, color: Color(0xFF2E8B7F)),
                                ),
                                const SizedBox(width: 12),
                                const Text('Username',
                                    style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 12,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Text(
                                  widget.staff['username']?.toString() ?? '—',
                                  style: const TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),

                          const Divider(
                              height: 1, indent: 16, endIndent: 16,
                              color: Color(0xFFEEEEEE)),

                          // PIN row — censored by default, editable when editing
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.tag_rounded,
                                      size: 16, color: Color(0xFF2E8B7F)),
                                ),
                                const SizedBox(width: 12),
                                const Text('PIN',
                                    style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 12,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w500)),
                                const Spacer(),
                                if (_isEditing)
                                  // when editing, show a text field for new PIN
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: _newPinController,
                                      // numeric keyboard for PIN entry
                                      keyboardType: TextInputType.number,
                                      obscureText: !_showPin,
                                      style: const TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 13,
                                          color: Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: 'New PIN (optional)',
                                        hintStyle: const TextStyle(
                                            color: Colors.black26,
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 11),
                                        filled: true,
                                        fillColor: const Color(0xFFF5F5F5),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                        // toggle show/hide PIN
                                        suffixIcon: GestureDetector(
                                          onTap: () => setState(
                                              () => _showPin = !_showPin),
                                          child: Icon(
                                            _showPin
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 16,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  // not editing — show censored dots for the PIN
                                  Row(
                                    children: [
                                      Text(
                                        '••••••',
                                        style: const TextStyle(
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 4,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 33),

                    // ── tracked attendance ────────────────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppColors.primaryLightTeal,
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tracked Attendance',
                              style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _loadingAttendance
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : shifts.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Text(
                                            'No attendance records yet.',
                                            style: TextStyle(
                                                fontFamily: AppFonts.avenir,
                                                color: Colors.white54,
                                                fontSize: 13)),
                                      ))
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: shifts.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) =>
                                          _AttendanceRow(
                                              shift: shifts[index]
                                                  as Map<String, dynamic>),
                                    ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── helper widgets (unchanged styling) ──────────────────────────────────────

class _ContactNumberField extends StatelessWidget {
  final TextEditingController controller;
  const _ContactNumberField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: const Color(0xFF2E8B7F),
              borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: const Text('+ 639',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 9,
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'Contact number is required';
              if (v.trim().length < 9) return 'Enter 9 digits after +639';
              return null;
            },
            style: const TextStyle(
                color: Colors.black87,
                fontFamily: AppFonts.poppins,
                fontSize: 14),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              hintText: 'Enter Contact Number',
              hintStyle: const TextStyle(
                  color: Colors.black38,
                  fontFamily: AppFonts.avenir,
                  fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.redAccent)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontFamily: AppFonts.poppins,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87));
}

class _SectionValue extends StatelessWidget {
  final String value;
  const _SectionValue({required this.value});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(left: 14, top: 0),
      child: Text(value,
          style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 15,
              color: Colors.black54)));
}

class _AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> shift;
  const _AttendanceRow({required this.shift});

  String formatTime(String? ts) {
    if (ts == null) return 'N/A';
    final dt = DateTime.tryParse(ts);
    if (dt == null) return 'N/A';
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  String formatDate(String? ts) {
    if (ts == null) return 'N/A';
    final dt = DateTime.tryParse(ts);
    if (dt == null) return 'N/A';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final clockIn = shift['clock_in_timestamp'];
    final clockOut = shift['clock_out_timestamp'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Clock In',
                style: TextStyle(
                    fontFamily: AppFonts.figtree,
                    fontSize: 13,
                    color: Colors.black87)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(formatTime(clockIn?.toString()),
                  style: const TextStyle(
                      fontFamily: AppFonts.figtree,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 80, 193, 84))),
              Text(formatDate(clockIn?.toString()),
                  style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 10,
                      color: Colors.black45)),
            ]),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Clock Out',
                style: TextStyle(
                    fontFamily: AppFonts.figtree,
                    fontSize: 13,
                    color: Colors.black87)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                clockOut != null
                    ? formatTime(clockOut.toString())
                    : 'Still on duty',
                style: TextStyle(
                    fontFamily: AppFonts.figtree,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: clockOut != null
                        ? const Color.fromARGB(255, 229, 57, 53)
                        : Colors.orange),
              ),
              if (clockOut != null)
                Text(formatDate(clockOut.toString()),
                    style: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 10,
                        color: Colors.black45)),
            ]),
          ]),
        ],
      ),
    );
  }
}