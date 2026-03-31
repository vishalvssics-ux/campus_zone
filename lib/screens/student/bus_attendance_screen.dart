import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';

class BusAttendanceScreen extends StatefulWidget {
  const BusAttendanceScreen({super.key});

  @override
  State<BusAttendanceScreen> createState() => _BusAttendanceScreenState();
}

class _BusAttendanceScreenState extends State<BusAttendanceScreen> {
  String? _driverId;
  bool _isInitLoaded = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      
      // If driverId is missing, refresh profile first
      if (user.driverId == null || user.driverId!.isEmpty) {
        await authProvider.refreshProfile();
      }

      // 1. Try user object first
      final updatedUser = authProvider.user;
      if (updatedUser?.driverId != null && updatedUser!.driverId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _driverId = updatedUser.driverId);
        });
      }

      // Try fetching active trip prediction first
      await busProvider.fetchPrediction(user.id);
      
      // If no active trip, try fetching general assignment
      if (_driverId == null && busProvider.prediction == null) {
        await busProvider.fetchMyBus(user.id);
      }

      if (mounted) {
        setState(() {
          final pred = busProvider.prediction;
          if (pred is Map) {
            _driverId ??= pred['busDriverId'] ?? pred['driverId'] ?? pred['bus']?['driverId'] ?? pred['_id'];
          } else if (pred is List && pred.isNotEmpty) {
            final first = pred[0];
            _driverId ??= first['busDriverId'] ?? first['driverId'] ?? first['bus']?['driverId'] ?? first['_id'];
          }
          _isInitLoaded = true;
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    
    if (_driverId == null || _driverId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bus assigned currently.'))
      );
      return;
    }

    try {
      final res = await Provider.of<BusProvider>(context, listen: false)
          .setDailyStatus(user.id, status, _driverId!);
      
      String message = res['message'] ?? 'Status updated to $status';
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green)
      );
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('already marked')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.orange)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = context.watch<BusProvider>();
    final prediction = busProvider.prediction;

    return Scaffold(
      backgroundColor: const Color(0xFF3F61B5),
      appBar: AppBar(
        title: const Text('Bus Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: !_isInitLoaded && busProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Bus Status',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3F61B5)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Are you coming to campus by bus today?',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        
                        if (_driverId == null && !busProvider.isLoading)
                          _buildNoBusState()
                        else ...[
                          _buildStatusCard(),
                          const SizedBox(height: 30),
                          _buildInfoSection(prediction),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBusState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No bus is currently assigned or active for your route.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'I am Coming',
                  Icons.check_circle_outline,
                  Colors.green,
                  () => _updateStatus('coming'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Not Coming',
                  Icons.cancel_outlined,
                  Colors.red,
                  () => _updateStatus('not_coming'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic>? prediction) {
    if (prediction == null) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Note: Detailed trip tracking (ETA/Distance) will appear once the driver starts the trip.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF3F61B5)),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text('Trip Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        // const SizedBox(height: 12),
        // _buildInfoRow(Icons.person, 'Driver', prediction['driverName'] ?? 'N/A'),
        // _buildInfoRow(Icons.timer, 'ETA', prediction['eta'] ?? 'Calculating...'),
        // _buildInfoRow(Icons.location_on, 'Distance', prediction['distance'] ?? 'Unknown'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
