import 'package:financeai/core/constants/category_types.dart';
import 'package:financeai/data/models/category.dart';
import 'package:sqflite/sqflite.dart';

/// Data Access Object for managing Category objects in the database.
///
/// This class handles all database operations related to Categories,
/// including creating, reading, updating, and deleting.
class CategoryDao {
  final Database _db;

  /// Table name for categories
  static const String tableName = 'categories';

  /// Constructor that takes a database instance
  CategoryDao(this._db);

  /// Creates the categories table in the database
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color TEXT NOT NULL,
        icon TEXT NOT NULL,
        isDefault INTEGER NOT NULL,
        parentId TEXT
      )
    ''');
  }

  /// Inserts a new category into the database
  Future<int> insert(Category category) async {
    return await _db.insert(
      tableName,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing category in the database
  Future<int> update(Category category) async {
    return await _db.update(
      tableName,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Deletes a category from the database by its ID
  Future<int> delete(String id) async {
    return await _db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets a category by its ID
  Future<Category?> getCategoryById(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Category.fromMap(maps.first);
  }

  /// Gets all categories
  Future<List<Category>> getAllCategories() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Gets all categories of a specific type
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Get top-level categories (categories without a parent)
  Future<List<Category>> getTopLevelCategories() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'parentId IS NULL',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Get top-level categories of a specific type
  Future<List<Category>> getTopLevelCategoriesByType(CategoryType type) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'parentId IS NULL AND type = ?',
      whereArgs: [type.name],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Get subcategories for a given parent category ID
  Future<List<Category>> getSubcategories(String parentId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'parentId = ?',
      whereArgs: [parentId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Batch inserts a list of categories into the database
  Future<void> insertCategories(List<Category> categories) async {
    final Batch batch = _db.batch();
    for (var category in categories) {
      batch.insert(
        tableName,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Checks if a category exists by its ID
  Future<bool> categoryExists(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  /// Delete all categories and their subcategories
  Future<void> deleteAllCategories() async {
    await _db.delete(tableName);
  }
}