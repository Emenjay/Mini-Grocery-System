import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  // Controllers for future DB integration
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;

  // for photo picker
  File? _pickedPhoto;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialIsEditing;
    _nameController = TextEditingController(text: widget.staff['name'].toString());
    _contactController = TextEditingController(text: widget.staff['contactNumber'].toString());
    _addressController = TextEditingController(text: widget.staff['address'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      setState(() => _isEditing = false);
      _showUpdateSuccess(context, _buildUpdatedStaff());
    } else {
      setState(() => _isEditing = true);
    }
  }

  Map<String, dynamic> _buildUpdatedStaff() {
    return {
      ...widget.staff,
      'name': _nameController.text.trim(),
      'contactNumber': _contactController.text.trim(),
      'address': _addressController.text.trim(),
      if (_pickedPhoto != null) 'photo': _pickedPhoto!.path,
    };
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
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2E8B7F)),
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

  void _showUpdateSuccess(BuildContext context, Map<String, dynamic> updatedStaff) {
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
                  "Staff information has been successfully updated.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context, updatedStaff); // pop screen with updated data
                    },
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
    final bool onDuty = widget.staff['onDuty'] as bool? ?? false;
    final List shifts = widget.staff["shifts"] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.white, // Extend white background to bottom
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B7F), // Match gradient start
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
                  Text('Hello,',
                    style: GoogleFonts.poppins(
                      fontSize: 13, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w400
                    )
                  ),
                  Text('Russel Marie!', // Logged-in admin name
                    style: GoogleFonts.poppins(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  )
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
              padding: const EdgeInsets.only(bottom: 45),
              child: Column(
                children: [
                  // Back button and duty status row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF2E4F4F),
                              size: 20,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              onDuty ? 'On Duty' : 'Off Duty',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: onDuty
                                    ? const Color(0xFF7BF07F)
                                    : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Edit Staff Information',
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
                          ? FileImage(_pickedPhoto!) as ImageProvider : widget.staff['photo'].toString().startsWith('assets/')
                          ? AssetImage(widget.staff['photo'].toString()) : FileImage(File(widget.staff['photo'].toString())),

                        ),
                        
                        if (_isEditing)
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: Colors.white, size: 30),
                                Text(
                                  _pickedPhoto != null ? 'Change Photo' : 'Profile Photo',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
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
                    widget.staff['role'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(153, 236, 233, 233),
                      fontFamily: AppFonts.avenir,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
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
                  // Action Button Row
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
                  const SizedBox(height: 4),
                  if (_isEditing)
                    _buildEditableField(_contactController)
                  else
                    _SectionValue(value: _contactController.text),
                  
                  const SizedBox(height: 18),

                  const _SectionLabel(label: 'Full Address:'),
                  const SizedBox(height: 4),
                  if (_isEditing)
                    _buildEditableField(_addressController)
                  else
                    _SectionValue(value: _addressController.text),
                  
                  const SizedBox(height: 32),

                  // -- Tracked Attendance Section --
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracked Attendance',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        shifts.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No attendance records yet.',
                                  style: TextStyle(
                                    fontFamily: AppFonts.avenir,
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: shifts.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final shift = shifts[index] as Map<String, dynamic>;
                                return _AttendanceRow(shift: shift);
                              },
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
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppFonts.poppins,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }
}

class _SectionValue extends StatelessWidget {
  final String value;
  const _SectionValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 0),
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

class _AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> shift;
  const _AttendanceRow({required this.shift});

  @override
  Widget build(BuildContext context) {
    final bool isLogOut = shift['type'].toString().toLowerCase() == 'log out';

    final Color timeColor = isLogOut 
        ? const Color.fromARGB(255, 229, 57, 53) 
        : const Color.fromARGB(255, 80, 193, 84);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            shift['type'].toString(),
            style: const TextStyle(
              fontFamily: AppFonts.figtree,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                shift['time'].toString(),
                style: TextStyle(
                  fontFamily: AppFonts.figtree,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: timeColor,
                ),
              ),
              Text(
                shift['date'].toString(),
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
