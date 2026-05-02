import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';

class AddStaffScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> newStaff)? onStaffAdded;
  const AddStaffScreen({super.key, this.onStaffAdded});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
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
                    const SizedBox(height: 20),
                    
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}