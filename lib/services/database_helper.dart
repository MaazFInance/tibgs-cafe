import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'session_model.dart';
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
  durationMinutes $intType
  )
''');
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
}
