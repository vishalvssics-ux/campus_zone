import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class CampusLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const CampusLogo({
    Key? key,
    this.size = 80,
    this.showText = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppTheme.primaryColor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(size * 0.25),
          decoration: BoxDecoration(
            color: logoColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/logo.png',scale: 3,),
          // child: Icon(
          //   Icons.account_balance_outlined, // A classic academic silhouette
          //   size: size,
          //   color: logoColor,
          // ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.2),
          Text(
            'Campus Zone',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              color: logoColor,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: size * 0.05),
          Text(
            'Smart Campus Management',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: size * 0.15,
              fontWeight: FontWeight.w500,
              color: logoColor.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ]
      ],
    );
  }
}
