import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({super.key});

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  Timer? _liveTimer;
  Map<String, dynamic>? _liveLocation;
  LatLng? _userLatLng;
  LatLng? _homeLatLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        if (user.lat != null && user.lng != null) {
          setState(() {
            _homeLatLng = LatLng(user.lat!, user.lng!);
          });
        }
        _initBusData(user.id, user.driverId);
      }
      _getUserLocation();
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLatLng = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _initBusData(String userId, String? driverId) async {
    final busProvider = context.read<BusProvider>();
    await busProvider.fetchPrediction(userId);
    
    final pred = busProvider.prediction;
    String? activeDriverId = driverId;
    
    if ((activeDriverId == null || activeDriverId.isEmpty) && pred != null) {
      activeDriverId = pred['driverId']?.toString() ?? pred['busDriverId']?.toString();
    }

    if (activeDriverId != null && activeDriverId.isNotEmpty) {
      await busProvider.fetchRoute(activeDriverId);
      _startPolling(activeDriverId);
    } else {
      _startPolling(''); // Fetch all active buses if no specific driver assigned
    }
  }

  void _startPolling(String driverId) {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final loc = await context.read<BusProvider>().getLiveLocation(driverId);
        if (mounted) {
          setState(() {
            _liveLocation = loc;
          });
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Live Bus Tracking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor:  AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BusProvider>(
        builder: (context, bus, _) {
          final pred = bus.prediction;
          
          if (bus.isLoading && pred == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pred == null || pred['status'] != 'ACTIVE') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.directions_bus_filled_outlined, size: 80, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   const Text('No Active Trip Found', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('Your bus is currently offline.', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          LatLng? busLatLng;
          if (_liveLocation != null) {
            try {
              if (_liveLocation!['lat'] != null && _liveLocation!['lng'] != null) {
                busLatLng = LatLng(double.parse(_liveLocation!['lat'].toString()), double.parse(_liveLocation!['lng'].toString()));
              } else if (_liveLocation!['location'] != null) {
                final loc = _liveLocation!['location'];
                busLatLng = LatLng(double.parse(loc['lat'].toString()), double.parse(loc['lng'].toString()));
              } else if (_liveLocation!['data'] != null) {
                var data = _liveLocation!['data'];
                if (data is List && data.isNotEmpty) {
                  data = data[0]; // array fallback
                }
                if (data is Map) {
                  if (data['lat'] != null && data['lng'] != null) {
                    busLatLng = LatLng(double.parse(data['lat'].toString()), double.parse(data['lng'].toString()));
                  } else if (data['location'] != null) {
                    final loc = data['location'];
                    busLatLng = LatLng(double.parse(loc['lat'].toString()), double.parse(loc['lng'].toString()));
                  }
                }
              }
            } catch (e) {
              debugPrint('Error parsing live location: $e');
            }
          }

          return Column(
            children: [
              // Map Section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: busLatLng ?? _homeLatLng ?? _userLatLng ?? const LatLng(20.5937, 78.9629),
                        initialZoom: busLatLng != null ? 16.0 : 12.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.campuszone.app', // Fixes the OSM access blocked error
                        ),
                        if (bus.roadPoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: bus.roadPoints.map((p) => LatLng(p[1], p[0])).toList(),
                                strokeWidth: 4.0,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        if (busLatLng != null || _userLatLng != null || _homeLatLng != null)
                          MarkerLayer(
                            markers: [
                              if (_homeLatLng != null)
                                Marker(
                                  point: _homeLatLng!,
                                  width: 60,
                                  height: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.home, color: Colors.orange, size: 40),
                                    ),
                                  ),
                                ),
                              if (_userLatLng != null)
                                Marker(
                                  point: _userLatLng!,
                                  width: 60,
                                  height: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                                    ),
                                  ),
                                ),
                              if (busLatLng != null)
                                Marker(
                                  point: busLatLng,
                                  width: 60,
                                  height: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.directions_bus, color: Colors.indigo, size: 40),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: busLatLng != null ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              busLatLng != null ? 'LIVE' : 'WAITING FOR GPS',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:  AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Driver Details', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(pred['driver'] ?? 'Assigned Driver', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoData(Icons.access_time, 'Est. Arrival', pred['predictedArrivalTime'] ?? '--:--'),
                        ),
                        Container(height: 40, width: 1, color: Colors.grey.shade200),
                        Expanded(
                          child: _buildInfoData(Icons.straighten, 'Distance', pred['distance'] ?? '--'),
                        ),
                        Container(height: 40, width: 1, color: Colors.grey.shade200),
                        Expanded(
                          child: _buildInfoData(Icons.timelapse, 'Duration', pred['duration'] ?? '--'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoData(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}
