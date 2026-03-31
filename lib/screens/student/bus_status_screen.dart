import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

import 'dart:async';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class BusStatusScreen extends StatefulWidget {
  const BusStatusScreen({super.key});

  @override
  State<BusStatusScreen> createState() => _BusStatusScreenState();
}

class _BusStatusScreenState extends State<BusStatusScreen> {
  Timer? _liveTimer;
  Map<String, dynamic>? _liveLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _initBusData(user.id);
      }
    });
  }

  void _initBusData(String userId) async {
    final busProvider = context.read<BusProvider>();
    await busProvider.fetchPrediction(userId);
    
    final pred = busProvider.prediction;
    String activeDriverId = pred != null ? (pred['driverId']?.toString() ?? pred['busDriverId']?.toString() ?? '') : '';
    if (activeDriverId.isNotEmpty) {
      await busProvider.fetchRoute(activeDriverId);
    }
    _startPolling(activeDriverId);
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
        print("Polling error: $e");
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
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Status & Tracking'),
        backgroundColor: const Color(0xFF3F61B5),
        foregroundColor: Colors.white,
      ),
      body: Consumer<BusProvider>(
        builder: (context, bus, _) {
          final pred = bus.prediction;
          if (bus.isLoading && pred == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pred == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bus_alert, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No bus information available.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _initBusData(user!.id),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Bus Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF15244B)),
                ),
                const SizedBox(height: 12),
                _buildBusStatusCard(context, bus, user!.id, pred['driverId'] ?? ''),
                const SizedBox(height: 32),

                const Text(
                  'Live Bus Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF15244B)),
                ),
                const SizedBox(height: 12),
                _buildLiveTrackingCard(pred, bus),
                const SizedBox(height: 24),

                if (pred['driver'] != null)
                   _buildInfoRow(Icons.person, 'Driver', pred['driver']),
                if (pred['predictedArrivalTime'] != null)
                   _buildInfoRow(Icons.access_time, 'Estimated Arrival', pred['predictedArrivalTime']),
                if (pred['distance'] != null)
                   _buildInfoRow(Icons.straighten, 'Distance', pred['distance']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBusStatusCard(BuildContext context, BusProvider bus, String userId, String driverId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text('Are you coming to campus today?', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: bus.isLoading && driverId.isNotEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton(
                        onPressed: driverId.isEmpty || bus.isLoading ? null : () => _updateBusStatus(context, bus, userId, 'Coming', driverId),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('I am Coming'),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: driverId.isEmpty || bus.isLoading ? null : () => _updateBusStatus(context, bus, userId, 'Not Coming', driverId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Not Coming'),
                ),
              ),
            ],
          ),
          if (driverId.isEmpty) 
            const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text('No bus assigned currently.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  void _updateBusStatus(BuildContext context, BusProvider bus, String userId, String status, String driverId) async {
    try {
      final res = await bus.setDailyStatus(userId, status, driverId);
      final message = res['message'] ?? 'Status updated: $status';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Widget _buildLiveTrackingCard(Map<String, dynamic> pred, BusProvider bus) {
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

    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: busLatLng ?? const LatLng(20.5937, 78.9629),
                initialZoom: busLatLng != null ? 15 : 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                if (busLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: busLatLng,
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.directions_bus, color: Colors.indigo, size: 35),
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
                      busLatLng != null ? 'ONLINE' : 'OFFLINE',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
