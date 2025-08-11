import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../widgets/user_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.purple[100],
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ahli Komuniti',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Bergabung pada Januari 2025',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // User Stats
            const UserStats(),
            const SizedBox(height: 16),
            
            // Settings
            Card(
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.notifications,
                    title: 'Notifikasi',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.location_on,
                    title: 'Lokasi',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.help,
                    title: 'Bantuan',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.info,
                    title: 'Tentang App',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple[700]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}