import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _isSending = false;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return false;
    }

    return true;
  }

  void _trigger() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bus = Provider.of<BusProvider>(context, listen: false);

    if (auth.user == null) return;

    // 1. Select Reason
    String? reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Emergency Category'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        children: [
          _reasonOption(context, '🚨 Accident / Collision'),
          _reasonOption(context, '🔧 Mechanical Failure'),
          _reasonOption(context, '🚑 Medical Emergency'),
          _reasonOption(context, '🚧 Road Block / Heavy Traffic'),
          _reasonOption(context, '⚠️ Other Immediate Issue'),
        ],
      ),
    );

    if (reason == null) return;

    setState(() => _isSending = true);

    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await bus.triggerSOS(auth.user!.id, reason, pos.latitude, pos.longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS BROADCASTED! Everyone notified.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS: $e'), backgroundColor: Colors.black),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _reasonOption(BuildContext context, String text) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, text),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('Emergency SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Security Protocol',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hold the button for 2 seconds to broadcast an instant emergency alert to all passengers and administrators.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    Center(
                      child: FadeIn(
                        duration: const Duration(milliseconds: 500),
                        child: Pulse(
                          infinite: true,
                          child: GestureDetector(
                            onLongPress: _trigger,
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                color: _isSending ? Colors.red[900] : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  )
                                ],
                              ),
                              child: Center(
                                child: _isSending
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.warning_amber_rounded, size: 90, color: Colors.white),
                                          SizedBox(height: 10),
                                          Text('HOLD TO\nSEND SOS',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your real-time GPS coordinates will be sent automatically.',
                              style: TextStyle(color: Colors.red[700], fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
