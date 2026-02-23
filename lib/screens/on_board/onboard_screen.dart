import 'package:campus_zone_user/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
          
            Positioned.fill(
              child: Image.asset("assets/onboard.png", fit: BoxFit.cover),
            ),
         
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54, 
                      Colors.black87,
                    ],
                    stops: [0.4, 0.7, 1.0], 
                  ),
                ),
              ),
            ),
           
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
           
                  const SizedBox(height: 30),
                
                  const Spacer(), 
                  const Text(
                    'Campus Zone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Campus Zone is a dedicated area within a college or university designed to support academic, social, and extracurricular activities of students. It typically includes classrooms, labs, libraries, common areas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
               
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        
                        print('Get Started tapped!');
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        // decoration: BoxDecoration(
                        //   gradient: const LinearGradient(
                        //     colors: [
                           
                        //     ],
                        //     begin: Alignment.centerLeft,
                        //     end: Alignment.centerRight,
                        //   ),
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        child: Container(
                          alignment: Alignment.center,
                          child:  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Get Started',
                                  style:GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  
                                  // style: TextStyle(
                                  //  color: Colors.white,
                                  //   fontSize: 15,
                                  //   fontWeight: FontWeight.w500,
                                  // ),
                                ),
                                SizedBox(width: 10),
                               Row(
                                children: [
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                               )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}