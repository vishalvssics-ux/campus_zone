import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:animate_do/animate_do.dart';
import '../student/marks_screen.dart';
class MyClassListScreen extends StatefulWidget {
  const MyClassListScreen({super.key});

  @override
  State<MyClassListScreen> createState() => _MyClassListScreenState();
}

class _MyClassListScreenState extends State<MyClassListScreen> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<AcademicProvider>(context, listen: false).fetchMyClass(user.id);
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
                  'My Students',
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
                 if (academic.isLoading) return const Center(child: CircularProgressIndicator());
                 
                 if (academic.myStudents.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.group_off_outlined, size: 64, color: Colors.grey.shade300),
                         const SizedBox(height: 16),
                         Text('No students assigned yet.', style: TextStyle(color: Colors.grey.shade500)),
                       ],
                     ),
                   );
                 }

                 return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: academic.myStudents.length,
                  itemBuilder: (context, index) {
                    final s = academic.myStudents[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarksScreen(studentId: s['_id']),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF3F61B5).withOpacity(0.1),
                            child: Text(
                              s['name']?[0] ?? '?',
                              style: const TextStyle(color: Color(0xFF3F61B5), fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(s['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s['email'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                 );
              },
            ),
          ),
        ],
      ),
    );
  }
}
