import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../theme/text_styles.dart';
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
                  fontFamily: AppFonts.avenir,
                  fontSize: 14, 
                  fontWeight:FontWeight.w100
                )),
                Text('Russel Marie!',
                style: TextStyle(
                  color: AppColors.white, 
                  fontFamily: AppFonts.avenir,
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
                    color: Colors.white.withOpacity(0.15),
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
                                      fontFamily: AppFonts.avenir,
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
                              fontFamily: AppFonts.poppins,
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
                              color: Color.fromARGB(153, 236, 233, 233),
                              fontFamily: AppFonts.avenir,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // -- white card container --
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Edit Account button
                                Align(
                                  alignment: Alignment.topRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Edit Account...')),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                    label: const Text(
                                      'Edit Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
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
                                ),
                                const SizedBox(height: 8),

                                // contact number
                                _SectionLabel(label: 'Contact Number:'),
                                const SizedBox(height: 6),
                                _SectionValue(value: staff['contactNumber'].toString()),
                                const SizedBox(height: 16),

                                // full address
                                _SectionLabel(label: 'Full Address:'),
                                const SizedBox(height: 6),
                                _SectionValue(value: staff['address'].toString()),
                                const SizedBox(height: 24),

                                // -- Tracked attendance section --
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLightTeal,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tracked Attendance',
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // attendance rows
                                      shifts.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Center(
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
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            final shift = shifts[index]
                                                as Map<String, dynamic>;
                                            return _AttendanceRow(shift: shift);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// Helper Widgets
// Section label with underline
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
            color: AppColors.primaryDarkTeal,
          ),
        ),
        Container(
          width: 120,
          height: 1,
          color: AppColors.surfaceLightGray,
          margin: const EdgeInsets.only(top: 4),
        ),
      ],
    );
  }
}

// Section value (indented)
class _SectionValue extends StatelessWidget {
  final String value;
  const _SectionValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}

// -- Attendance row widget --
class _AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> shift;
  const _AttendanceRow({required this.shift});

  @override
  Widget build(BuildContext context) {
    final bool isLogOut = shift['type'].toString().toLowerCase() == 'log out';

    final Color timeColor = 
    isLogOut ? const Color.fromARGB(255, 229, 57, 53) : 
    const Color.fromARGB(255, 80, 193, 84);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Log in/Log out label
          Text(
            shift['type'].toString(),
            style: const TextStyle(
              fontFamily: AppFonts.figtree,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          // time and date
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
