import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_state.dart';
import '../../utils/constants.dart';
import '../../services/staff_service.dart';

class AdminProfileScreen extends StatefulWidget {
  final bool isSubPage;
  const AdminProfileScreen({super.key, this.isSubPage = false});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoadingProfile = true;
  File? _pickedPhoto;

  // loaded from backend on initState
  String? _profilePicturePath;

  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _usernameController;
  // blank = keep existing password, filled = change to this
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    // initialise with whatever AppState has so screen isn't blank while loading
    _nameController     = TextEditingController(text: AppState.userName);
    _contactController  = TextEditingController();
    _addressController  = TextEditingController();
    _usernameController = TextEditingController(
        text: AppState.user?['username']?.toString() ?? '');
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // fetch full admin profile from backend to get contact, address, profile picture
  Future<void> _loadProfile() async {
    final result = await StaffService.getStaffByID(AppState.userID);
    if (!mounted) return;

    if (result['success']) {
      final user = result['user'] as Map<String, dynamic>;
      setState(() {
        _nameController.text     = user['full_name']?.toString()     ?? AppState.userName;
        _usernameController.text = user['username']?.toString()       ?? '';
        _profilePicturePath      = user['profile_picture']?.toString();

        // strip +639 prefix for display in the contact field if present
        final raw = user['contact_number']?.toString() ?? '';
        _contactController.text = raw.startsWith('+639')
            ? raw.substring(4)
            : raw.startsWith('639')
                ? raw.substring(3)
                : raw;

        _addressController.text = user['address']?.toString() ?? '';
        _isLoadingProfile = false;
      });
    } else {
      // couldn't load - just stop the spinner and show what AppState has
      setState(() => _isLoadingProfile = false);
    }
  }

  // resolves profile picture: backend relative path, full URL, local file, or null
  ImageProvider? _resolvePhoto() {
    // newly picked local file takes priority
    if (_pickedPhoto != null) return FileImage(_pickedPhoto!);

    final path = _profilePicturePath;
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    // relative backend path e.g. 'uploads/profiles/profile-123.jpg'
    if (path.startsWith('uploads/')) {
      return NetworkImage('${AppConstants.baseUrl}/$path');
    }
    if (path.startsWith('assets/')) return AssetImage(path);
    if (File(path).existsSync()) return FileImage(File(path));
    return null;
  }

  Future<void> _pickPhoto() async {
    if (!_isEditing) return;
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF2E8B7F)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 80);
                if (picked != null)
                  setState(() => _pickedPhoto = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF2E8B7F)),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 80);
                if (picked != null)
                  setState(() => _pickedPhoto = File(picked.path));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final newPassword = _passwordController.text.trim();

    final result = await StaffService.updateStaff(
      id: AppState.userID,
      fullName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      // send full number with country code
      contactNumber: _contactController.text.trim().isNotEmpty
          ? '+639${_contactController.text.trim()}'
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      username: _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : null,
      // blank = keep existing password
      password: newPassword.isNotEmpty ? newPassword : null,
      // null = keep existing photo, File = upload new and delete old
      profilePicture: _pickedPhoto,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success']) {
      // update AppState so the header name refreshes immediately
      if (_nameController.text.trim().isNotEmpty) {
        AppState.user?['fullName'] = _nameController.text.trim();
      }
      // update local path so avatar shows new photo without re-fetching
      if (_pickedPhoto != null) {
        _profilePicturePath = _pickedPhoto!.path;
        _pickedPhoto = null;
      }
      _passwordController.clear();
      setState(() => _isEditing = false);
      _showUpdateSuccess(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update profile')),
      );
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _showUpdateSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Color(0xFF2D936C), size: 60),
              const SizedBox(height: 16),
              const Text("Update Successful",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Your account information has been successfully updated.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35524A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Close",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _resolvePhoto();

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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png')),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hello,',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w400)),
                  Text('${AppState.userName}!',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white, size: 20),
                    ),
                    Positioned(
                      top: 8,
                      right: 10,
                      child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoadingProfile
          // show spinner while fetching real profile data
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── gradient header ────────────────────────────────────
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
                        if (_isEditing) ...[
                          const SizedBox(height: 5),
                          Text(
                            'Edit Admin Information',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 15),
                        // avatar — tappable when editing
                        GestureDetector(
                          onTap: _isEditing ? _pickPhoto : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.white24,
                                backgroundImage: photo,
                                // show person icon when no photo at all
                                child: photo == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white38, size: 50)
                                    : null,
                              ),
                              if (_isEditing)
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add,
                                          color: Colors.white, size: 30),
                                      Text(
                                        _pickedPhoto != null
                                            ? 'Change Photo'
                                            : 'Profile Photo',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // name — inline text field when editing
                        if (_isEditing)
                          Container(
                            width: 250,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: TextField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Full Name'),
                            ),
                          )
                        else
                          Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : AppState.userName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: AppFonts.poppins,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 4),
                        const Text(
                          'Admin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromARGB(153, 236, 233, 233),
                              fontFamily: AppFonts.avenir,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // ── white card body ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30))),
                    transform: Matrix4.translationValues(0, -30, 0),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // edit / confirm button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _SectionLabel(label: 'Contact Number:'),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : _toggleEdit,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2))
                                    : Icon(
                                        _isEditing ? Icons.check : Icons.edit,
                                        size: 14,
                                        color: Colors.white),
                                label: Text(
                                  _isSaving
                                      ? 'Saving...'
                                      : (_isEditing
                                          ? 'Confirm'
                                          : 'Edit Account'),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // contact number
                        if (_isEditing)
                          _ContactNumberField(controller: _contactController)
                        else
                          _SectionValue(
                            value: _contactController.text.isEmpty
                                ? 'Not set'
                                : '+639${_contactController.text}',
                          ),

                        const SizedBox(height: 18),
                        const _SectionLabel(label: 'Full Address:'),
                        const SizedBox(height: 4),
                        if (_isEditing)
                          _buildEditableField(_addressController,
                              hint: 'Enter Full Address')
                        else
                          _SectionValue(
                              value: _addressController.text.isEmpty
                                  ? 'Not set'
                                  : _addressController.text),

                        const SizedBox(height: 32),

                        // ── system login card ──────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: const Color(0xFF2E4F4F),
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'System Login Account',
                                style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),

                              // username field
                              _AccountField(
                                label: 'Username:',
                                value: _usernameController.text,
                                controller:
                                    _isEditing ? _usernameController : null,
                              ),
                              const SizedBox(height: 16),

                              // password field — number pad, blank = keep existing
                              _AccountField(
                                label: 'Password / PIN:',
                                value: '••••••••',
                                isPassword: true,
                                // number pad so PIN entry is easier
                                keyboardType: TextInputType.number,
                                controller:
                                    _isEditing ? _passwordController : null,
                                hintText: _isEditing
                                    ? 'Leave blank to keep current'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(TextEditingController controller,
      {String hint = ''}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle:
              const TextStyle(color: Colors.black38, fontSize: 13),
        ),
      ),
    );
  }
}

// ── helper widgets ──────────────────────────────────────────────────────────

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
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 9,
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
      padding: const EdgeInsets.only(left: 14, top: 2),
      child: Text(value,
          style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 15,
              color: Colors.black54)));
}

class _AccountField extends StatefulWidget {
  final String label;
  final String value;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? hintText;

  const _AccountField({
    required this.label,
    required this.value,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.hintText,
  });

  @override
  State<_AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<_AccountField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Expanded(
                child: widget.controller != null
                    ? TextField(
                        controller: widget.controller,
                        obscureText: widget.isPassword && _obscureText,
                        // number pad for password/PIN field
                        keyboardType: widget.keyboardType,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontFamily: AppFonts.poppins),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: widget.hintText,
                          hintStyle: const TextStyle(
                              color: Colors.black38, fontSize: 13),
                        ),
                      )
                    : Text(
                        (widget.isPassword && _obscureText)
                            ? '•' *
                                (widget.value.length > 20
                                    ? 20
                                    : widget.value.length)
                            : widget.value,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontFamily: AppFonts.poppins),
                      ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  onTap: () =>
                      setState(() => _obscureText = !_obscureText),
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}