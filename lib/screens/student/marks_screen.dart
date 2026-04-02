import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class MarksScreen extends StatefulWidget {
  final String? studentId;
  const MarksScreen({super.key, this.studentId});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final idToFetch = widget.studentId ?? Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (idToFetch != null) {
      Provider.of<AcademicProvider>(context, listen: false)
        .fetchMyMarks(idToFetch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('My Results', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    if (academic.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (academic.marks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.feed_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('No marks published yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: academic.marks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final result = academic.marks[index];
                        final num obtained = result['marksObtained'] ?? 0;
                        final num total = result['totalMarks'] ?? 100;
                        final double percentage = total > 0 ? (obtained / total) : 0;
                        final bool isPass = percentage >= 0.4;
                        final Color resultColor = isPass ? Colors.green : Colors.red;

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
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: percentage,
                                        backgroundColor: Colors.grey[200],
                                        color: resultColor,
                                        strokeWidth: 5,
                                      ),
                                      Center(
                                        child: Text(
                                          '${(percentage * 100).toInt()}%',
                                          style: TextStyle(
                                            color: resultColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result['subject'] ?? 'Subject',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result['examType'] ?? 'Exam',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$obtained',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: resultColor),
                                    ),
                                    Text(
                                      '/ $total',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
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
}
