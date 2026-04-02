import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:campus_zone_user/utils/app_theme.dart';

class PassengerManagerScreen extends StatefulWidget {
  const PassengerManagerScreen({super.key});

  @override
  State<PassengerManagerScreen> createState() => _PassengerManagerScreenState();
}

class _PassengerManagerScreenState extends State<PassengerManagerScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      busProvider.fetchMyPassengers(user.id);
      busProvider.fetchAllUsers();
    }
  }

  void _add(String userId) async {
    final driver = Provider.of<AuthProvider>(context, listen: false).user;
    if (driver != null) {
      try {
        await Provider.of<BusProvider>(context, listen: false).addPassenger(driver.id, userId);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Passenger added successfully!'), backgroundColor: Colors.green)
           );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
           );
        }
      }
    }
  }

  void _remove(String userId) async {
    final driver = Provider.of<AuthProvider>(context, listen: false).user;
    if (driver != null) {
      try {
        await Provider.of<BusProvider>(context, listen: false).removePassenger(driver.id, userId);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Passenger removed from trip.'), backgroundColor: Colors.orange)
           );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
           );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:  AppTheme.primaryColor,
        appBar: AppBar(
          title: const Text('Manage Passengers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(child: Text('MY LIST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Tab(child: Text('ADD NEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 3,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: TabBarView(
            children: [
              _buildMyPassengersTab(),
              _buildAddNewTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPassengersTab() {
    return FadeInUp(
      child: Consumer<BusProvider>(
        builder: (context, bus, _) {
          if (bus.isLoading && bus.passengers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bus.passengers.isEmpty) {
            return _buildEmptyState(
              icon: Icons.people_outline,
              message: 'No passengers in your current trip list.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bus.passengers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = bus.passengers[index];
                return _buildUserCard(
                  name: p['name'] ?? 'Unknown',
                  role: p['role'] ?? 'Student',
                  email: p['email'] ?? '',
                  action: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => _remove(p['_id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddNewTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
        Expanded(
          child: Consumer<BusProvider>(
            builder: (context, bus, _) {
              if (bus.isLoading && bus.allUsers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = bus.allUsers.where((u) {
                final name = (u['name'] ?? '').toString().toLowerCase();
                final alreadyIn = bus.passengers.any((p) => p['_id'] == u['_id']);
                return name.contains(_searchQuery) && !alreadyIn;
              }).toList();

              if (filtered.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.person_search,
                  message: _searchQuery.isEmpty ? 'Loading users...' : 'No matching users found.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final u = filtered[index];
                  return _buildUserCard(
                    name: u['name'] ?? 'Unknown',
                    role: u['role'] ?? 'Student',
                    email: u['email'] ?? '',
                    action: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _add(u['_id']),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard({
    required String name,
    required String role,
    required String email,
    required Widget action,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:  AppTheme.primaryColor.withOpacity(0.1),
            child: Text(name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(role.toUpperCase(), style: TextStyle(color: Colors.grey.shade600, fontSize: 11, letterSpacing: 1.1)),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
