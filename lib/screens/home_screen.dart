import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/theme_provider.dart';
import 'main_layout.dart';
import 'revenue_analytics_screen.dart';
import 'session_management_screen.dart'; // Though not directly nav'd from here for session cards anymore as they redirect to tabs

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Entrance Animation
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('TIBGS CAFE',
            style: Theme.of(context).textTheme.displayMedium),
        backgroundColor: Colors.transparent, // Glass effect header
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        // Background with subtle gradient if needed, or rely on scaffold bg
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DASHBOARD HEADER
                _buildDashboardSummary(context),
                const SizedBox(height: 32),

                Text(
                  'COMMAND CENTER',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 20),

                // SESSION CONTROL ROW
                Row(
                  children: [
                    Expanded(
                      child: _buildSessionCard(
                        context,
                        title: 'PC ZONE',
                        subtitle: 'Manage High-End PCs',
                        icon: Icons.computer,
                        color: Theme.of(context).primaryColor,
                        type: 'PC',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSessionCard(
                        context,
                        title: 'CONSOLE HUB',
                        subtitle: 'PS5 & Xbox Stations',
                        icon: Icons.gamepad,
                        color: Theme.of(context).colorScheme.secondary,
                        type: 'Console',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSummary(BuildContext context) {
    // Get Daily Revenue asynchronously?
    // Ideally Provider should hold this or we fetch it.
    // For now we can assume analytics screen/provider fetches it.
    // Let's use a FutureBuilder here if we want or just static for now as requested fix was counts.

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DAILY REVENUE',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  // Placeholder for now, can be connected to provider later
                  Text('₹ ---', // Placeholder
                      style: Theme.of(context).textTheme.displayLarge),
                ],
              ),
              InkWell(
                onTap: () {
                  // Switch to Revenue Tab (Index 3)
                  final mainState =
                      context.findAncestorStateOfType<MainLayoutState>();
                  mainState?.switchTab(3);
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bar_chart,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick Stats Row
          Consumer<SessionProvider>(builder: (context, session, _) {
            return Row(
              children: [
                _buildQuickStat(context, 'Active PCs', Icons.desktop_windows,
                    '${session.activePCCount}'),
                const SizedBox(width: 24),
                _buildQuickStat(context, 'Active Consoles',
                    Icons.videogame_asset, '${session.activeConsoleCount}'),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
      BuildContext context, String label, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required String type}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Switch Tab based on type
          final mainState = context.findAncestorStateOfType<MainLayoutState>();
          if (type == 'PC') {
            mainState?.switchTab(1);
          } else {
            mainState?.switchTab(2);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
