import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class CreateExamScheduleScreen extends StatefulWidget {
  const CreateExamScheduleScreen({super.key});

  @override
  State<CreateExamScheduleScreen> createState() => _CreateExamScheduleScreenState();
}

class _CreateExamScheduleScreenState extends State<CreateExamScheduleScreen> {
  final List<Map<String, String>> _exams = [];
  final _subjectCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController(text: 'Sem-1');
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _startTimeCtrl.text = picked.format(context);
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 13, minute: 0),
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _endTimeCtrl.text = picked.format(context);
        });
      }
    }
  }

  void _addExam() {
    if (_subjectCtrl.text.isNotEmpty && _dateCtrl.text.isNotEmpty && _startTimeCtrl.text.isNotEmpty) {
      setState(() {
        _exams.add({
          'subject': _subjectCtrl.text,
          'date': _dateCtrl.text,
          'startTime': _startTimeCtrl.text,
          'endTime': _endTimeCtrl.text,
        });
        _subjectCtrl.clear();
        _dateCtrl.clear();
        _startTimeCtrl.clear();
        _endTimeCtrl.clear();
      });
    }
  }

  void _publish() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AcademicProvider>(context, listen: false).createExamSchedule({
          'teacherId': user.id,
          'semester': _semesterCtrl.text,
          'exams': _exams
        });
        if(mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam Schedule Published & Emailed!'), backgroundColor: Colors.green));
      } catch (e) {
        if(mounted){
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.black));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Blue Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Create Exam Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                     'Academic Info',
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                   ),
                   const SizedBox(height: 16),
                   TextField(
                     controller: _semesterCtrl,
                     decoration: InputDecoration(
                       labelText: 'Semester (e.g., Sem-1)',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       prefixIcon: const Icon(Icons.school_outlined),
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(15),
                       border: Border.all(color: Colors.grey.shade300),
                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Add Subject Details', style: TextStyle(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 12),
                         TextField(
                           controller: _subjectCtrl,
                           decoration: const InputDecoration(hintText: 'Subject Name', prefixIcon: Icon(Icons.book_outlined)),
                         ),
                         const SizedBox(height: 12),
                         GestureDetector(
                           onTap: _selectDate,
                           child: AbsorbPointer(
                             child: TextField(
                               controller: _dateCtrl,
                               decoration: const InputDecoration(hintText: 'Examination Date', prefixIcon: Icon(Icons.event)),
                             ),
                           ),
                         ),
                         const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectStartTime,
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: _startTimeCtrl,
                                      decoration: const InputDecoration(hintText: 'Start Time', prefixIcon: Icon(Icons.timer_outlined)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectEndTime,
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: _endTimeCtrl,
                                      decoration: const InputDecoration(hintText: 'End Time', prefixIcon: Icon(Icons.timer_off_outlined)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                         const SizedBox(height: 16),
                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton(
                             onPressed: _addExam,
                             style: ElevatedButton.styleFrom(
                               backgroundColor:  AppTheme.primaryColor,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                               padding: const EdgeInsets.symmetric(vertical: 12),
                             ),
                             child: const Text('Add to List', style: TextStyle(color: Colors.white)),
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                   const SizedBox(height: 32),
                   if (_exams.isNotEmpty) ...[
                     const Text('Preview Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     const SizedBox(height: 12),
                     ..._exams.map((e) => Container(
                       margin: const EdgeInsets.only(bottom: 12),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.grey.shade200),
                       ),
                       child: ListTile(
                         title: Text(e['subject']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                         subtitle: Text('${e['date']} | ${e['startTime']} - ${e['endTime']}'),
                         trailing: IconButton(
                           icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() => _exams.remove(e));
                            },
                         ),
                       ),
                     )),
                     const SizedBox(height: 24),
                     SizedBox(
                       width: double.infinity,
                       height: 56,
                       child: ElevatedButton(
                         onPressed: _isLoading ? null : _publish,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                         ),
                         child: _isLoading 
                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                             : const Text('Publish & Email Students', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                       ),
                     )
                   ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
