import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/device_model.dart';
import '../services/database_helper.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _activeSessions = [];
  List<Device> _devices = [];
  Map<int, Timer> _tickers = {};

  // Settings (Could be moved to a settings provider)
  double pcHourlyRate = 50.0;
  double consoleHourlyRate = 80.0;

  List<Session> get activeSessions => _activeSessions;
  List<Device> get devices => _devices;

  List<Device> get pcDevices => _devices.where((d) => d.type == 'PC').toList();
  List<Device> get consoleDevices =>
      _devices.where((d) => d.type == 'Console').toList();

  SessionProvider() {
    loadDevices();
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

  // Initialize: Load any active sessions from DB?
  // For V1 we assume app state clears on restart, but we can load unfinished sessions later.

  void startSession(String deviceName, String deviceType) async {
    final startTime = DateTime.now();
    final newSession = Session(
      deviceName: deviceName,
      deviceType: deviceType,
      startTime: startTime,
    );

    // Save to DB to get ID
    int id = await DatabaseHelper.instance.createSession(newSession);

    // Create in-memory object with ID
    final sessionWithId = Session(
      id: id,
      deviceName: deviceName,
      deviceType: deviceType,
      startTime: startTime,
    );

    _activeSessions.add(sessionWithId);
    _startTicker(sessionWithId);
    notifyListeners();
  }

  void _startTicker(Session session) {
    // Update UI every minute or second
    _tickers[session.id!] = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Calculate current cost
      _updateSessionCost(session);
      notifyListeners();
    });
  }

  void _updateSessionCost(Session session) {
    if (session.endTime != null) return; // Already stopped

    final now = DateTime.now();
    final duration = now.difference(session.startTime);
    session.durationMinutes = duration.inMinutes;

    double rate =
        session.deviceType == DeviceType.pc ? pcHourlyRate : consoleHourlyRate;

    // Simple logic: Rate per minute
    session.totalCost = (duration.inSeconds / 3600) * rate;
  }

  void addTime(int sessionId, int hoursToAdd) {
    // NOTE: "Add Time" in this context usually means "Extend the allowed time"
    // BUT the user prompt says "Add 1 hour... The added time should: Increase the session’s allowed duration, Be reflected in pricing instantly"
    // Since this is a "Pay as you go" or "Prepaid" hybrid, we need to clarify logic.
    // For now, if "Add Time" acts as a prepayment or a target, we might need a targetEndTime.
    // Implementing as "Extension" for now (just visual or logic later).
    //
    // If the requirement means "Prepay", we just update cost?
    // Let's assume standard "Start/Stop" flow first as per primary description.
    // "Add Time" might just update a "Paid Until" marker.
    notifyListeners();
  }

  void stopSession(int sessionId) async {
    final index = _activeSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _activeSessions[index];
      session.endTime = DateTime.now();
      _tickers[sessionId]?.cancel();
      _tickers.remove(sessionId);

      // Final Cost Calculation
      _updateSessionCost(session);

      // Update DB
      await DatabaseHelper.instance.updateSession(session);

      // Remove from active
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
