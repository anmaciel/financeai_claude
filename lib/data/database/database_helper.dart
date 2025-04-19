import 'package:financeai/data/daos/category_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class to manage database connections and initialization.
///
/// This centralizes database operations like opening, creating, upgrading,
/// and providing access to DAOs.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Database name and version
  static const String _databaseName = 'financeai.db';
  static const int _databaseVersion = 1;

  // Factory constructor to return the same instance every time
  factory DatabaseHelper() {
    return _instance;
  }

  // Private constructor to enforce singleton pattern
  DatabaseHelper._internal();

  /// Initializes and gets the database.
  ///
  /// Returns the database instance. Creates it if not already created.
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database.
  ///
  /// Creates the database file, opens a connection, and sets up the tables.
  Future<Database> _initDatabase() async {
    // Get the path to the database file
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    // Open/create the database at the given path
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the database tables when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    // Create category table
    await CategoryDao(db).createTable(db);
    
    // Additional tables can be created here
    // await TransactionDao(db).createTable(db);
    // await AccountDao(db).createTable(db);
  }

  /// Handles database upgrades when version is increased.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations between database versions
    if (oldVersion < 2) {
      // Example: add a new column to an existing table when upgrading to version 2
      // await db.execute('ALTER TABLE categories ADD COLUMN parent_id TEXT;');
    }
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Deletes the database file.
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Gets a CategoryDao instance.
  Future<CategoryDao> getCategoryDao() async {
    final db = await database;
    return CategoryDao(db);
  }
}