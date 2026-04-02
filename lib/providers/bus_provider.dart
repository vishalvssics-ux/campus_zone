import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BusProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  
  // Data
  dynamic _prediction;
  dynamic _routeData;
  List<dynamic> _passengers = [];
  List<dynamic> _comingUsers = [];
  List<dynamic> _allUsers = [];
  List<dynamic> _roadPoints = [];
  bool _isTripActive = false;

  bool get isLoading => _isLoading;
  bool get isTripActive => _isTripActive;
  dynamic get prediction => _prediction;
  dynamic get routeData => _routeData;
  List<dynamic> get passengers => _passengers;
  List<dynamic> get comingUsers => _comingUsers;
  List<dynamic> get allUsers => _allUsers;
  List<dynamic> get roadPoints => _roadPoints;


  Future<void> _performAction(Future<void> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // STUDENT: Get Prediction
  Future<void> fetchPrediction(String userId) async {
    await _performAction(() async {
      try {
        final res = await _api.get('/bus/prediction/$userId');
        _prediction = res;
      } catch (e) {
        _prediction = null; // No active trip
      }
    });
  }

  // DRIVER: Start Trip
  Future<void> startTrip(String driverId, double lat, double lng) async {
    await _performAction(() async {
      await _api.post('/bus/start-trip', {
        'driverId': driverId,
        'lat': lat,
        'lng': lng
      });
      _isTripActive = true;
    });
  }

  // DRIVER: End Trip
  Future<void> endTrip(String driverId) async {
     await _performAction(() async {
      await _api.post('/bus/end-trip', {'driverId': driverId});
      _isTripActive = false;
    });
  }

  // SHARED: Sync/Check if Trip is currently active
  Future<void> syncTripStatus(String driverId) async {
    try {
      final res = await _api.get('/bus/live-location', queryParameters: {'driverId': driverId});
      // If status is ONLINE, trip is active
      _isTripActive = res != null && res['status'] == 'ONLINE';
      notifyListeners();
    } catch (e) {
      _isTripActive = false;
      notifyListeners();
    }
  }

  // DRIVER: Trigger SOS
  Future<void> triggerSOS(String driverId, String reason, double lat, double lng) async {
     await _performAction(() async {
      await _api.post('https://collage-backend-123.vercel.app/api/bus/sos', {
        'driverId': driverId,
        'reason': reason,
        'lat': lat,
        'lng': lng
      });
    });
  }

  // DRIVER: Get My Passengers
  Future<void> fetchMyPassengers(String driverId) async {
    await _performAction(() async {
      final res = await _api.get('/bus/my-passengers', queryParameters: {'driverId': driverId});
      _passengers = res is List ? res : [];
    });
  }

  // DRIVER: Add Passenger
  Future<void> addPassenger(String driverId, String passengerId) async {
    await _performAction(() async {
      await _api.post('/bus/add-passenger', {'driverId': driverId, 'passengerId': passengerId});
      await fetchMyPassengers(driverId); // Refresh
    });
  }

  // STUDENT: Set Daily Status
  Future<dynamic> setDailyStatus(String userId, String status, String driverId) async {
    dynamic res;
    await _performAction(() async {
      res = await _api.post('/bus/status', {
        'userId': userId,
        'status': status,
        'driverId': driverId,
      });
    });
    return res;
  }

  // DRIVER: Get All Users (for adding passengers)
  Future<void> fetchAllUsers() async {
    await _performAction(() async {
      final res = await _api.get('/bus/all-users');
      _allUsers = res is List ? res : [];
    });
  }

  // STUDENT: Get My Assigned Bus/Driver
  Future<void> fetchMyBus(String userId) async {
    await _performAction(() async {
      try {
        final res = await _api.get('/bus/my-bus/$userId');
        if (_prediction == null) {
          _prediction = res; 
        }
      } catch (e) {
        // Silently fail or set to null if not found
        if (_prediction == null) _prediction = null;
      }
    });
  }

  // DRIVER: Get Optimized Route Stops
  Future<void> fetchRoute(String driverId) async {
    await _performAction(() async {
      final res = await _api.get('/bus/route', queryParameters: {'driverId': driverId});
      _routeData = res;
      
      // If we have stops, fetch the road-following path
      if (res != null && res['stops'] != null) {
        final List stops = res['stops'];
        final start = res['start'];
        if (stops.isNotEmpty && start != null) {
          await fetchRoadRoute(start, stops);
        }
      }
    });
  }

  // NEW: Fetch actual road-following points using OSRM
  Future<void> fetchRoadRoute(Map<String, dynamic> start, List stops) async {
    try {
      // Format: lng,lat;lng,lat;...
      String coords = '${start['lng']},${start['lat']}';
      for (var stop in stops) {
        if (stop['lat'] != 0 && stop['lng'] != 0) {
          coords += ';${stop['lng']},${stop['lat']}';
        }
      }

      final url = 'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
      final response = await _api.get(url); // ApiService can handle full URLs if we modify it, or use direct dio
      
      if (response != null && response['routes'] != null && response['routes'].isNotEmpty) {
        _roadPoints = response['routes'][0]['geometry']['coordinates'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('OSRM Route Fetch Failed: $e');
      _roadPoints = []; // Fallback to straight lines (handled in UI)
    }

  }

  // SHARED: Get Live Location
  Future<Map<String, dynamic>?> getLiveLocation(String driverId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/bus/live-location', queryParameters: {'driverId': driverId});
      // Backend returns { status: 'ONLINE', data: { location: { lat, lng, ... } } }
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // DRIVER: Remove Passenger
  Future<void> removePassenger(String driverId, String passengerId) async {
    await _performAction(() async {
      await _api.post('/bus/remove-passenger', {'driverId': driverId, 'passengerId': passengerId});
      await fetchMyPassengers(driverId);
    });
  }
}
