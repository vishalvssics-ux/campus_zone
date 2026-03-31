import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final academic = Provider.of<AcademicProvider>(context, listen: false);
      if (user.role == 'teacher') {
        academic.fetchExamSchedule(teacherId: user.id);
      } else {
        academic.fetchExamSchedule(studentId: user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F61B5),
      appBar: AppBar(
        title: const Text('Exam Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Consumer<AcademicProvider>(
                   builder: (context, academic, _) {
                     if (academic.isLoading) return const Center(child: CircularProgressIndicator());
                     if (academic.exams.isEmpty) {
                       return Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade300),
                             const SizedBox(height: 16),
                             const Text('No exams scheduled yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                           ],
                         ),
                       );
                     }
                     return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: academic.exams.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final exam = academic.exams[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.assignment_outlined, color: Colors.red),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(exam['subject'] ?? 'Subject', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF15244B))),
                                            Text(exam['date'] ?? 'TBD', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoItem(Icons.access_time, 'Time', '${exam['startTime']} - ${exam['endTime']}'),
                                      _buildInfoItem(Icons.room_outlined, 'Room', exam['room'] ?? 'TBD'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                   },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15244B))),
      ],
    );
  }
}
