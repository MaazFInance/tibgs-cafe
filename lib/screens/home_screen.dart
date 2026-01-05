import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../models/session_model.dart'; // For types
import 'session_management_screen.dart';
import 'revenue_analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIBGS CAFE MANAGER'),
        leading: const Icon(Icons.gamepad),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // REVENUE BOX (Clickable)
            Material(
              color: CardTheme.of(context).color,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RevenueAnalyticsScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'TODAY\'S REVENUE',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white54,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Placeholder for live revenue (would need a Stream or FutureBuilder)
                      Text(
                        '₹ 0.00', // Dynamic later
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap for detailed analytics',
                        style: TextStyle(fontSize: 12, color: Colors.white30),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'SESSION CONTROLS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // PC SESSIONS CARD
            Expanded(
              child: _buildSessionCard(
                context,
                title: 'PC SESSIONS',
                icon: Icons.monitor,
                color: Colors.blueAccent,
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionManagementScreen(type: DeviceType.pc)),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // CONSOLE SESSIONS CARD
            Expanded(
              child: _buildSessionCard(
                context,
                title: 'CONSOLE SESSIONS',
                icon: Icons.videogame_asset,
                color: Colors.purpleAccent,
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionManagementScreen(type: DeviceType.console)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
