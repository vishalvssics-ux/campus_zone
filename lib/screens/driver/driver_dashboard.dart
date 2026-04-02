import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

// Assuming these files exist in your project structure
import 'trip_screen.dart';
import 'passenger_manager_screen.dart';
import 'route_screen.dart';
import 'sos_screen.dart';
import '../home/attendance_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Elegant Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.5), width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.drive_eta_rounded, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                user?.name ?? 'Captain',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Route Coordinator',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'On Duty',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Positioned(
                    right: 0,
                    top: 10,
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white70),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Action Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripScreen())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.secondaryColor, Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'START TRIP',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to begin your shift',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Fleet Controls',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDarkColor,
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
                    childAspectRatio: 1.05,
                    children: [
                      _buildMenuCard(context, 'My Passengers', Icons.people_outline_rounded, const Color(0xFF0EA5E9), 0),
                      _buildMenuCard(context, 'Optimize Route', Icons.directions_rounded, const Color(0xFF8B5CF6), 100),
                      _buildMenuCard(context, 'Attendance', Icons.how_to_reg_rounded, const Color(0xFF10B981), 200),
                      _buildMenuCard(context, 'Emergency SOS', Icons.warning_amber_rounded, const Color(0xFFEF4444), 300),
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

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color primaryIconColor, int delayMs) {
    return FadeInUp(
      delay: Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          if (title == 'My Passengers') Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerManagerScreen()));
          else if (title == 'Optimize Route') Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteScreen()));
          else if (title == 'Attendance') Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
          else if (title == 'Emergency SOS') Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSScreen()));
        },
        child: Container(
          decoration: BoxDecoration(
            color: title == 'Emergency SOS' ? const Color(0xFFFEF2F2) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: title == 'Emergency SOS' ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: title == 'Emergency SOS' ? Colors.red.withOpacity(0.2) : Colors.grey.shade100,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: title == 'Emergency SOS' 
                    ? Colors.red.withOpacity(0.1) 
                    : primaryIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  size: 32, 
                  color: title == 'Emergency SOS' ? Colors.red : primaryIconColor
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: title == 'Emergency SOS' ? Colors.red.shade700 : AppTheme.textDarkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
