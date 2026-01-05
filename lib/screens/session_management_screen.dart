import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../models/session_model.dart'; // For DeviceType consts
import '../providers/session_provider.dart';
import 'package:intl/intl.dart';

class SessionManagementScreen extends StatelessWidget {
  final String type; // 'PC' or 'Console'

  const SessionManagementScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$type Management',
            style: Theme.of(context).textTheme.displayMedium),
        centerTitle: true,
      ),
      body: Consumer<SessionProvider>(
        builder: (context, provider, child) {
          final devices = type == DeviceType.pc
              ? provider.pcDevices
              : provider.consoleDevices;

          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other,
                      size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No devices added yet',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Taller cards for better spacing
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _DeviceCard(device: device);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: Text('ADD $type'),
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New $type'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Device Name (e.g., PC 11)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<SessionProvider>(context, listen: false)
                    .addDevice(controller.text, type);
                Navigator.pop(context);
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final session = provider.getSession(device.name);
        final isRunning = session != null;
        final theme = Theme.of(context);
        final primaryColor = theme.primaryColor;

        return GestureDetector(
          onLongPress: () => _showDeleteConfirmation(context, provider),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRunning ? primaryColor : Colors.white10,
                width: isRunning ? 2 : 1,
              ),
              boxShadow: isRunning
                  ? [
                      BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1)
                    ]
                  : [],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRunning
                    ? [primaryColor.withOpacity(0.15), Colors.transparent]
                    : [Colors.transparent, Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style:
                            theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isRunning ? Icons.timer : Icons.circle_outlined,
                      color: isRunning ? primaryColor : Colors.grey,
                      size: 18,
                    ),
                  ],
                ),

                const Divider(height: 20, color: Colors.white10),

                if (isRunning) ...[
                  // ACTIVE STATE
                  _buildStatRow(
                      'Started', DateFormat.jm().format(session.startTime)),
                  const SizedBox(height: 4),
                  _buildStatRow(
                      'Cost', '₹ ${session.totalCost.toStringAsFixed(0)}'),

                  const Spacer(),
                  // Live Timer
                  Text(
                    _formatDuration(session.durationMinutes),
                    style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        color: primaryColor,
                        shadows: [Shadow(color: primaryColor, blurRadius: 10)]),
                  ),
                  const Spacer(),

                  // CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Minimalist buttons
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => provider.addTime(session.id!, 1),
                        tooltip: '+1 Hour',
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle_outlined,
                            color: Colors.redAccent),
                        onPressed: () => _showStopConfirmation(
                            context, provider, session.id!),
                        tooltip: 'Stop Session',
                      ),
                    ],
                  )
                ] else ...[
                  // IDLE STATE
                  const Spacer(),
                  Icon(Icons.power_settings_new,
                      size: 40, color: Colors.white12),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          provider.startSession(device.name, device.type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                      ),
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

  void _showStopConfirmation(
      BuildContext context, SessionProvider provider, int sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Session?'),
        content: const Text(
            'Are you sure you want to stop this session? Charging will stop immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              provider.stopSession(sessionId);
              Navigator.pop(context);
            },
            child: const Text('STOP'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SessionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Station?'),
        content: Text('This will remove "${device.name}" permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              provider.deleteDevice(device.id!);
              Navigator.pop(context);
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
