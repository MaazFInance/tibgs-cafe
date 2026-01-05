import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session_model.dart';
import '../models/device_model.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tibgs_cafe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // If upgrading, you might need onUpgrade. For now, simple version bump or recreate.
    // Since we are adding a table, we can just bump version and handle it,
    // OR since it's dev, just delete app data.
    // Let's increment version to 2 and add onUpgrade logic just in case.
    return await openDatabase(path,
        version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      await db.execute('''
        CREATE TABLE devices (
          id $idType,
          name $textType,
          type $textType
        )
      ''');
      // Seed Data during upgrade if needed
      await _seedDevices(db);
    }

    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN targetDurationMinutes INTEGER');
      await db.execute('ALTER TABLE sessions ADD COLUMN hourlyRate REAL');
    }
  }

  Future _seedDevices(Database db) async {
    // Seed default devices
    final batch = db.batch();
    for (int i = 1; i <= 5; i++) {
      batch.insert('devices', {'name': 'PC $i', 'type': 'PC'});
    }
    for (int i = 1; i <= 2; i++) {
      batch.insert('devices', {'name': 'Console $i', 'type': 'Console'});
    }
    await batch.commit();
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE sessions ( 
  id $idType, 
  deviceName $textType,
  deviceType $textType,
  startTime $textType,
  endTime TEXT,
  totalCost $realType,
  durationMinutes $intType,
  targetDurationMinutes INTEGER,
  hourlyRate REAL
  )
''');

    await db.execute('''
CREATE TABLE devices (
  id $idType,
  name $textType,
  type $textType
)
''');

    await _seedDevices(db);
  }

  Future<int> createSession(Session session) async {
    final db = await instance.database;
    return await db.insert('sessions', session.toMap());
  }

  Future<int> updateSession(Session session) async {
    final db = await instance.database;
    return db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<Session>> getAllSessions() async {
    final db = await instance.database;
    final orderBy = 'startTime DESC';
    final result = await db.query('sessions', orderBy: orderBy);

    return result.map((json) => Session.fromMap(json)).toList();
  }

  Future<List<Session>> getSessionsByDate(DateTime date) async {
    final db = await instance.database;

    // Simple filter string match for YYYY-MM-DD
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final result = await db.query(
      'sessions',
      where: 'startTime LIKE ?',
      whereArgs: ['$dateStr%'],
    );

    return result.map((json) => Session.fromMap(json)).toList();
  }

  // Analytics Queries
  Future<double> getDailyRevenue(DateTime date) async {
    final sessions = await getSessionsByDate(date);
    double total = 0;
    for (var s in sessions) {
      if (s.endTime != null) {
        total += s.totalCost;
      }
    }
    return total;
  }

  Future<Map<DateTime, double>> getWeeklyRevenue() async {
    final Map<DateTime, double> weeklyData = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final revenue = await getDailyRevenue(date);
      weeklyData[date] = revenue;
    }
    return weeklyData;
  }

  Future<Map<DateTime, double>> getMonthlyRevenue() async {
    final Map<DateTime, double> monthlyData = {};
    final now = DateTime.now();

    // Get last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final revenue = await getDailyRevenue(date);
      monthlyData[date] = revenue;
    }
    return monthlyData;
  }

  // Device Operations
  Future<int> addDevice(Device device) async {
    final db = await instance.database;
    return await db.insert('devices', device.toMap());
  }

  Future<int> deleteDevice(int id) async {
    final db = await instance.database;
    return await db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Device>> getAllDevices() async {
    final db = await instance.database;
    final result = await db.query('devices', orderBy: 'name ASC');
    return result.map((json) => Device.fromMap(json)).toList();
  }
}
