import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddStaffScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> newStaff)? onStaffAdded;
  const AddStaffScreen({super.key, this.onStaffAdded});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {

  // state variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole;
  static const List<String> _roles = ['Inventory Staff', 'Cashier'];
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _generatedUsername; 
  String? _generatedPassword;  
  bool _credentialsGenerated = false;
  File? _pickedPhoto;

  /* Generate credentials based on full name and selected role
     - Username: DinglePM_<LastName>
     - PIN: Numeric PIN with length between 4 and 6 digits.
     - displays snackbar if name or role is missing
  */
  void _generateCredentials() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the employee\'s full name first.')),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a role first.')),
      );
      return;
    }
    final parts = name.split(RegExp(r'\s+'));
    final lastName = parts.last;
    setState(() {
      _generatedUsername = 'DinglePM_$lastName';

      // PIN length: 4-6 digits
      final int pinLength = 4 + Random().nextInt(3);
      final int pinMin = pow(10, pinLength - 1).toInt();
      final int pinMax = pow(10, pinLength).toInt();
      _generatedPassword = (pinMin + Random().nextInt(pinMax - pinMin)).toString();
      _credentialsGenerated = true;
    });
  }

  // form validation
  void _submitForm() {
  if (!(_formKey.currentState?.validate() ?? false)) return;
  if (!_credentialsGenerated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please generate login credentials before saving.')),
    );
    return;
  }
  final newStaff = <String, dynamic>{
    'id': DateTime.now().millisecondsSinceEpoch,
    'name': _nameController.text.trim(),
    'role': _selectedRole,
    'onDuty': false,
    'photo': _pickedPhoto?.path ?? 'assets/images/logo.png',
    'contactNumber': '+639${_contactController.text.trim()}',
    'address': _addressController.text.trim(),
    'username': _generatedUsername,
    'shifts': <Map<String, dynamic>>[],
  };
  widget.onStaffAdded?.call(newStaff);
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Staff member added successfully! :)')),
  );
}

// Photo picker
Future<void> _pickPhoto() async {
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
                color: AppColors.primaryDarkTeal),
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
                color: AppColors.primaryDarkTeal),
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


 // dispose of controllers to prevent memory leaks when the widget is destroyed
  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();   
    _addressController.dispose(); 
    super.dispose();
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
        toolbarHeight: 89,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png',
              height: 56,
              errorBuilder: (_, __, ___) => const CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 28,
                child: Icon(Icons.store, color: AppColors.mutedGreen),
              ),
            ),

            const SizedBox(width: 12),
            
            // TODO: replace with logged-in user's name from auth state
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello,',
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: AppFonts.avenir,
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                  )
                ),
                Text('Russel Marie!',
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: AppFonts.avenir,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                    color: Colors.white.withValues(alpha:0.15),
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

      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4.5),
              decoration: BoxDecoration(
                color: AppColors.mutedGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // back button row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back,
                                      color: AppColors.primaryDarkTeal, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // screen title
                        const Text('Add New Employee',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.poppins,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )),
                        
                        // photo picker 
                        const SizedBox(height: 20),
                        _ProfilePhotoPicker(
                          photo: _pickedPhoto,
                          onTap: _pickPhoto,
                        ),
                        const SizedBox(height: 24),
              
                        // name field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _TextField(
                            controller: _nameController,
                            hintText: 'Enter Full Name',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Full name is required'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // role dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _RoleDropdown(
                            roles: _roles,
                            value: _selectedRole,
                            onChanged: (v) => setState(() => _selectedRole = v),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 8,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              _FieldLabel(label: 'Contact Number:'),
                              const SizedBox(height: 8),
                              _ContactNumberField(controller: _contactController),
                              const SizedBox(height: 20),
                              _FieldLabel(label: 'Full Address:'),
                              const SizedBox(height: 8),
                              _WhiteFormField(
                                controller: _addressController,
                                hintText: 'Enter Full Address',
                                validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Address is required'
                                  : null,
                              ),
                              const SizedBox(height: 28),
                              
                              // --- Generate button
                              Center(
                                child: ElevatedButton(
                                  onPressed: _generateCredentials,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.mutedGreen,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  
                                  child: const Text('Generate Login Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )
                                  ),
                                ),
                              ),

                              // Credentials card (visible only after generation)
                              if (_credentialsGenerated) ...[
                                const SizedBox(height: 24),
                                _SystemLoginCard(
                                  username: _generatedUsername!,
                                  password: _generatedPassword!,
                                ),
                              ],

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDarkTeal,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  
                                  child: const Text('Add Employee',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    )),
                                ),
                              ),

                              
                            ],
                          ),
                        ),
                        

                      ],
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

// -- Helper widgets --
// --- Profile photo picker placeholder
class _ProfilePhotoPicker extends StatelessWidget {
  final File? photo;
  final VoidCallback onTap;

  const _ProfilePhotoPicker({required this.onTap, this.photo});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.20),
              border: Border.all(color: Colors.white38, width: 2),

              image: photo != null
              ? DecorationImage(
                  image: FileImage(photo!),
                  fit: BoxFit.cover,
                )
              : null,
            ),

            child: photo == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 32),

                  SizedBox(height: 4),

                  Text('Profile Photo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: AppFonts.avenir,
                      fontSize: 11,
                    )
                  ),
                ],
              )
            : null,
          ),
          
          // edit badge shown after photo is picked
          if (photo != null)
            Positioned(
              bottom: 4, right: 4,
              child: Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.mutedGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}


// --- reusable _TextField with validator
class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,

      style: const TextStyle(
        color: Colors.black87,
        fontFamily: AppFonts.poppins,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.88),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontFamily: AppFonts.avenir,
          fontSize: 14,
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// --- _RoleDropdown for selecting staff role
class _RoleDropdown extends StatelessWidget {
  final List<String> roles;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _RoleDropdown({
    required this.roles,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.88),
        borderRadius: BorderRadius.circular(10),
      ),

      padding: const EdgeInsets.symmetric(horizontal: 18),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text('Choose Role',
            style: TextStyle(
              color: Colors.black38,
              fontFamily: AppFonts.avenir,
              fontSize: 14,
            )
          ),
          
          icon: const Icon(Icons.arrow_drop_down,
          color: AppColors.primaryDarkTeal),
          dropdownColor: Colors.white,
          style: const TextStyle(
    
            color: Colors.black87,
            fontFamily: AppFonts.poppins,
            fontSize: 14,
          ),

          items: roles
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
          onChanged: onChanged,
        ),
        
      ),
    );
  }
}

// --- Contact number & Full address
// _FieldLabel – bold label with underline ... for later
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
      style: const TextStyle(
        fontFamily: AppFonts.poppins,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: AppColors.primaryDarkTeal,
      )
    );
  }
}

// _ContactNumberField with +639 prefix pill and validation
class _ContactNumberField extends StatelessWidget {
  final TextEditingController controller;
  const _ContactNumberField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // "+639" prefix pill
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text('+ 639',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )),
        ),
        
        const SizedBox(width: 10),

        // validator
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            // remaining 9 digits
            maxLength: 9,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Contact number is required';
              if (v.trim().length < 9) return 'Enter 9 digits after +639';
              return null;
            },

            style: const TextStyle(
              color: Colors.black87,
              fontFamily: AppFonts.poppins,
              fontSize: 14,
            ),

            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceLightGray.withValues(alpha: .4),
              hintText: 'Enter Contact Number',
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontFamily: AppFonts.avenir,
                fontSize: 13,
              ),

              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),

            ),
          ),
        ),
      ],
    );
  }
}

// _WhiteFormField - generic white field (used for address, etc.)
class _WhiteFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const _WhiteFormField({
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        color: Colors.black87,
        fontFamily: AppFonts.poppins,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceLightGray.withValues(alpha: .4),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontFamily: AppFonts.avenir,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// --- 'Generate Login Account' button and System Login Account card
class _SystemLoginCard extends StatelessWidget {
  final String username;
  final String password;

  const _SystemLoginCard({
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(

            child: Text('System Login Account',
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppFonts.poppins,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
          ),

          const SizedBox(height: 16),
          const Text('Username:',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: AppFonts.avenir,
              fontSize: 12,
            )),
          const SizedBox(height: 6),
          _CredentialDisplay(value: username), // reusable credential row

          const SizedBox(height: 14),

          const Text('PIN:',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: AppFonts.avenir,
              fontSize: 12,
            )),
          const SizedBox(height: 6),
          _CredentialDisplay(value: password),
        ],
      ),
    );
  }
}

// u da real credential display
class _CredentialDisplay extends StatelessWidget {
  final String value;
  const _CredentialDisplay({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Text(value,
        style: const TextStyle(
          color: Colors.black87,
          fontFamily: AppFonts.poppins,
          fontSize: 14,
        )
      ),
    );
  }
}

/* 
_CredentialDisplay shows login credentials (username/password) that the 
system generated for the new staff member.
*/