import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Account'),
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            title: 'Profile Information',
            subtitle: 'Name, Email, Phone Number',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Accounts & Wallets',
            subtitle: 'Manage your connected accounts',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader('Preferences'),
          _buildSettingTile(
            context,
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: 'USD (\$)',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Manage alerts and reminders',
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: false,
            onChanged: (value) {},
          ),
          const Divider(),
          _buildSectionHeader('Security'),
          _buildSettingTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            subtitle: 'Biometrics, Password',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader('App'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'About NetView',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
