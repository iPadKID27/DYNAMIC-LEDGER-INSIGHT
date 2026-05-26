import 'package:flutter/material.dart';
import 'settings_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Text(
                'TW',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The one who wait',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'waiter@example.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              title: 'Personal Details',
              onTap: () {},
            ),
            _buildProfileOption(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'My Assets',
              onTap: () {},
            ),
            _buildProfileOption(
              context,
              icon: Icons.history,
              title: 'Transaction History',
              onTap: () {},
            ),
            _buildProfileOption(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsView()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'Support',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
