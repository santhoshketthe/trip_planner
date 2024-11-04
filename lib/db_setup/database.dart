import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'day_planner.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('ALTER TABLE Activities ADD COLUMN priority TEXT');

      await db.execute('ALTER TABLE Activities ADD COLUMN description TEXT');
    }
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Trips (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
  ''');

    await db.execute(''' 
  CREATE TABLE Activities ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    date TEXT, 
    trip_id TEXT, 
    category TEXT, 
    time TEXT, 
    priority TEXT,
    description TEXT,
    FOREIGN KEY (trip_id) REFERENCES Trips(id) ON DELETE CASCADE 
  ) 
''');

  }
  Future<void> saveTrip(String tripName, List<Map<String, dynamic>> days, Map<int, List<Map<String, dynamic>>> activitiesPerDay) async {
    final db = await database;

    await db.transaction((txn) async {

      await txn.insert('Trips', {
        'name': tripName,
      });

      for (var day in days) {
        var activities = activitiesPerDay[day['id']] ?? [];
        for (var activity in activities) {
          await txn.insert('Activities', {
            'date' : day['date'],
            'trip_id': tripName,
            'priority' : activity['priority'],
            'description' : activity['description'],
            'category': activity['category'],
            'time': activity['time'],
          });
        }
      }
    });
  }

  Future<bool> checkTripNameExists(String tripName) async{
    final db = await database;
    List check = await db.query('Trips',where: " name = ?",whereArgs: [tripName]);
    return check.isNotEmpty;
  }

  Future<void> deleteTrip(tripName) async{
    final db = await database;
     await db.delete('Trips',where: "name = ? ",whereArgs: [tripName]);
     await db.delete('Activities',where: "trip_id = ?",whereArgs: [tripName]);
  }

  Future<void> updateTrip(String tripName, List<Map<String, dynamic>> days, Map<int, List<Map<String, dynamic>>> activitiesPerDay) async {
    final db = await database;

    await db.transaction((txn) async {

      await txn.update('Trips', {'name': tripName}, where: 'name = ?', whereArgs: [tripName]);

      await txn.delete('Activities',where: 'trip_id =?',whereArgs: [tripName]);
      for (var day in days) {
        var activities = activitiesPerDay[day['id']] ?? [];
        for (var activity in activities) {
          await txn.insert('Activities', {
            'date' : day['date'],
            'trip_id': tripName,
            'priority' : activity['priority'],
            'description' : activity['description'],
            'category': activity['category'],
            'time': activity['time'],
          });
        }
      }
    });
  }

}
