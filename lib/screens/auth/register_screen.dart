import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tap to Select Home Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
              Expanded(
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
                          child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'role': _selectedRole,
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
    };

    if (_selectedRole == 'student' && _selectedTeacherId != null) {
      userData['classTeacherId'] = _selectedTeacherId!;
    }

    try {
      await auth.register(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful! Please wait for approval.'))
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF15244B),
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
                  const Text('Create An Account', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  FadeInUp(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: ['student', 'teacher', 'driver', 'non-faculty']
                          .map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase())))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                  ),
                  if (_selectedRole == 'student') ...[
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: DropdownButtonFormField<String>(
                        value: _selectedTeacherId,
                        decoration: const InputDecoration(labelText: 'Select Class Teacher'),
                        items: _teachers
                            .map((t) => DropdownMenuItem(value: t['_id'] as String, child: Text(t['name'] as String)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedTeacherId = val),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Location Picker
                  FadeInUp(
                    delay: const Duration(milliseconds: 450),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_pin, color: _locationSet ? Colors.blue : Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _locationSet 
                                    ? 'Location: ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}'
                                    : 'Select Home Location for Bus Tracking',
                                  style: TextStyle(color: _locationSet ? Colors.black : Colors.grey.shade600, fontSize: 13),
                                ),
                              ),
                              TextButton(
                                onPressed: _showLocationPicker,
                                child: Text(_locationSet ? 'Change' : 'Pick Map'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15244B),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: auth.isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      }
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
