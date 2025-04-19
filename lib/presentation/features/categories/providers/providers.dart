import 'package:financeai/data/repositories/category_repository.dart';
import 'package:financeai/presentation/features/categories/models/category_list_state.dart';
import 'package:financeai/presentation/features/categories/providers/category_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final repository = CategoryRepository();
  ref.onDispose(() {
    repository.close();
  });
  return repository;
});

/// Provider for initializing the repository
final repositoryInitializerProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  await repository.initialize();
});

/// Provider for the CategoryListViewModel
final categoryListViewModelProvider = StateNotifierProvider<CategoryListViewModel, CategoryListState>((ref) {
  // Ensure the repository has been initialized
  ref.watch(repositoryInitializerProvider);
  
  final repository = ref.read(categoryRepositoryProvider);
  return CategoryListViewModel(repository);
});