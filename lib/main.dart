import 'package:campus_zone_user/screens/home/home_router.dart';
import 'package:campus_zone_user/screens/on_board/onboard_screen.dart';
import 'package:campus_zone_user/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/academic_provider.dart';
import 'providers/bus_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AcademicProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const SmartCollageApp(),
    ),
  );
}

class SmartCollageApp extends StatelessWidget {
  const SmartCollageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    //  home: OnBoardScreen(),
      title: 'Smart Collage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    initialRoute: '/',
      routes: {
        '/':(context)=>const SplashScreen(),
        '/onboard':(context) => const OnBoardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeRouter(),
      },
    );
  }
}
