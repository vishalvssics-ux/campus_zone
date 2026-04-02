import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/campus_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step indicator: 0 = Email, 1 = OTP, 2 = Reset
  int _step = 0;
  
  // State data
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.forgotPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your email.'), backgroundColor: AppTheme.accentColor));
      setState(() => _step = 1);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _handleVerifyOTP() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP.'), backgroundColor: Colors.red));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.verifyOTP(email, otp);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Verified.'), backgroundColor: Colors.green));
      setState(() => _step = 2);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _handleResetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.red));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.resetPassword(email, otp, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Reset Successful! You can now login.'), backgroundColor: Colors.green));
      Navigator.pop(context); // Go back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Elegant Header Background
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 250,
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
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Forgot Password',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                
                // Form Container
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(child: CampusLogo(size: 80)),
                              const SizedBox(height: 32),
                              
                              // EMAIL SECTION
                              _buildSectionTitle('Verify Account', _step >= 1),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _emailController,
                                enabled: _step == 0,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(CupertinoIcons.mail, size: 20),
                                  suffixIcon: _step > 0 
                                    ? IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryColor),
                                        onPressed: () => setState(() => _step = 0),
                                      )
                                    : null,
                                ),
                              ),
                              if (_step == 0) ...[
                                const SizedBox(height: 24),
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleSendOTP,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: AppTheme.primaryColor,
                                        elevation: 2,
                                      ),
                                      child: auth.isLoading 
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('Send OTP Code', style: TextStyle(fontWeight: FontWeight.bold)),
                                    );
                                  }
                                ),
                              ],
                              
                              // OTP SECTION
                              if (_step >= 1) ...[
                                const SizedBox(height: 32),
                                FadeInDown(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildSectionTitle('Enter OTP', _step >= 2),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: _otpController,
                                        enabled: _step == 1,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          hintText: '000000',
                                        ),
                                      ),
                                      if (_step == 1) ...[
                                        const SizedBox(height: 24),
                                        Consumer<AuthProvider>(
                                          builder: (context, auth, _) {
                                            return ElevatedButton(
                                              onPressed: auth.isLoading ? null : _handleVerifyOTP,
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                backgroundColor: AppTheme.primaryColor,
                                                elevation: 2,
                                              ),
                                              child: auth.isLoading 
                                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : const Text('Verify Code', style: TextStyle(fontWeight: FontWeight.bold)),
                                            );
                                          }
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              
                              // RESET SECTION
                              if (_step >= 2) ...[
                                const SizedBox(height: 32),
                                FadeInDown(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildSectionTitle('Set New Password', false),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: 'New Password',
                                          prefixIcon: const Icon(CupertinoIcons.lock, size: 20),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        decoration: InputDecoration(
                                          labelText: 'Confirm Password',
                                          prefixIcon: const Icon(CupertinoIcons.lock_shield, size: 20),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Consumer<AuthProvider>(
                                        builder: (context, auth, _) {
                                          return ElevatedButton(
                                            onPressed: auth.isLoading ? null : _handleResetPassword,
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              backgroundColor: AppTheme.accentColor, // Highlighting final action
                                              elevation: 4,
                                              shadowColor: AppTheme.accentColor.withOpacity(0.5),
                                            ),
                                            child: auth.isLoading 
                                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                              : const Text('Reset Account Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 40),
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
    );
  }

  Widget _buildSectionTitle(String title, bool isCompleted) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            size: 14,
            color: isCompleted ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.green : AppTheme.textDarkColor,
          ),
        ),
      ],
    );
  }
}
