import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:campus_zone_user/models/user.dart';
import 'package:campus_zone_user/providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/app_theme.dart';

import '../home/profile_screen.dart';
import '../home/attendance_screen.dart';
import 'time_table_screen.dart';
import 'exam_schedule_screen.dart';
import 'marks_screen.dart';
import 'assignments_screen.dart';
import 'bus_tracking_screen.dart';
import 'bus_attendance_screen.dart';
import 'dart:async';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<AttendanceProvider>().fetchHistory(user.id);
        context.read<BusProvider>().fetchPrediction(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final attendance = context.watch<AttendanceProvider>();
    
    // Calculate attendance percentage
    double attendancePercent = 0.0;
    if (attendance.history.isNotEmpty) {
      int present = attendance.history.where((r) => r['status'] == 'present').length;
      attendancePercent = (present / attendance.history.length) * 100;
    }

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
                      Text(
                        'Hello,',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.name ?? 'Student',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          '${user?.className ?? 'Class'} • Roll: ${user?.rollNo ?? '--'}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
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
                  ),
                  Positioned(
                    right: 0,
                    top: 60,
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
                  // Section Title
                  Text(
                    'Overview',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Summary Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          '${attendancePercent.toStringAsFixed(1)}%',
                          'Attendance',
                          Icons.how_to_reg_rounded,
                          AppTheme.secondaryColor,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Academics & Transport',
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
                    childAspectRatio: 1.05, // Slightly taller for better text spacing
                    children: [
                      _buildMenuCard(context, 'Assignments', Icons.menu_book_rounded, AppTheme.secondaryColor, 0),
                      _buildMenuCard(context, 'Time Table', Icons.calendar_month_rounded, const Color(0xFFF59E0B), 100),
                      _buildMenuCard(context, 'Results', Icons.military_tech_rounded, const Color(0xFF8B5CF6), 200),
                      _buildMenuCard(context, 'Date Sheet', Icons.event_note_rounded, const Color(0xFF10B981), 300),
                      _buildMenuCard(context, 'Live Bus', Icons.directions_bus_rounded, const Color(0xFFEF4444), 400),
                      _buildMenuCard(context, 'Bus Attend', Icons.departure_board_rounded, const Color(0xFF0EA5E9), 500),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String value, String label, IconData icon, Color iconColor, [VoidCallback? onTap]) {
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
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
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
          if (title == 'Assignments') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsScreen()));
          } else if (title == 'Time Table') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTableScreen()));
          } else if (title == 'Live Bus') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BusTrackingScreen()));
          } else if (title == 'Bus Attend') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BusAttendanceScreen()));
          } else if (title == 'Results') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MarksScreen()));
          } else if (title == 'Date Sheet') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen(showOnlyHistory: true)));
          }
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
            // Subtle border for premium feel
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
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
