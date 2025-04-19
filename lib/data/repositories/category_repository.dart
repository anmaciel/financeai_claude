import 'dart:convert';
import 'dart:io';

import 'package:financeai/core/constants/category_types.dart';
import 'package:financeai/data/daos/category_dao.dart';
import 'package:financeai/data/database/database_helper.dart';
import 'package:financeai/data/models/category.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing categories, providing a clean API over the DAO layer.
///
/// This class handles business logic related to categories, including loading
/// default categories from JSON files, and providing methods to interact with
/// the category data.
class CategoryRepository {
  late CategoryDao _categoryDao;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  /// Initializes the repository and database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _categoryDao = await _databaseHelper.getCategoryDao();
    
    // Load default categories if needed
    await _loadDefaultCategoriesIfNeeded();
    
    _isInitialized = true;
  }

  /// Checks if default categories need to be loaded and loads them if so
  Future<void> _loadDefaultCategoriesIfNeeded() async {
    final categories = await _categoryDao.getAllCategories();
    if (categories.isEmpty) {
      await _loadDefaultCategories();
    }
  }

  /// Loads default categories from JSON files
  Future<void> _loadDefaultCategories() async {
    // Determine which language to use based on the device locale
    final String languageCode = Platform.localeName.substring(0, 2).toLowerCase();
    final String assetPath = languageCode == 'pt'
        ? 'assets/constants/categories_pt.json'
        : 'assets/constants/categories_en.json';

    try {
      final String jsonContent = await rootBundle.loadString(assetPath);
      final List<dynamic> categoryList = json.decode(jsonContent);
      
      // Process top-level categories and subcategories
      List<Category> allCategories = [];
      
      for (var topCat in categoryList) {
        final mainCategory = _processCategory(topCat);
        allCategories.add(mainCategory);
        
        // Process subcategories if they exist
        if (topCat['subcategorias'] != null) {
          for (var subCat in topCat['subcategorias']) {
            final subCategory = _processCategory(subCat, parentId: mainCategory.id);
            allCategories.add(subCategory);
            
            // Process third-level subcategories if they exist
            if (subCat['subcategorias'] != null) {
              for (var thirdCat in subCat['subcategorias']) {
                final thirdCategory = _processCategory(thirdCat, parentId: subCategory.id);
                allCategories.add(thirdCategory);
              }
            }
          }
        }
      }

      await _categoryDao.insertCategories(allCategories);
    } catch (e) {
      print('Error loading default categories: $e');
    }
  }
  
  /// Process a category from JSON format into a Category object
  Category _processCategory(Map<String, dynamic> json, {String? parentId}) {
    final String id = json['id'] ?? _uuid.v4();
    final String name = json['nome'] ?? '';
    final String rawType = json['tipo'] ?? 'despesa';
    
    // Convert tipo string to CategoryType enum
    final CategoryType type = rawType.toLowerCase() == 'receita' 
        ? CategoryType.INCOME 
        : CategoryType.EXPENSE;
    
    final String color = json['color'] ?? '#CCCCCC';
    final String icon = json['icon_name'] ?? 'category';
    final bool isDefault = json['is_fixed'] == 1;
    
    return Category(
      id: id,
      name: name,
      type: type,
      color: color,
      icon: icon,
      isDefault: isDefault,
      parentId: parentId,
    );
  }

  /// Gets all categories
  Future<List<Category>> getAllCategories() async {
    if (!_isInitialized) await initialize();
    return await _categoryDao.getAllCategories();
  }

  /// Gets categories of a specific type
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    if (!_isInitialized) await initialize();
    return await _categoryDao.getCategoriesByType(type);
  }

  /// Gets a category by its ID
  Future<Category?> getCategoryById(String id) async {
    if (!_isInitialized) await initialize();
    return await _categoryDao.getCategoryById(id);
  }

  /// Creates a new category
  Future<bool> createCategory(Category category) async {
    if (!_isInitialized) await initialize();
    try {
      final newCategory = category.copyWith(
        id: category.id.isEmpty ? _uuid.v4() : category.id,
      );
      await _categoryDao.insert(newCategory);
      return true;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  /// Updates an existing category
  Future<bool> updateCategory(Category category) async {
    if (!_isInitialized) await initialize();
    try {
      await _categoryDao.update(category);
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  /// Deletes a category by its ID
  Future<bool> deleteCategory(String id) async {
    if (!_isInitialized) await initialize();
    try {
      // Check if the category is a default category
      final category = await getCategoryById(id);
      if (category != null && category.isDefault) {
        return false; // Cannot delete default categories
      }
      
      await _categoryDao.delete(id);
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  /// Get top-level categories (categories without a parent)
  Future<List<Category>> getTopLevelCategories() async {
    if (!_isInitialized) await initialize();
    return await _categoryDao.getTopLevelCategories();
  }

  /// Get subcategories for a given parent category ID
  Future<List<Category>> getSubcategories(String parentId) async {
    if (!_isInitialized) await initialize();
    return await _categoryDao.getSubcategories(parentId);
  }

  /// Close the database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }
}