import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final stats = await ApiService.fetchAdminStats(auth.token!);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Stats')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatCard('Total Revenue', '₹${_stats?['totalRevenue']}', Colors.green),
                    const SizedBox(width: 15),
                    _buildStatCard('Tickets Sold', '${_stats?['ticketsSold']}', Colors.blue),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatCard('Total Bookings', '${_stats?['totalBookings']}', Colors.orange, isFullWidth: true),
                const SizedBox(height: 40),
                const Text('Most Popular Movies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: (_stats?['popularMovies'] as List).length,
                    itemBuilder: (context, index) {
                      final movie = _stats?['popularMovies'][index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(movie['title']),
                        trailing: Text('${movie['bookings']} bookings', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, {bool isFullWidth = false}) {
    return Expanded(
      flex: isFullWidth ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
