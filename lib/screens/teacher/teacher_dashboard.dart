import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

import 'student_requests_screen.dart';
import 'broadcast_screen.dart';
import 'my_class_list_screen.dart';
import 'create_exam_schedule_screen.dart';
import 'add_marks_screen.dart';
import 'create_assignment_screen.dart';
import '../student/bus_attendance_screen.dart';
import '../student/time_table_screen.dart';
import '../home/attendance_screen.dart';
import '../home/profile_screen.dart';
import '../student/bus_tracking_screen.dart';
import 'live_class_attendance_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<AcademicProvider>().fetchStudentRequests(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final academic = context.watch<AcademicProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Elegant Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.5), width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person_outline, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                user?.name ?? 'Faculty',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Senior Professor • Dept of CS',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Session 2023-24',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actionable Summary Card
                  _buildSummaryCard(
                    context,
                    'Pending Requests',
                    '${academic.studentRequests.length}',
                    Icons.how_to_reg_rounded,
                    const Color(0xFFF59E0B), // Orange-ish
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRequestsScreen())),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Academic Management',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid Menu
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.05,
                    children: [
                      _buildMenuCard(context, 'Attendance', Icons.person_add_alt_1_rounded, AppTheme.secondaryColor, 0),
                      _buildMenuCard(context, 'Live Class Attd', Icons.video_camera_front_rounded, const Color(0xFF10B981), 50),
                      _buildMenuCard(context, 'Broadcast', Icons.campaign_rounded, const Color(0xFF8B5CF6), 100),
                      _buildMenuCard(context, 'Class List', Icons.groups_rounded, const Color(0xFF0EA5E9), 150),
                      _buildMenuCard(context, 'Date Sheet', Icons.grid_view_rounded, AppTheme.secondaryColor, 200),
                      _buildMenuCard(context, 'Add Marks', Icons.add_chart_rounded, const Color(0xFFF59E0B), 250),
                      _buildMenuCard(context, 'Assignments', Icons.note_add_rounded, const Color(0xFF8B5CF6), 300),
                      _buildMenuCard(context, 'Time Table', Icons.calendar_month_rounded, const Color(0xFF10B981), 350),
                      _buildMenuCard(context, 'Bus Attend', Icons.directions_bus_rounded, const Color(0xFF0EA5E9), 400),
                      _buildMenuCard(context, 'Live Bus', Icons.add_location_alt_rounded, const Color(0xFFEF4444), 450),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color primaryIconColor, int delayMs) {
    return FadeInUp(
      delay: Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          if (title == 'Attendance') Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
          else if (title == 'Class Broadcast') Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
          else if (title == 'Class List') Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClassListScreen()));
          else if (title == 'Date Sheet') Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExamScheduleScreen()));
          else if (title == 'Add Marks') Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMarksScreen()));
          else if (title == 'Assignments') Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()));
          else if (title == 'Time Table') Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTableScreen()));
          else if (title == 'Bus Attend') Navigator.push(context, MaterialPageRoute(builder: (_) => const BusAttendanceScreen()));
          else if (title == 'Live Bus') Navigator.push(context, MaterialPageRoute(builder: (_) => const BusTrackingScreen()));
          else if (title == 'Live Class Attd') Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveClassAttendanceScreen()));
          else if (title == 'Broadcast') Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            // Subtle border for clear separation
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: primaryIconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textDarkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
