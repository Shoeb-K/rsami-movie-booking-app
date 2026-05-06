import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'manage_movies_screen.dart';
import 'create_showtime_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN PANEL', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAdminCard(
              context, 
              'Manage Movies', 
              Icons.movie_creation_outlined,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageMoviesScreen())),
            ),
            const SizedBox(height: 20),
            _buildAdminCard(
              context, 
              'Create Showtime', 
              Icons.schedule,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateShowtimeScreen())),
            ),
            const SizedBox(height: 20),
            _buildAdminCard(
              context, 
              'View Reports', 
              Icons.bar_chart,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.amber),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
