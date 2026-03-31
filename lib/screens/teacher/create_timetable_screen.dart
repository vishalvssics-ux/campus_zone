import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';

class CreateTimeTableScreen extends StatefulWidget {
  const CreateTimeTableScreen({super.key});

  @override
  State<CreateTimeTableScreen> createState() => _CreateTimeTableScreenState();
}

class _CreateTimeTableScreenState extends State<CreateTimeTableScreen> {
  final _subjectCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String _selectedDay = 'Monday';

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeCtrl.text = picked.format(context);
      });
    }
  }

  void _post() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      if (_subjectCtrl.text.isEmpty || _timeCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill subject and time')));
        return;
      }

      try {
        await Provider.of<AcademicProvider>(context, listen: false).createTimeTable({
          'teacherId': user.id,
          'teacherName': user.name,
          'subject': _subjectCtrl.text,
          'day': _selectedDay,
          'time': _timeCtrl.text,
          'room': _roomCtrl.text,
        });
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time Table Entry Added!')));
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
                  'Add Time Table',
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
                    'Entry Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F61B5)),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.calendar_view_day_outlined),
                    ),
                    items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                    onChanged: (val) => setState(() => _selectedDay = val!),
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

                  GestureDetector(
                    onTap: _selectTime,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _timeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Time',
                          hintText: 'Select Time',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.access_time_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _roomCtrl,
                    decoration: InputDecoration(
                      labelText: 'Room / Hall',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.room_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _post,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F61B5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Add Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
