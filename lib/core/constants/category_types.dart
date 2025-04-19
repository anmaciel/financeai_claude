/// Defines the types of categories available in the application.
///
/// Categories can be either for income or expense transactions.
enum CategoryType {
  /// Represents income categories like salary, investments, etc.
  INCOME,

  /// Represents expense categories like food, transportation, etc.
  EXPENSE,
}

/// Extension on CategoryType to provide utility methods
extension CategoryTypeExtension on CategoryType {
  /// Returns the string representation of the category type
  String get name => toString().split('.').last;

  /// Returns a localized name based on the type
  String getLocalizedName(bool isPtBr) {
    switch (this) {
      case CategoryType.INCOME:
        return isPtBr ? 'Receita' : 'Income';
      case CategoryType.EXPENSE:
        return isPtBr ? 'Despesa' : 'Expense';
    }
  }

  /// Converts a string to CategoryType
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CategoryType.EXPENSE,
    );
  }
}