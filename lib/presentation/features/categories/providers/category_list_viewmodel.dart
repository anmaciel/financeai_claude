import 'package:financeai/core/constants/category_types.dart';
import 'package:financeai/data/models/category.dart';
import 'package:financeai/data/repositories/category_repository.dart';
import 'package:financeai/presentation/features/categories/models/category_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the CategoryList ViewModel
///
/// This class manages the state of the category list and provides methods
/// to interact with categories (add, edit, delete).
class CategoryListViewModel extends StateNotifier<CategoryListState> {
  final CategoryRepository _repository;

  /// Creates a CategoryListViewModel with a repository
  CategoryListViewModel(this._repository) : super(CategoryListState.initial()) {
    loadCategories();
  }

  /// Loads all categories from the repository
  Future<void> loadCategories() async {
    try {
      state = CategoryListState.loading();
      final categories = await _repository.getAllCategories();
      state = CategoryListState.success(categories);
    } catch (e) {
      state = CategoryListState.error('Failed to load categories: $e');
    }
  }

  /// Loads categories of a specific type
  Future<void> loadCategoriesByType(CategoryType type) async {
    try {
      state = CategoryListState.loading();
      final categories = await _repository.getCategoriesByType(type);
      state = CategoryListState.success(categories);
    } catch (e) {
      state = CategoryListState.error('Failed to load categories: $e');
    }
  }

  /// Creates a new category
  Future<bool> createCategory(Category category) async {
    try {
      final success = await _repository.createCategory(category);
      if (success) {
        await loadCategories();
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create category: $e',
      );
      return false;
    }
  }

  /// Updates an existing category
  Future<bool> updateCategory(Category category) async {
    try {
      final success = await _repository.updateCategory(category);
      if (success) {
        await loadCategories();
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update category: $e',
      );
      return false;
    }
  }

  /// Deletes a category by ID
  Future<bool> deleteCategory(String id) async {
    try {
      final success = await _repository.deleteCategory(id);
      if (success) {
        await loadCategories();
      } else {
        state = state.copyWith(
          errorMessage: 'Cannot delete a default category',
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete category: $e',
      );
      return false;
    }
  }
}