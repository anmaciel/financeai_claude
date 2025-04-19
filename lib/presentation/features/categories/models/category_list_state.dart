import 'package:financeai/data/models/category.dart';

/// Represents the possible states of loading categories
enum CategoryListStatus {
  /// Initial state, no data has been loaded yet
  initial,
  
  /// Data is currently being loaded
  loading,
  
  /// Data has been successfully loaded
  success,
  
  /// An error occurred while loading data
  error,
}

/// Represents the state of the category list screen.
///
/// This class holds the current status, list of categories, and any error message.
class CategoryListState {
  /// The current loading status
  final CategoryListStatus status;
  
  /// The list of categories to display
  final List<Category> categories;
  
  /// Optional error message when status is [CategoryListStatus.error]
  final String? errorMessage;

  /// Creates a new CategoryListState
  const CategoryListState({
    this.status = CategoryListStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  CategoryListState copyWith({
    CategoryListStatus? status,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return CategoryListState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Initial state with no categories
  factory CategoryListState.initial() {
    return const CategoryListState(
      status: CategoryListStatus.initial,
      categories: [],
    );
  }

  /// Loading state
  factory CategoryListState.loading() {
    return const CategoryListState(
      status: CategoryListStatus.loading,
      categories: [],
    );
  }

  /// Success state with a list of categories
  factory CategoryListState.success(List<Category> categories) {
    return CategoryListState(
      status: CategoryListStatus.success,
      categories: categories,
    );
  }

  /// Error state with an error message
  factory CategoryListState.error(String message) {
    return CategoryListState(
      status: CategoryListStatus.error,
      categories: [],
      errorMessage: message,
    );
  }
}