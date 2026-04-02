import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isServiceEnabled = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  void _initRoute() {
    _checkPermissionAndStartTracking();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<BusProvider>(context, listen: false).fetchRoute(user.id);
    }
  }

  Future<void> _checkPermissionAndStartTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isServiceEnabled = false);
      return;
    }
    setState(() => _isServiceEnabled = true);

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('Route Overview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: Colors.white),
            onPressed: () {
              final bus = Provider.of<BusProvider>(context, listen: false);
              if (bus.roadPoints.isNotEmpty) {
                final pts = bus.roadPoints.map((c) => LatLng(c[1], c[0])).toList();
                _fitBounds(pts);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initRoute,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Consumer<BusProvider>(
                  builder: (context, bus, _) {
                    final dynamic routeDataRaw = bus.routeData;
                    final Map<String, dynamic>? routeData = routeDataRaw is Map<String, dynamic> ? routeDataRaw : null;
                    
                    List<Marker> markers = [];
                    List<LatLng> polyPoints = [];
                    
                    // 1. Process Road Points & Fit Bounds
                    if (bus.roadPoints.isNotEmpty) {
                      for (var coord in bus.roadPoints) {
                        polyPoints.add(LatLng(coord[1], coord[0]));
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                         if (mounted) _fitBounds(polyPoints);
                      });
                    }

                    // 2. Prepare Markers
                    if (_currentPosition != null) {
                      markers.add(Marker(
                        point: _currentPosition!,
                        width: 50, height: 50,
                        child: const Icon(Icons.directions_bus, color: AppTheme.primaryColor, size: 35),
                      ));
                    }

                    if (routeData != null && routeData['start'] != null) {
                      final start = routeData['start'];
                      markers.add(Marker(
                        point: LatLng(start['lat'], start['lng']),
                        width: 50, height: 50,
                        child: const Icon(Icons.school, color: Colors.red, size: 35),
                      ));
                    }

                    if (routeData != null && routeData['stops'] != null) {
                      final List stops = routeData['stops'];
                      for (var stop in stops) {
                        if (stop['lat'] != 0 && stop['lng'] != 0) {
                          markers.add(Marker(
                            point: LatLng(stop['lat'], stop['lng']),
                            width: 40, height: 40,
                            child: Tooltip(message: stop['name'], child: const Icon(Icons.location_on, color: Colors.green, size: 30)),
                          ));
                        }
                      }
                    }

                    // 3. Fallback for Polyline if OSRM fails
                    if (polyPoints.isEmpty && routeData != null) {
                      if (_currentPosition != null) polyPoints.add(_currentPosition!);
                      final List? stops = routeData['stops'];
                      if (stops != null) {
                        for (var stop in stops) {
                          if (stop['lat'] != 0 && stop['lng'] != 0) polyPoints.add(LatLng(stop['lat'], stop['lng']));
                        }
                      }
                      if (routeData['start'] != null) {
                         final start = routeData['start'];
                         polyPoints.add(LatLng(start['lat'], start['lng']));
                      }
                    }

                    return Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentPosition ?? const LatLng(12.9716, 77.5946),
                            initialZoom: 13,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                              userAgentPackageName: 'com.example.app',
                            ),
                            if (polyPoints.length > 1) 
                              PolylineLayer(polylines: [
                                Polyline(
                                  points: polyPoints,
                                  color:  AppTheme.primaryColor,
                                  strokeWidth: 5.0,
                                  borderColor: Colors.white,
                                  borderStrokeWidth: 1.0,
                                )
                              ]),
                            if (markers.isNotEmpty) MarkerLayer(markers: markers),
                          ],
                        ),
                        
                        if (routeData != null)
                          Positioned(
                            bottom: 20, left: 20, right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.alt_route, color: AppTheme.primaryColor),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Today\'s Optimized Route (${routeData['totalComing']} users)', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const Text('Actually following roadside paths', style: TextStyle(fontSize: 11, color: Colors.blue)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (bus.isLoading) const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  },
                ),
               ),
             ),
           ),
        ],
      ),
    );
  }
}
