class Device {
  final int? id;
  final String name;
  final String type; // 'PC' or 'Console'

  Device({this.id, required this.name, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      name: map['name'],
      type: map['type'],
    );
  }
}
