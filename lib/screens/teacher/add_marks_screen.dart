import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';

class AddMarksScreen extends StatefulWidget {
  const AddMarksScreen({super.key});

  @override
  State<AddMarksScreen> createState() => _AddMarksScreenState();
}

class _AddMarksScreenState extends State<AddMarksScreen> {
  final _semesterCtrl = TextEditingController(text: '1');
  final _subjectCtrl = TextEditingController();
  final _marksCtrl = TextEditingController();
  final _totalCtrl = TextEditingController(text: '100');
  final _examTypeCtrl = TextEditingController(text: 'Final');

  String? _selectedStudentId;
  
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<AcademicProvider>(context, listen: false).fetchMyClass(user.id);
    }
  }

  void _submit() async {
    if (_selectedStudentId == null) return;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
       try {
         await Provider.of<AcademicProvider>(context, listen: false).addMarks({
           'teacherId': user.id,
           'studentId': _selectedStudentId,
           'semester': _semesterCtrl.text,
           'subject': _subjectCtrl.text,
           'marks': int.tryParse(_marksCtrl.text) ?? 0,
           'total': int.tryParse(_totalCtrl.text) ?? 100,
           'examType': _examTypeCtrl.text
         });
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks Added!')));
         _marksCtrl.clear();
         _subjectCtrl.clear();
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              color: Color(0xFF3F61B5),
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
                  'Upload Marks',
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
            child: Consumer<AcademicProvider>(
              builder: (context, academic, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Performance',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F61B5)),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedStudentId,
                        decoration: InputDecoration(
                          labelText: 'Select Student',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: academic.myStudents.map<DropdownMenuItem<String>>((s) {
                          return DropdownMenuItem(value: s['_id'], child: Text(s['name']));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedStudentId = val),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _semesterCtrl,
                              decoration: InputDecoration(
                                labelText: 'Semester',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _examTypeCtrl,
                              decoration: InputDecoration(
                                labelText: 'Exam Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller: _subjectCtrl,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.book_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _marksCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Marks Obtained',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _totalCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Total Marks',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F61B5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text('Save Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
