import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import './staff_list_screen.dart';
// import 'edit_staff_screen.dart'; 

class StaffInfoScreen extends StatelessWidget {
  final Map<String, dynamic> staff;

  const StaffInfoScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    final bool onDuty = staff['onDuty'] as bool;
    final List shifts = staff["shifts"] as List? ?? [];
 
    return Scaffold(
      backgroundColor: AppColors.mutedGreen,

      // -- app bar --
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

            const SizedBox(width:12),

            // TODO: replace hardcoded logged-in user's name
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello,',
                style: TextStyle(
                  color: AppColors.white, 
                  fontSize: 14, 
                  fontWeight:FontWeight.w400
                )),

                Text('Russel Marie!',
                style: TextStyle(
                  color: AppColors.white, 
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ))
              ],

            ),

            const Spacer(),

            Container(
              width: 1,
              height: 40,
              color: Colors.white38,
              margin: const EdgeInsets.only(right: 16),
            ),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 24),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red, 
                      shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // -- body --
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
                    // ── back button & duty status ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              
                              // back button
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: AppColors.primaryDarkTeal,
                                    size: 20,
                                  ),
                                ),
                              ),

                              // Duty status
                              Row(
                                children: [
                                  Text(
                                    onDuty ? 'On Duty' : 'Off Duty',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: onDuty
                                          ? const Color.fromARGB(255, 123, 240, 127)
                                          : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          // -- Profile section (image, name, role)
                          const CircleAvatar(
                            radius: 72,
                            backgroundImage: AssetImage('assets/images/logo.png'),
                          ),
                          
                          const SizedBox(height: 16),
    
                          // name
                          Text(
                            staff['name'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // role
                          Text(
                            staff['role'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}
