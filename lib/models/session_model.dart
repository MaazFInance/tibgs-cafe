class DeviceType {
  static const String pc = 'PC';
  static const String console = 'Console';
}

class Session {
  final int? id;
  final String deviceName;
  final String deviceType; // 'PC' or 'Console'
  final DateTime startTime;
  DateTime? endTime;
  double totalCost;
  int durationMinutes; // Actual duration played
  int? targetDurationMinutes;
  double? hourlyRate;

  Session({
    this.id,
    required this.deviceName,
    required this.deviceType,
    required this.startTime,
    this.endTime,
    this.totalCost = 0.0,
    this.durationMinutes = 0,
    this.targetDurationMinutes,
    this.hourlyRate,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalCost': totalCost,
      'durationMinutes': durationMinutes,
      'targetDurationMinutes': targetDurationMinutes,
      'hourlyRate': hourlyRate,
    };
  }

  // Create from Map
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      deviceName: map['deviceName'],
      deviceType: map['deviceType'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      totalCost: map['totalCost'] ?? 0.0,
      durationMinutes: map['durationMinutes'] ?? 0,
      targetDurationMinutes: map['targetDurationMinutes'],
      hourlyRate: map['hourlyRate'],
    );
  }
}
