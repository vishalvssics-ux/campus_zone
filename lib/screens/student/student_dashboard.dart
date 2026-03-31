import 'package:campus_zone_user/models/user.dart';
import 'package:campus_zone_user/providers/bus_provider.dart';
import 'package:campus_zone_user/screens/student/time_table_screen.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'exam_schedule_screen.dart';
import 'marks_screen.dart';
import 'assignments_screen.dart';
import 'bus_tracking_screen.dart';
import 'bus_attendance_screen.dart';
import '../home/attendance_screen.dart';
import '../home/profile_screen.dart';
import 'package:flutter/material.dart';

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
  void dispose() {
    super.dispose();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF3F61B5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi ${user?.name ?? 'Student'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user?.className ?? 'Class'} | Roll no: ${user?.rollNo ?? '--'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '2020-2021',
                          style: TextStyle(color: Colors.white, fontSize: 12),
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
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 50,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
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
                children: [
                  // Summary Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          '${attendancePercent.toStringAsFixed(1)}%',
                          'Attendance',
                          Icons.person_outline,
                          Colors.orange,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Expanded(
                      //   child: _buildSummaryCard(
                      //     '₹6400',
                      //     'Fees Due',
                      //     Icons.currency_rupee,
                      //     Colors.purple,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Grid Menu
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(context, 'Assignment', Icons.menu_book_outlined, Colors.indigo),
                      _buildMenuCard(context, 'Time Table', Icons.calendar_month_outlined, Colors.indigo),
                      _buildMenuCard(context, 'Result', Icons.description_outlined, Colors.blue),
                      _buildMenuCard(context, 'Date Sheet', Icons.star_outline, Colors.indigo),
                      _buildMenuCard(context, 'Bus Tracking', Icons.add_location_alt, Colors.blue),
                      _buildMenuCard(context, 'Bus Attendance', Icons.directions_bus, Colors.indigo),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Assignment') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsScreen()));
        } else if (title == 'Time Table') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTableScreen()));
        } else if (title == 'Bus Tracking') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BusTrackingScreen()));
        } else if (title == 'Bus Attendance') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BusAttendanceScreen()));
        } else if (title == 'Result') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MarksScreen()));
        } else if (title == 'Date Sheet') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen(showOnlyHistory: true)));
        }
        // Add more navigation as needed
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3F61B5)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
