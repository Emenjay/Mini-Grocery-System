import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
// import 'edit_staff_screen.dart'; 

class StaffInfoScreen extends StatelessWidget {
  final Map<String, dynamic> staff;

  const StaffInfoScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mutedGreen,
      body: const Center(
        child: Text('Staff Info Screen...'),
      ),
    );
  }
}
