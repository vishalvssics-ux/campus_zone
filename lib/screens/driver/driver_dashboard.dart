import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

// Assuming these files exist in your project structure
import 'trip_screen.dart';
import 'passenger_manager_screen.dart';
import 'route_screen.dart';
import 'sos_screen.dart';
import '../home/attendance_screen.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Command', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // FIXED: FadeInDown takes a single 'child', not 'children'
            FadeInDown(
              child: _buildControlCard(context, 'Trip Control', Icons.bus_alert, Colors.white, isStart: true),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildControlCard(context, 'My Passengers', Icons.people_outline, Colors.blue),
                  _buildControlCard(context, 'Optimize Route', Icons.directions_rounded, Colors.green),
                  _buildControlCard(context, 'Attendance', Icons.how_to_reg_rounded, Colors.orange),
                  _buildControlCard(context, 'Emergency SOS', Icons.warning_amber_rounded, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(BuildContext context, String title, IconData icon, Color color, {bool isStart = false}) {
    // Note: Since you wrapped the top card in FadeInDown in the build method, 
    // having FadeInUp here creates a double animation for that specific card.
    // It works, but usually, you would choose one or the other.
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          if (isStart) Navigator.push(context, MaterialPageRoute(builder: (_) => const TripScreen()));
          if (title == 'My Passengers') Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerManagerScreen()));
          if (title == 'Optimize Route') Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteScreen()));
          if (title == 'Attendance') Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
          if (title == 'Emergency SOS') Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSScreen()));
        },
        child: Container(
          decoration: BoxDecoration(
            color: isStart ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          // FIXED: Properly closed the BoxDecoration and formatted the child Column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}