import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:animate_do/animate_do.dart';
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                            },
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Text(
                            'Hi ${user?.name ?? 'Faculty'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                         
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senior Professor | Dept of CS',
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
                          'Session 2023-24',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          context.read<AuthProvider>().logout();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card for Requests
                  _buildSummaryCard(
                    context,
                    'Pending Requests',
                    '${academic.studentRequests.length}',
                    Icons.person_add_alt_1,
                    Colors.orange,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRequestsScreen())),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Academic Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F61B5),
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
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(context, 'Attendance', Icons.person_add_alt_1, Colors.blue),
                      _buildMenuCard(context, 'Class Broadcast', Icons.campaign_rounded, Colors.indigo),
                      _buildMenuCard(context, 'My Class List', Icons.groups_rounded, Colors.blue),
                      _buildMenuCard(context, 'Post Exam Schedule', Icons.grid_view_rounded, Colors.indigo),
                      _buildMenuCard(context, 'Add Student Marks', Icons.add_chart_rounded, Colors.blue),
                      _buildMenuCard(context, 'Create Assignment', Icons.note_add_rounded, Colors.indigo),
                      _buildMenuCard(context, 'Time Table', Icons.calendar_month_outlined, Colors.blue),
                      _buildMenuCard(context, 'Bus Attendance', Icons.directions_bus, Colors.indigo),
                      _buildMenuCard(context, 'Bus Tracking', Icons.add_location_alt, Colors.blue),
                      _buildMenuCard(context, 'Live Class Attendance', Icons.video_camera_front, Colors.indigo),
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

  Widget _buildSummaryCard(BuildContext context, String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          if (title == 'Attendance') Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
          if (title == 'Student Requests') Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRequestsScreen()));
          if (title == 'Class Broadcast') Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
          if (title == 'My Class List') Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClassListScreen()));
          if (title == 'Post Exam Schedule') Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExamScheduleScreen()));
          if (title == 'Add Student Marks') Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMarksScreen()));
          if (title == 'Create Assignment') Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()));
          if (title == 'Time Table') Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTableScreen()));
          if (title == 'Bus Attendance') Navigator.push(context, MaterialPageRoute(builder: (_) => const BusAttendanceScreen()));
          if (title == 'Bus Tracking') Navigator.push(context, MaterialPageRoute(builder: (_) => const BusTrackingScreen()));
          if (title == 'Live Class Attendance') Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveClassAttendanceScreen()));
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
