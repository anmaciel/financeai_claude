import 'package:financeai/core/constants/category_types.dart';
import 'package:flutter/material.dart';
import 'package:financeai/core/utils/color_utils.dart';
import 'package:financeai/core/constants/icon_constants.dart';

/// Represents a financial category for either income or expense.
///
/// Categories have properties like name, type (income or expense),
/// color, and icon to help users visually distinguish between them.
/// Categories can also have hierarchical relationships with parent-child links.
class Category {
  /// Unique identifier for the category
  final String id;

  /// Display name of the category
  final String name;

  /// Type of the category (income or expense)
  final CategoryType type;

  /// Color of the category, stored as a hex string (e.g., "#FF0000")
  final String color;

  /// Name of the icon to use for this category
  final String icon;

  /// Indicates whether this is a default category that cannot be deleted
  final bool isDefault;

  /// ID of the parent category if this is a subcategory
  final String? parentId;

  /// Creates a new Category instance
  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    this.isDefault = false,
    this.parentId,
  });

  /// Creates a copy of this Category with the given fields replaced with new values
  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? color,
    String? icon,
    bool? isDefault,
    String? parentId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      parentId: parentId ?? this.parentId,
    );
  }

  /// Converts a Category to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'color': color,
      'icon': icon,
      'isDefault': isDefault ? 1 : 0,
      'parentId': parentId,
    };
  }

  /// Creates a Category from a Map (e.g., from database)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: CategoryTypeExtension.fromString(map['type']),
      color: map['color'],
      icon: map['icon'],
      isDefault: map['isDefault'] == 1,
      parentId: map['parentId'],
    );
  }

  /// Creates a Category from a JSON map (e.g., from asset files)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['nome'] ?? '',
      type: json['tipo']?.toString().toLowerCase() == 'receita'
          ? CategoryType.INCOME
          : CategoryType.EXPENSE,
      color: json['color'] ?? '#CCCCCC',
      icon: json['icon_name'] ?? 'category',
      isDefault: json['is_fixed'] == 1,
      parentId: json['parentId'],
    );
  }

  /// Gets the Color object from the hex color string
  Color get colorObj => ColorUtils.fromHex(color);

  /// Gets the IconData object from the icon name
  IconData get iconData => IconConstants.getIconData(icon);

  /// Determines if this is a top-level category (has no parent)
  bool get isTopLevel => parentId == null;

  @override
  String toString() {
    return 'Category{id: $id, name: $name, type: $type, color: $color, icon: $icon, isDefault: $isDefault, parentId: $parentId}';
  }
}