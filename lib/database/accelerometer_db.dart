import 'package:mobile_sensorium/database/database_service.dart';
import 'package:mobile_sensorium/model/accelerometer_record.dart';
import 'package:sqflite/sqflite.dart';

class AccelerometerDB {
  final tableName = "accelerometer_records";
  late final Database db;

  AccelerometerDB() {
    _init();
  }

  void _init() async {
    db = await DatabaseService().database;
  }

  Future<void> createTable(Database database) async {
    await database.execute(""" 
    CREATE TABLE IF NOT EXISTS $tableName (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "timestamp" INTEGER,
      "x" REAL,
      "y" REAL,
      "z" REAL,
      "orientation" TEXT,
      "action" TEXT
      );""");
  }

  Future<void> createAccelerometerRecord(AccelerometerRecord record) async {
    await db.rawInsert(
      'INSERT INTO $tableName (timestamp, x, y, z, orientation, action) VALUES (?, ?, ?, ?, ?, ?)',
      [
        record.timestamp,
        record.x,
        record.y,
        record.z,
        record.orientation,
        record.action
      ],
    );
  }

  Future<List<AccelerometerRecord>> fetchAllAccelerometerRecords() async {
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM accelerometer_records');

    return List.generate(result.length, (i) {
      return AccelerometerRecord.fromMap(result[i]);
    });
  }

  Future<void> clearDatabase() async {
    await db.rawDelete('DELETE FROM $tableName');
  }

  Future<int> getCount(String tableName) async {
    final data = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    int count = Sqflite.firstIntValue(data) ?? 0;
    return count;
  }
}
