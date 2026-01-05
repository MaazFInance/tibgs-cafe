import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_model.dart'; // For DeviceType consts
import '../providers/session_provider.dart';
import 'package:intl/intl.dart';

class SessionManagementScreen extends StatelessWidget {
  final String type; // 'PC' or 'Console'

  const SessionManagementScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    // Generate a list of devices (e.g., PC 1 - PC 10)
    final deviceCount = type == DeviceType.pc ? 10 : 5; // Example counts
    final devices = List.generate(deviceCount, (index) => '$type ${index + 1}');

    return Scaffold(
      appBar: AppBar(
        title: Text('$type Management'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 Columns
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final deviceName = devices[index];
          return _DeviceCard(deviceName: deviceName, deviceType: type);
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String deviceName;
  final String deviceType;

  const _DeviceCard({required this.deviceName, required this.deviceType});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final session = provider.getSession(deviceName);
        final isRunning = session != null;

        return Card(
          color: isRunning ? const Color(0xFF2C1810) : null, // Darker tint if active
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isRunning 
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                  : BorderSide.none),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Icon(
                      isRunning ? Icons.timer : Icons.circle_outlined,
                      color: isRunning ? Theme.of(context).primaryColor : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
                
                if (isRunning) ...[
                  // ACTIVE STATE
                  const Divider(),
                  _buildStatRow('Started:', DateFormat.jm().format(session.startTime)),
                  const SizedBox(height: 8),
                  
                  // Live Timer
                  Text(
                    _formatDuration(session.durationMinutes),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${session.totalCost.toStringAsFixed(2)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const Spacer(),
                  // CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SmallButton(label: '+1H', onTap: () => provider.addTime(session.id!, 1)),
                      _SmallButton(label: 'STOP', isDestructive: true, onTap: () => provider.stopSession(session.id!)),
                    ],
                  )
                ] else ...[
                  // IDLE STATE
                  const Spacer(),
                  const Icon(Icons.desktop_windows, size: 40, color: Colors.white24),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => provider.startSession(deviceName, deviceType),
                      child: const Text('START'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SmallButton({required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDestructive ? Colors.red : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
