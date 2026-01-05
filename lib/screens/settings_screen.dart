import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

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
          // Hourly Rates Section
          _buildSectionHeader(
              context, "PRICING CONFIGURATION", Icons.attach_money),
          const SizedBox(height: 16),
          Consumer<SettingsProvider>(builder: (context, settings, _) {
            return Column(
              children: [
                _buildRateTile(context, "PC Hourly Rate", settings.pcHourlyRate,
                    (val) => settings.updatePCRate(val)),
                const SizedBox(height: 12),
                _buildRateTile(
                    context,
                    "Console Hourly Rate",
                    settings.consoleHourlyRate,
                    (val) => settings.updateConsoleRate(val)),
              ],
            );
          }),
          const SizedBox(height: 32),

          _buildSectionHeader(context, 'APPEARANCE', Icons.palette),
          const SizedBox(height: 16),
          Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1)),
                ),
                child: SwitchListTile(
                  title: const Text('Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                      'Toggle between cyberpunk dark and light theme'),
                  secondary: Icon(
                      provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.primaryColor),
                  value: provider.isDarkMode,
                  activeColor: theme.primaryColor,
                  onChanged: (value) => provider.toggleTheme(),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, 'ABOUT', Icons.info_outline),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.1)),
            ),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              trailing: Text('1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateTile(BuildContext context, String title, double currentRate,
      Function(double) onSave) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('₹ ${currentRate.toStringAsFixed(0)} / hr',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold)),
        ),
        onTap: () {
          _showRateEditDialog(context, title, currentRate, onSave);
        },
      ),
    );
  }

  void _showRateEditDialog(BuildContext context, String title, double current,
      Function(double) onSave) {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Edit $title',
                  style: Theme.of(ctx).textTheme.titleLarge),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rate (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('CANCEL')),
                ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(controller.text);
                      if (val != null) {
                        onSave(val);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('SAVE')),
              ],
            ));
  }
}
