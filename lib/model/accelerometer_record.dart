class AccelerometerRecord {
  final int? id;
  final String timestamp;
  final double x;
  final double y;
  final double z;
  final String orientation;
  final String action;

  AccelerometerRecord({
    this.id, // id is nullable because it will be auto-generated by the database
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
    required this.orientation,
    required this.action,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'x': x,
      'y': y,
      'z': z,
      'orientation': orientation,
      'action': action,
    };
  }

  factory AccelerometerRecord.fromMap(Map<String, dynamic> map) {
    return AccelerometerRecord(
      id: map['id'],
      timestamp: map['timestamp'],
      x: map['x'],
      y: map['y'],
      z: map['z'],
      orientation: map['orientation'],
      action: map['action'],
    );
  }

  @override
  String toString() {
    return 'AccelerometerRecord{id: $id, timestamp: $timestamp, x: $x, y: $y, z: $z, orientation: $orientation, action: $action}';
  }
}
