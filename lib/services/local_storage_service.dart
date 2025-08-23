import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Database? _database;
  SharedPreferences? _prefs;

  // Initialize the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  // Initialize SQLite database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'amuma.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Medications table
        await db.execute('''
          CREATE TABLE medications (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            dosage TEXT NOT NULL,
            times TEXT NOT NULL,
            isCompleted TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        // Health entries table
        await db.execute('''
          CREATE TABLE health_entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            bloodPressureSystolic INTEGER,
            bloodPressureDiastolic INTEGER,
            bloodSugar INTEGER,
            weight REAL,
            notes TEXT,
            createdAt TEXT NOT NULL
          )
        ''');

        // Appointments table
        await db.execute('''
          CREATE TABLE appointments (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            location TEXT NOT NULL,
            type TEXT NOT NULL,
            notes TEXT,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');

        // Badges table
        await db.execute('''
          CREATE TABLE badges (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            dateEarned TEXT,
            progress INTEGER DEFAULT 0,
            target INTEGER DEFAULT 1
          )
        ''');

        // Streaks table
        await db.execute('''
          CREATE TABLE streaks (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            count INTEGER NOT NULL DEFAULT 0,
            lastUpdate TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Shared Preferences methods for simple key-value storage
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // User preferences
  Future<void> setLanguage(String language) async {
    await setString('language', language);
  }

  String getLanguage() {
    return getString('language') ?? 'EN';
  }

  Future<void> setUserProfile(Map<String, dynamic> profile) async {
    await setString('user_profile', jsonEncode(profile));
  }

  Map<String, dynamic>? getUserProfile() {
    final profileJson = getString('user_profile');
    if (profileJson != null) {
      return jsonDecode(profileJson);
    }
    return null;
  }

  // Medication methods
  Future<void> saveMedication(Map<String, dynamic> medication) async {
    await _database?.insert(
      'medications',
      medication,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMedications() async {
    return await _database?.query('medications') ?? [];
  }

  Future<void> updateMedicationCompletion(
      String id, List<bool> isCompleted) async {
    await _database?.update(
      'medications',
      {'isCompleted': jsonEncode(isCompleted)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMedication(String id) async {
    await _database?.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Health entries methods
  Future<void> saveHealthEntry(Map<String, dynamic> entry) async {
    await _database?.insert(
      'health_entries',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHealthEntries({int? limit}) async {
    if (limit != null) {
      return await _database?.query(
            'health_entries',
            orderBy: 'date DESC',
            limit: limit,
          ) ??
          [];
    }
    return await _database?.query(
          'health_entries',
          orderBy: 'date DESC',
        ) ??
        [];
  }

  Future<void> deleteHealthEntry(String id) async {
    await _database?.delete(
      'health_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointments methods
  Future<void> saveAppointment(Map<String, dynamic> appointment) async {
    await _database?.insert(
      'appointments',
      appointment,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAppointments() async {
    return await _database?.query(
          'appointments',
          orderBy: 'date ASC',
        ) ??
        [];
  }

  Future<void> updateAppointmentCompletion(String id, bool isCompleted) async {
    await _database?.update(
      'appointments',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAppointment(String id) async {
    await _database?.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Badges methods
  Future<void> saveBadge(Map<String, dynamic> badge) async {
    await _database?.insert(
      'badges',
      badge,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getBadges() async {
    return await _database?.query('badges') ?? [];
  }

  Future<List<Map<String, dynamic>>> getEarnedBadges() async {
    return await _database?.query(
          'badges',
          where: 'dateEarned IS NOT NULL',
          orderBy: 'dateEarned DESC',
        ) ??
        [];
  }

  Future<void> awardBadge(String id, String dateEarned) async {
    await _database?.update(
      'badges',
      {'dateEarned': dateEarned},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateBadgeProgress(String id, int progress) async {
    await _database?.update(
      'badges',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Streaks methods
  Future<void> saveStreak(Map<String, dynamic> streak) async {
    await _database?.insert(
      'streaks',
      streak,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getStreak(String type) async {
    final result = await _database?.query(
      'streaks',
      where: 'type = ?',
      whereArgs: [type],
    );
    return result?.isNotEmpty == true ? result!.first : null;
  }

  Future<void> updateStreak(String type, int count) async {
    final now = DateTime.now().toIso8601String();
    await _database?.update(
      'streaks',
      {
        'count': count,
        'lastUpdate': now,
      },
      where: 'type = ?',
      whereArgs: [type],
    );

    // If streak doesn't exist, create it
    final existing = await getStreak(type);
    if (existing == null) {
      await saveStreak({
        'id': '${type}_streak',
        'type': type,
        'count': count,
        'lastUpdate': now,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllStreaks() async {
    return await _database?.query('streaks') ?? [];
  }

  // Emergency profile methods
  Future<void> setEmergencyProfile(Map<String, dynamic> profile) async {
    await setString('emergency_profile', jsonEncode(profile));
  }

  Map<String, dynamic>? getEmergencyProfile() {
    final profileJson = getString('emergency_profile');
    if (profileJson != null) {
      return jsonDecode(profileJson);
    }
    return null;
  }

  // First time setup
  Future<void> setFirstTimeSetupComplete(bool completed) async {
    await setBool('first_time_setup_complete', completed);
  }

  bool isFirstTimeSetupComplete() {
    return getBool('first_time_setup_complete') ?? false;
  }

  // Data export/import for backup
  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'medications': await getMedications(),
      'health_entries': await getHealthEntries(),
      'appointments': await getAppointments(),
      'badges': await getBadges(),
      'streaks': await getAllStreaks(),
      'user_profile': getUserProfile(),
      'emergency_profile': getEmergencyProfile(),
      'language': getLanguage(),
      'export_date': DateTime.now().toIso8601String(),
    };
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await _prefs?.clear();
    if (_database != null) {
      await _database!.delete('medications');
      await _database!.delete('health_entries');
      await _database!.delete('appointments');
      await _database!.delete('badges');
      await _database!.delete('streaks');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _database?.close();
  }
}
