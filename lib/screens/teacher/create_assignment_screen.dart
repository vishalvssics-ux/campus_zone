import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _topicCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _semCtrl = TextEditingController(text: '1');
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

  void _post() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AcademicProvider>(context, listen: false).createAssignment({
          'teacherId': user.id,
          'topic': _topicCtrl.text,
          'description': _descCtrl.text,
          'submissionDate': _dateCtrl.text,
          'semester': _semCtrl.text
        });
        if(mounted){
          setState(() => _isLoading = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment Created!')));
        }
      } catch (e) {
        if(mounted){
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                  'New Assignment',
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
                     'Assignment Details',
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                   ),
                   const SizedBox(height: 24),
                   
                   TextField(
                     controller: _topicCtrl,
                     decoration: InputDecoration(
                       labelText: 'Topic',
                       hintText: 'e.g., Calculus Homework',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       prefixIcon: const Icon(Icons.topic_outlined),
                     ),
                   ),
                   const SizedBox(height: 20),
                   TextField(
                     controller: _descCtrl,
                     maxLines: 4,
                     decoration: InputDecoration(
                       labelText: 'Description',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                   ),
                   const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateCtrl,
                          decoration: InputDecoration(
                            labelText: 'Submission Date',
                            hintText: 'Select Date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                      ),
                    ),
                   const SizedBox(height: 20),
                   TextField(
                     controller: _semCtrl,
                     decoration: InputDecoration(
                       labelText: 'Semester',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                   ),
                   const SizedBox(height: 32),
                   
                   SizedBox(
                     width: double.infinity,
                     height: 56,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null : _post,
                       style: ElevatedButton.styleFrom(
                         backgroundColor:  AppTheme.primaryColor,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                       ),
                       child: _isLoading 
                           ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                           : const Text('Post Assignment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                     ),
                   )
                 ],
               ),
            ),
          ),
        ],
      ),
    );
  }
}
