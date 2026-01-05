import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/device_model.dart';
import '../services/database_helper.dart';
import 'settings_provider.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _activeSessions = [];
  List<Device> _devices = [];
  Map<int, Timer> _tickers = {};
  SettingsProvider? _settings;

  // Track alerted sessions to avoid repeated beeps
  final Set<int> _alertedSessions = {};

  List<Session> get activeSessions => _activeSessions;
  List<Device> get devices => _devices;

  List<Device> get pcDevices => _devices.where((d) => d.type == 'PC').toList();
  List<Device> get consoleDevices =>
      _devices.where((d) => d.type == 'Console').toList();

  int get activePCCount =>
      _activeSessions.where((s) => s.deviceType == DeviceType.pc).length;
  int get activeConsoleCount =>
      _activeSessions.where((s) => s.deviceType == DeviceType.console).length;

  // Expose current rates for UI
  double get pcHourlyRate => _settings?.pcHourlyRate ?? 50.0;
  double get consoleHourlyRate => _settings?.consoleHourlyRate ?? 80.0;

  SessionProvider([this._settings]) {
    loadDevices();
  }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  Future<void> loadDevices() async {
    _devices = await DatabaseHelper.instance.getAllDevices();
    notifyListeners();
  }

  Future<void> addDevice(String name, String type) async {
    final device = Device(name: name, type: type);
    await DatabaseHelper.instance.addDevice(device);
    await loadDevices();
  }

  Future<void> deleteDevice(int id) async {
    await DatabaseHelper.instance.deleteDevice(id);
    await loadDevices();
  }

  void startSession(String deviceName, String deviceType,
      {int? targetDurationMinutes, double? customRate}) async {
    final startTime = DateTime.now();

    // Determine Rate: Custom > Settings > Default
    double rate = customRate ??
        (deviceType == DeviceType.pc
            ? (_settings?.pcHourlyRate ?? 50.0)
            : (_settings?.consoleHourlyRate ?? 80.0));

    final newSession = Session(
      deviceName: deviceName,
      deviceType: deviceType,
      startTime: startTime,
      targetDurationMinutes: targetDurationMinutes,
      hourlyRate: rate,
    );

    // Save to DB to get ID
    int id = await DatabaseHelper.instance.createSession(newSession);

    // Create in-memory object with ID
    final sessionWithId = Session(
      id: id,
      deviceName: deviceName,
      deviceType: deviceType,
      startTime: startTime,
      targetDurationMinutes: targetDurationMinutes,
      hourlyRate: rate,
    );

    _activeSessions.add(sessionWithId);
    _startTicker(sessionWithId);
    notifyListeners();
  }

  void _startTicker(Session session) {
    _tickers[session.id!] = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateSessionCost(session);

      // Check for Target Duration
      if (session.targetDurationMinutes != null) {
        if (session.durationMinutes >= session.targetDurationMinutes! &&
            !_alertedSessions.contains(session.id)) {
          _alertedSessions.add(session.id!);
          // Trigger Alert (Just notify listeners, UI will handle sound/dialog if checking)
          // Ideally, we'd use a service for sound. For now, UI state reflects "Time's Up".
        }
      }

      notifyListeners();
    });
  }

  void _updateSessionCost(Session session) {
    if (session.endTime != null) return;

    final now = DateTime.now();
    final duration = now.difference(session.startTime);
    session.durationMinutes = duration.inMinutes;

    // Use the locked rate
    double rate = session.hourlyRate ?? 50.0;

    // Simple logic: Rate per minute (Total Hours * Rate)
    session.totalCost = (duration.inSeconds / 3600) * rate;
  }

  bool isTimeUp(Session session) {
    if (session.targetDurationMinutes == null) return false;
    return session.durationMinutes >= session.targetDurationMinutes!;
  }

  void stopSession(int sessionId, {bool addToRevenue = true}) async {
    final index = _activeSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _activeSessions[index];
      session.endTime = DateTime.now();
      _tickers[sessionId]?.cancel();
      _tickers.remove(sessionId);
      _alertedSessions.remove(sessionId);

      // Final Cost
      _updateSessionCost(session);

      if (!addToRevenue) {
        session.totalCost = 0.0; // Or handle differently in DB
      }

      // Update DB
      await DatabaseHelper.instance.updateSession(session);

      _activeSessions.removeAt(index);
      notifyListeners();
    }
  }

  Session? getSession(String deviceName) {
    try {
      return _activeSessions.firstWhere((s) => s.deviceName == deviceName);
    } catch (e) {
      return null;
    }
  }
}
