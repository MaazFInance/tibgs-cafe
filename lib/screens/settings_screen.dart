import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('SETTINGS',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 24)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'APPEARANCE'),
          Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle:
                    const Text('Toggle between cyberpunk dark and light theme'),
                secondary: Icon(
                    provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: theme.primaryColor),
                value: provider.isDarkMode,
                activeColor: theme.primaryColor,
                onChanged: (value) => provider.toggleTheme(),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'PRICING CONFIGURATION (Coming Soon)'),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.attach_money),
            title: Text('Hourly Rates'),
            subtitle: Text('Configure PC and Console rates per hour'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const Divider(),
          _buildSectionHeader(context, 'ABOUT'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
