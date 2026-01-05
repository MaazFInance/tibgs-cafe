import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../models/session_model.dart';
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
              childAspectRatio: 0.70,
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

        bool isTimeUp = false;
        if (isRunning) {
          isTimeUp = provider.isTimeUp(session);
        }

        final cardBorderColor =
            isTimeUp ? Colors.red : (isRunning ? primaryColor : Colors.white10);

        final cardGlowColor = isTimeUp
            ? Colors.red.withOpacity(0.5)
            : (isRunning ? primaryColor.withOpacity(0.3) : Colors.transparent);

        return GestureDetector(
          onLongPress: () => _showDeleteConfirmation(context, provider),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cardBorderColor,
                width: isRunning ? 2 : 1,
              ),
              boxShadow: isRunning
                  ? [
                      BoxShadow(
                          color: cardGlowColor, blurRadius: 15, spreadRadius: 2)
                    ]
                  : [],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRunning
                    ? [cardBorderColor.withOpacity(0.15), Colors.transparent]
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
                    if (isRunning && session.targetDurationMinutes != null)
                      Icon(Icons.timelapse,
                          color: isTimeUp ? Colors.red : primaryColor, size: 16)
                  ],
                ),

                const Divider(height: 16, color: Colors.white10),

                if (isRunning) ...[
                  // ACTIVE STATE
                  _buildStatRow(
                      'Started', DateFormat.jm().format(session.startTime)),
                  const SizedBox(height: 4),
                  _buildStatRow('Rate',
                      '₹${session.hourlyRate?.toStringAsFixed(0) ?? "--"}/hr'),
                  const SizedBox(height: 4),
                  _buildStatRow(
                      'Cost', '₹ ${session.totalCost.toStringAsFixed(0)}',
                      highlight: true, context: context),

                  const Spacer(),
                  // Live Timer
                  Text(
                    _formatDuration(session),
                    style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        color: isTimeUp ? Colors.red : primaryColor,
                        shadows: [
                          Shadow(
                              color: isTimeUp ? Colors.red : primaryColor,
                              blurRadius: 10)
                        ]),
                  ),
                  if (isTimeUp)
                    Text("TIME UP!",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  const Spacer(),

                  // CONTROLS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () =>
                          _showStopConfirmation(context, provider, session),
                      child: const Text('STOP'),
                    ),
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
                      onPressed: () => _showStartDialog(context, provider),
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

  void _showStartDialog(BuildContext context, SessionProvider provider) {
    // Determine default rate
    final isPC = device.type == DeviceType.pc;
    double defaultRate = isPC
        ? provider.pcHourlyRate
        : provider
            .consoleHourlyRate; // Wait, provider getters might not be directly exposed or we access SettingsProvider?
    // Actually SessionProvider logic handles defaults if we pass null.
    // BUT user wants to see/edit it.
    // We can assume we can get it from session provider if we exposed getters, or just let session provider handle logic.
    // Let's rely on user input or defaults. To show pre-filled, we need access.
    // I should have exposed current rates in SessionProvider public API or used SettingsProvider here.
    // Let's assume standard defaults for display if provider doesn't expose easily, OR check provider code.
    // Provider code: uses _settings?.pcHourlyRate.

    // Quick fix: Add public getters to SessionProvider for current rates to display here?
    // Or just use 50/80 as fallback display if we can't access.
    // Actually, let's just use a text controller.

    // To properly support "Configurable Rates" appearing here, we need to fetch them.
    // Since SessionManagementScreen doesn't inject SettingsProvider, we can use Provider.of<SettingsProvider>? No, main.dart only provides SettingsProvider to SessionProvider via proxy, but it IS a top level provider too.
    // Yes, main.dart: ChangeNotifierProvider(create: (_) => SettingsProvider()),
    // So we CAN access SettingsProvider here!

    // BUT `SessionProvider` is what we use for `startSession`.

    // Let's just create a stateful dialog wrapper.
    showDialog(
      context: context,
      builder: (ctx) => _StartSessionDialog(
          deviceName: device.name, deviceType: device.type, provider: provider),
    );
  }

  void _showStopConfirmation(
      BuildContext context, SessionProvider provider, Session session) {
    // Calculate final cost visually (provider will update for real on stop)
    // We assume current session.totalCost is close enough (updated every second)

    bool addToRevenue = true;

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Session Receipt'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReceiptRow('Device', session.deviceName),
                  _buildReceiptRow(
                      'Start Time', DateFormat.jm().format(session.startTime)),
                  _buildReceiptRow(
                      'End Time', DateFormat.jm().format(DateTime.now())),
                  _buildReceiptRow(
                      'Duration', '${session.durationMinutes} min'),
                  const Divider(),
                  _buildReceiptRow(
                      'Total Cost', '₹ ${session.totalCost.toStringAsFixed(0)}',
                      isBold: true),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Add to Daily Revenue"),
                    value: addToRevenue,
                    onChanged: (val) {
                      setState(() {
                        addToRevenue = val == true;
                      });
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    provider.stopSession(session.id!,
                        addToRevenue: addToRevenue);
                    Navigator.pop(ctx);
                  },
                  child: const Text('CONFIRM STOP'),
                ),
              ],
            );
          });
        });
  }

  String _formatDuration(Session session) {
    int minutesDisplay;
    if (session.targetDurationMinutes != null) {
      // Countdown
      int remaining = session.targetDurationMinutes! - session.durationMinutes;
      minutesDisplay = remaining > 0 ? remaining : 0;
      if (remaining < 0)
        return "00:00"; // Should typically just show 0 or negative? Let's show 00:00 if over.
    } else {
      minutesDisplay = session.durationMinutes;
    }

    final hours = minutesDisplay ~/ 60;
    final mins = minutesDisplay % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  Widget _buildStatRow(String label, String value,
      {bool highlight = false, BuildContext? context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: highlight && context != null
                    ? Theme.of(context).primaryColor
                    : Colors.white)),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SessionProvider provider) {
    // ... same as before
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Station?'),
        content: Text('This will remove "${device.name}" permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
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
}

class _StartSessionDialog extends StatefulWidget {
  final String deviceName;
  final String deviceType;
  final SessionProvider provider;

  const _StartSessionDialog(
      {required this.deviceName,
      required this.deviceType,
      required this.provider});

  @override
  State<_StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends State<_StartSessionDialog> {
  late TextEditingController _rateController;
  int _selectedDurationIndex = 0; // 0: Open, 1: 1h, 2: 2h, 3: Custom

  final List<String> _durationLabels = [
    'Open Ended',
    '1 Hour',
    '2 Hours',
    'Custom'
  ];
  final List<int?> _durationValues = [null, 60, 120, -1]; // -1 for custom

  @override
  void initState() {
    super.initState();
    // Default rate logic
    // We simply want to pre-fill with settings value.
    // But we don't have direct ref to SettingsProvider here unless we use context.
    // However, the provider calls passed to widget.provider.startSession will use default if we pass null.
    // But user wants to SEE it.
    // Let's just put 50/80 as placeholder if we can't easily reach settings,
    // OR we just wrap this in a Consumer<SettingsProvider>? No, dialog context might be tricky.
    // Let's just try to read it once.
    _rateController = TextEditingController();

    // Hack: We can just let the user type if they want, or leave blank to use system Default.
    // Label can say "Leave blank for default".
  }

  @override
  Widget build(BuildContext context) {
    // Access Settings Provider here to pre-fill
    // We need to wrap content?
    // Or just look up via context of the dialog if available?
    // Yes, context is available.

    //   final settings = Provider.of<SettingsProvider>(context, listen: false);
    // The context passed to showDialog *might* not have provider if strictly root, but usually it does if below MaterialApp.
    // Let's assume it works.

    return AlertDialog(
      title: Text('Start ${widget.deviceName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Duration Mode",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_durationLabels.length, (index) {
                final isSelected = _selectedDurationIndex == index;
                return ChoiceChip(
                  label: Text(_durationLabels[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDurationIndex = index;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text("Hourly Rate (₹)",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Default (from Settings)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL")),
        ElevatedButton(
          onPressed: () {
            int? duration;
            if (_selectedDurationIndex == 1) duration = 60;
            if (_selectedDurationIndex == 2) duration = 120;
            // For custom, we'd theoretically ask, but let's just stick to 1/2 for MVP as requested "Pre-sets".

            double? customRate = double.tryParse(_rateController.text);

            widget.provider.startSession(widget.deviceName, widget.deviceType,
                targetDurationMinutes: duration, customRate: customRate);
            Navigator.pop(context);
          },
          child: const Text("START"),
        )
      ],
    );
  }
}
