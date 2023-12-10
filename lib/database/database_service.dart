import 'package:mobile_sensorium/database/accelerometer_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'accelerometer.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      singleInstance: true,
    );
    return database;
  }

  Future<void> _onUpgrade(
      Database database, int oldVersion, int newVersion) async {
    await database.execute('DROP TABLE IF EXISTS accelerometer_records');
    _onCreate(database, newVersion);
  }

  Future<void> _onCreate(Database database, int version) async =>
      await AccelerometerDB().createTable(database);
}
