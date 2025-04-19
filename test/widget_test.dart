// FinanceAI widget tests
//
// Verifies the basic functionality of the FinanceAI application.

import 'package:flutter_test/flutter_test.dart';
import 'package:financeai/data/models/category.dart';
import 'package:financeai/core/constants/category_types.dart';

void main() {
  group('FinanceAI Tests', () {
    // Skip the widget test that requires database initialization
    // testWidgets('App loads with title', (WidgetTester tester) async {
    //   // Build our app and trigger a frame.
    //   await tester.pumpWidget(
    //     const ProviderScope(child: FinanceAIApp()),
    //   );

    //   // Verify that our loading screen appears
    //   expect(find.text('Loading FinanceAI...'), findsOneWidget);
    // });

    test('Category model initializes correctly', () {
      final category = Category(
        id: 'test-id',
        name: 'Groceries',
        type: CategoryType.EXPENSE,
        color: '#FF0000',
        icon: 'shopping_cart',
      );

      expect(category.id, 'test-id');
      expect(category.name, 'Groceries');
      expect(category.type, CategoryType.EXPENSE);
      expect(category.color, '#FF0000');
      expect(category.icon, 'shopping_cart');
      expect(category.isDefault, false);
    });

    test('Category copyWith works correctly', () {
      final category = Category(
        id: 'test-id',
        name: 'Groceries',
        type: CategoryType.EXPENSE,
        color: '#FF0000',
        icon: 'shopping_cart',
      );

      final updatedCategory = category.copyWith(
        name: 'Food',
        color: '#00FF00',
      );

      expect(updatedCategory.id, 'test-id');
      expect(updatedCategory.name, 'Food');
      expect(updatedCategory.type, CategoryType.EXPENSE);
      expect(updatedCategory.color, '#00FF00');
      expect(updatedCategory.icon, 'shopping_cart');
      expect(updatedCategory.isDefault, false);
    });

    test('Category toMap and fromMap work correctly', () {
      final originalCategory = Category(
        id: 'test-id',
        name: 'Groceries',
        type: CategoryType.EXPENSE,
        color: '#FF0000',
        icon: 'shopping_cart',
        isDefault: true,
      );

      final map = originalCategory.toMap();
      final recreatedCategory = Category.fromMap(map);

      expect(recreatedCategory.id, originalCategory.id);
      expect(recreatedCategory.name, originalCategory.name);
      expect(recreatedCategory.type, originalCategory.type);
      expect(recreatedCategory.color, originalCategory.color);
      expect(recreatedCategory.icon, originalCategory.icon);
      expect(recreatedCategory.isDefault, originalCategory.isDefault);
    });
  });
}
