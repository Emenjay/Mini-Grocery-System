import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminProfileScreen extends StatefulWidget {
  final bool isSubPage;

  const AdminProfileScreen({
    super.key, 
    this.isSubPage = false,
  });

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isEditing = false;

  // photo picker state variable
  File? _pickedPhoto;
  
  // Controllers for easy database integration
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Initial data matching the reference image
    _nameController = TextEditingController(text: 'Russel Marie Soliman');
    _contactController = TextEditingController(text: '0912345678');
    _addressController = TextEditingController(text: 'Brgy. New Jenshan, California');
    _usernameController = TextEditingController(text: 'dinglePM_soliman');
    _passwordController = TextEditingController(text: 'password123admin');
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

  void _toggleEdit() {
    if (_isEditing) {
      // Transition from editing to viewing
      setState(() {
        _isEditing = false;
      });
      _showUpdateSuccess(context);
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  // Photo picker method: gallery/camera options
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
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF2E8B7F)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => _pickedPhoto = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF2E8B7F)),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => _pickedPhoto = File(picked.path));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- ᴜᴘᴅᴀᴛᴇ ꜱᴜᴄᴄᴇꜱꜱ ᴍᴏᴅᴀʟ ---
  void _showUpdateSuccess(BuildContext context) {
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
                  "Update Successful",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
    return Scaffold(
      backgroundColor: Colors.white, // Ensures white background extends to bottom
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B7F), // Match gradient start
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents white line on scroll
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
                  Text('Hello,',
                    style: GoogleFonts.poppins(
                      fontSize: 13, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w400
                    )
                  ),
                  Text('Russel Marie!',
                    style: GoogleFonts.poppins(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  )
                ],
              ),
              const Spacer(),
              // Vertical line
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
                          color: Colors.red, 
                          shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Gradient Background)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E8B7F), Color(0xFF35524A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 45), // Transition overlap
              child: Column(
                children: [
                  if (_isEditing) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Edit Admin Information',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  
                  GestureDetector(
                    onTap: _isEditing ? _pickPhoto : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white24,
                          backgroundImage: _pickedPhoto != null
                            ? FileImage(_pickedPhoto!) as ImageProvider :  const AssetImage('assets/images/logo.png'),
                        ),

                        if (_isEditing)
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: Colors.white, size: 30),
                                Text(
                                  _pickedPhoto != null ? 'Change Photo' : 'Profile Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 11,
                                  )
                                     
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  if (_isEditing)
                    Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Full Name',
                        ),
                      ),
                    )
                  else
                    Text(
                      _nameController.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: AppFonts.poppins,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  Text(
                    'Admin',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(153, 236, 233, 233),
                      fontFamily: AppFonts.avenir,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Bottom Section (White Card Content)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Label and Action Button for alignment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _SectionLabel(label: 'Contact Number:'),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: _toggleEdit,
                          icon: Icon(
                            _isEditing ? Icons.check : Icons.edit, 
                            size: 14, 
                            color: Colors.white
                          ),
                          label: Text(
                            _isEditing ? 'Confirm' : 'Edit Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8B7F),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (_isEditing)
                    _buildEditableField(_contactController)
                  else
                    _SectionValue(value: _contactController.text),
                  
                  const SizedBox(height: 18),

                  const _SectionLabel(label: 'Full Address:'),
                  const SizedBox(height: 2),
                  if (_isEditing)
                    _buildEditableField(_addressController)
                  else
                    _SectionValue(value: _addressController.text),
                  
                  const SizedBox(height: 32),

                  // -- System Login Account Section --
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4F4F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'System Login Account',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _AccountField(
                          label: 'Username:', 
                          value: _usernameController.text,
                          controller: _isEditing ? _usernameController : null,
                        ),
                        const SizedBox(height: 16),
                        
                        _AccountField(
                          label: 'Password:', 
                          value: _passwordController.text,
                          isPassword: true,
                          controller: _isEditing ? _passwordController : null,
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

  Widget _buildEditableField(TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

// Helper Widgets
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SectionValue extends StatelessWidget {
  final String value;
  const _SectionValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 2),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 15,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class _AccountField extends StatefulWidget {
  final String label;
  final String value;
  final bool isPassword;
  final TextEditingController? controller;

  const _AccountField({
    required this.label, 
    required this.value, 
    this.isPassword = false,
    this.controller,
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
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.controller != null 
                ? TextField(
                    controller: widget.controller,
                    obscureText: widget.isPassword && _obscureText,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                  (widget.isPassword && _obscureText) 
                      ? '•' * (widget.value.length > 20 ? 20 : widget.value.length) 
                      : widget.value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                    color: Colors.black54, 
                    size: 20
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
