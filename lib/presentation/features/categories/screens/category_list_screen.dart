import 'package:financeai/core/constants/category_types.dart';
import 'package:financeai/data/models/category.dart';
import 'package:financeai/presentation/features/categories/models/category_list_state.dart';
import 'package:financeai/presentation/features/categories/providers/providers.dart';
import 'package:financeai/presentation/features/categories/screens/category_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen that displays a list of categories and allows the user to add, edit, or delete them.
class CategoryListScreen extends ConsumerWidget {
  /// Creates a CategoryListScreen
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          PopupMenuButton<CategoryType>(
            icon: const Icon(Icons.filter_list),
            onSelected: (CategoryType type) {
              ref.read(categoryListViewModelProvider.notifier).loadCategoriesByType(type);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: const Text('All Categories'),
                onTap: () {
                  ref.read(categoryListViewModelProvider.notifier).loadCategories();
                },
              ),
              const PopupMenuDivider(),
              ...CategoryType.values.map((type) => PopupMenuItem(
                value: type,
                child: Text(type.getLocalizedName(false)),
              )),
            ],
          ),
        ],
      ),
      body: _buildBody(context, state, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCategory(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CategoryListState state, WidgetRef ref) {
    switch (state.status) {
      case CategoryListStatus.initial:
      case CategoryListStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CategoryListStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${state.errorMessage}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(categoryListViewModelProvider.notifier).loadCategories(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      case CategoryListStatus.success:
        if (state.categories.isEmpty) {
          return const Center(
            child: Text('No categories found. Add one by tapping the + button.'),
          );
        }

        return ListView.builder(
          itemCount: state.categories.length,
          itemBuilder: (context, index) {
            final category = state.categories[index];
            return _buildCategoryItem(context, category, ref);
          },
        );
    }
  }

  Widget _buildCategoryItem(BuildContext context, Category category, WidgetRef ref) {
    return Dismissible(
      key: Key(category.id),
      direction: category.isDefault
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (category.isDefault) return false;

        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text('Are you sure you want to delete "${category.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        ref.read(categoryListViewModelProvider.notifier).deleteCategory(category.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(categoryListViewModelProvider.notifier).createCategory(category);
              },
            ),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.colorObj,
          child: Icon(
            category.iconData,
            color: Colors.white,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(category.type.getLocalizedName(false)),
        trailing: category.isDefault
            ? const Chip(label: Text('Default'))
            : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditCategory(context, category),
              ),
        onTap: () => _navigateToEditCategory(context, category),
      ),
    );
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoryFormScreen(),
      ),
    );
  }

  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(
          category: category,
        ),
      ),
    );
  }
}