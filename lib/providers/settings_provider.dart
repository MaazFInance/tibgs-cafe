import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _pcHourlyRate = 50.0;
  double _consoleHourlyRate = 80.0;

  double get pcHourlyRate => _pcHourlyRate;
  double get consoleHourlyRate => _consoleHourlyRate;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _pcHourlyRate = prefs.getDouble('pcHourlyRate') ?? 50.0;
    _consoleHourlyRate = prefs.getDouble('consoleHourlyRate') ?? 80.0;
    notifyListeners();
  }

  Future<void> updatePCRate(double rate) async {
    _pcHourlyRate = rate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pcHourlyRate', rate);
    notifyListeners();
  }

  Future<void> updateConsoleRate(double rate) async {
    _consoleHourlyRate = rate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('consoleHourlyRate', rate);
    notifyListeners();
  }
}
