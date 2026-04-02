import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/campus_logo.dart';
import '../../utils/app_theme.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fields cannot be empty"), backgroundColor: Colors.red),
      );
      return;
    }
    try {
       await auth.login(_emailController.text.trim(), _passwordController.text.trim());
      // Navigate to dashboard based on role
      final role = auth.user?.role;
      if (role != null) {
         if (mounted) {
           Navigator.pushReplacementNamed(context, '/home');
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Elegant Header Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
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
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                 SliverFillRemaining(
                   hasScrollBody: false,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: [
                         const SizedBox(height: 20),
                         // Logo Section
                         FadeInDown(
                           child: const CampusLogo(
                             size: 70,
                             color: Colors.white,
                             showText: false,
                           ),
                         ),
                         const SizedBox(height: 20),
                         FadeInDown(
                           delay: const Duration(milliseconds: 200),
                           child: Column(
                             children: [
                               Text(
                                 'Welcome Back',
                                 style: GoogleFonts.outfit(
                                   color: Colors.white,
                                   fontSize: 32,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 'Sign in to your campus account',
                                 style: GoogleFonts.outfit(
                                   color: Colors.white70,
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(height: 40),
                         
                         // Login Form Card
                         FadeInUp(
                           delay: const Duration(milliseconds: 400),
                           child: Container(
                             padding: const EdgeInsets.all(32),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(24),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.black.withOpacity(0.08),
                                   blurRadius: 24,
                                   offset: const Offset(0, 8),
                                 ),
                               ],
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.stretch,
                               children: [
                                 TextField(
                                   controller: _emailController,
                                   keyboardType: TextInputType.emailAddress,
                                   textInputAction: TextInputAction.next,
                                   decoration: const InputDecoration(
                                     labelText: 'Email Address',
                                     prefixIcon: Icon(CupertinoIcons.mail, size: 20),
                                   ),
                                 ),
                                 const SizedBox(height: 20),
                                 TextField(
                                   controller: _passwordController,
                                   obscureText: _obscurePassword,
                                   textInputAction: TextInputAction.done,
                                   onSubmitted: (_) => _handleLogin(),
                                   decoration: InputDecoration(
                                     labelText: 'Password',
                                     prefixIcon: const Icon(CupertinoIcons.lock, size: 20),
                                     suffixIcon: IconButton(
                                       icon: Icon(
                                         _obscurePassword 
                                           ? Icons.visibility_off_outlined 
                                           : Icons.visibility_outlined,
                                          size: 20,
                                       ),
                                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                     ),
                                   ),
                                 ),
                                 const SizedBox(height: 12),
                                 Align(
                                   alignment: Alignment.centerRight,
                                   child: TextButton(
                                     onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                                     child: Text(
                                       'Forgot Password?',
                                       style: TextStyle(
                                         color: AppTheme.primaryColor,
                                         fontWeight: FontWeight.w600,
                                       ),
                                     ),
                                   ),
                                 ),
                                 const SizedBox(height: 24),
                                 Consumer<AuthProvider>(
                                   builder: (context, auth, _) {
                                     return ElevatedButton(
                                       onPressed: auth.isLoading ? null : _handleLogin,
                                       style: ElevatedButton.styleFrom(
                                          elevation: 4,
                                          backgroundColor: AppTheme.primaryColor,
                                          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                       ),
                                       child: auth.isLoading 
                                         ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                         : const Row(
                                             mainAxisAlignment: MainAxisAlignment.center,
                                             children: [
                                               Text('Login Securely'),
                                               SizedBox(width: 8),
                                               Icon(Icons.arrow_forward_rounded, size: 20),
                                             ],
                                           ),
                                     );
                                   }
                                 ),
                               ],
                             ),
                           ),
                         ),
                       //  const Spacer(),
                         
                         // Registration Link
                         FadeInUp(
                           delay: const Duration(milliseconds: 600),
                           child: Center(
                             child: Padding(
                               padding: const EdgeInsets.symmetric(vertical: 24.0),
                               child: TextButton(
                                 onPressed: () => Navigator.pushNamed(context, '/register'),
                                 child: Text.rich(
                                   TextSpan(
                                     text: 'Need an account? ',
                                     style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                     children: [
                                       TextSpan(
                                         text: 'Register Here',
                                         style: TextStyle(
                                           color: AppTheme.primaryColor,
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
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
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
