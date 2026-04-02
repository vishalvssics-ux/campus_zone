import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'student';
  String? _selectedTeacherId;
  List<dynamic> _teachers = [];
  
  // Location
  LatLng _selectedLocation = const LatLng(12.9704, 77.5979);
  bool _locationSet = false;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  void _fetchTeachers() async {
    try {
      final data = await ApiService().get('/teachers');
      setState(() {
        _teachers = data;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                // Minimal drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Home Location',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.textDarkColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
                        ),
                        child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 15,
                        onTap: (tapPosition, point) {
                          setModalState(() {
                            _selectedLocation = point;
                          });
                          setState(() {
                            _selectedLocation = point;
                            _locationSet = true;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.location_on, color: AppTheme.secondaryColor, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required.'), backgroundColor: Colors.red));
      return;
    }
    
    final userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'role': _selectedRole,
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
    };

    if (_selectedRole == 'student') {
      if (_selectedTeacherId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Class Teacher.'), backgroundColor: Colors.red));
        return;
      }
      userData['classTeacherId'] = _selectedTeacherId!;
    }

    try {
      await auth.register(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful! Please wait for approval.'),
          backgroundColor: AppTheme.accentColor,
        )
      );
      Navigator.pop(context); // back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                      Text(
                        'Create Account',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    children: [
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
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
                              Text(
                                'Personal Details',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDarkColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(CupertinoIcons.person, size: 20),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(CupertinoIcons.mail, size: 20),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
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
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(labelText: 'Role'),
                                icon: const Icon(Icons.expand_more_rounded),
                                items: ['student', 'teacher', 'driver', 'non-faculty']
                                    .map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase())))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedRole = val!),
                              ),
                              if (_selectedRole == 'student') ...[
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedTeacherId,
                                  decoration: const InputDecoration(labelText: 'Select Class Teacher'),
                                  icon: const Icon(Icons.expand_more_rounded),
                                  items: _teachers
                                      .map((t) => DropdownMenuItem(value: t['_id'] as String, child: Text(t['name'] as String)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedTeacherId = val),
                                ),
                              ],
                              const SizedBox(height: 24),
                              
                              // Location Picker
                              GestureDetector(
                                onTap: _showLocationPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _locationSet ? AppTheme.secondaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.location_solid, 
                                          color: _locationSet ? AppTheme.secondaryColor : Colors.grey.shade500,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Home Location',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _locationSet 
                                                ? '${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}'
                                                : 'Tap to select on map',
                                              style: TextStyle(
                                                color: _locationSet ? AppTheme.textDarkColor : Colors.grey.shade500,
                                                fontSize: 14,
                                                fontWeight: _locationSet ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return ElevatedButton(
                                    onPressed: auth.isLoading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                       elevation: 4,
                                       backgroundColor: AppTheme.primaryColor,
                                       shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                    ),
                                    child: auth.isLoading 
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Register Now'),
                                  );
                                }
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
          ),
        ],
      ),
    );
  }
}
