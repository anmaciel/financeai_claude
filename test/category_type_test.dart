// Tests for CategoryType enum functionality

import 'package:financeai/core/constants/category_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryType Tests', () {
    test('fromString returns correct type for INCOME', () {
      final type = CategoryTypeExtension.fromString('INCOME');
      expect(type, CategoryType.INCOME);
    });

    test('fromString returns correct type for EXPENSE', () {
      final type = CategoryTypeExtension.fromString('EXPENSE');
      expect(type, CategoryType.EXPENSE);
    });

    test('fromString handles default value for unknown strings', () {
      final type = CategoryTypeExtension.fromString('unknown');
      expect(type, CategoryType.EXPENSE); // Default should be expense
    });

    test('getLocalizedName returns correct name in English', () {
      expect(CategoryType.INCOME.getLocalizedName(false), 'Income');
      expect(CategoryType.EXPENSE.getLocalizedName(false), 'Expense');
    });
    
    test('getLocalizedName returns correct name in Portuguese', () {
      expect(CategoryType.INCOME.getLocalizedName(true), 'Receita');
      expect(CategoryType.EXPENSE.getLocalizedName(true), 'Despesa');
    });
  });
}