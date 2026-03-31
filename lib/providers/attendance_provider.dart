import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  List<dynamic> _history = [];
  Map<String, dynamic>? _liveClassData;

  bool get isLoading => _isLoading;
  List<dynamic> get history => _history;
  Map<String, dynamic>? get liveClassData => _liveClassData;

  Future<dynamic> markAttendance(String userId, String status, {double lat = 0, double lng = 0}) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('Marking Attendance: userId=$userId, status=$status, lat=$lat, lng=$lng');
      final res = await _api.post('/attendance/mark', {
        'userId': userId,
        'status': status,
        'lat': lat,
        'lng': lng,
      });
      // Refresh history
      await fetchHistory(userId);
      return res;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/attendance/history', queryParameters: {'userId': userId});
      if (res is Map && res.containsKey('history')) {
        _history = res['history'] as List<dynamic>;
      } else {
        _history = res is List ? res : [];
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLiveClassAttendance(String teacherId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/attendance/live-class', queryParameters: {'teacherId': teacherId});
      _liveClassData = res is Map ? res as Map<String, dynamic> : null;
    } catch (e) {
      _liveClassData = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
