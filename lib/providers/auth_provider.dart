import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      // Logic to recreate user from prefs if needed, or just keep as null until login
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.post('/login', {'email': email, 'password': password});
      _user = User.fromJson(data);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _user!.id);
      await prefs.setString('role', _user!.role);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('/register', userData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_user == null) return;
    try {
      final data = await _apiService.get('/profile/${_user!.id}');
      _user = User.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Profile refresh failed: $e');
    }
  }

  // --- Password Reset Flow ---
  
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('https://collage-backend-123.vercel.app/api/forgot-password', {'email': email});
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('https://collage-backend-123.vercel.app/api/verify-otp', {'email': email, 'otp': otp});
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('https://collage-backend-123.vercel.app/api/reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
