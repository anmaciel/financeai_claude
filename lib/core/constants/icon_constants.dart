import 'package:flutter/material.dart';

/// A class that provides a mapping between icon names and their corresponding IconData objects.
class IconConstants {
  /// A map that associates string names with Material icons
  static final Map<String, IconData> icons = {
    'add': Icons.add,
    'attach_money': Icons.attach_money,
    'bolt': Icons.bolt,
    'calendar_today': Icons.calendar_today,
    'credit_card': Icons.credit_card,
    'delete': Icons.delete,
    'directions_car': Icons.directions_car,
    'edit': Icons.edit,
    'favorite': Icons.favorite,
    'folder': Icons.folder,
    'home': Icons.home,
    'lightbulb': Icons.lightbulb,
    'local_grocery_store': Icons.local_grocery_store,
    'local_hospital': Icons.local_hospital,
    'movie': Icons.movie,
    'payment': Icons.payment,
    'pets': Icons.pets,
    'phone': Icons.phone,
    'restaurant': Icons.restaurant,
    'school': Icons.school,
    'shopping_cart': Icons.shopping_cart,
    'star': Icons.star,
    'train': Icons.train,
    'trending_up': Icons.trending_up,
    'work': Icons.work,
  };

  /// Returns the IconData associated with the given name.
  /// 
  /// If the name is not found in the map, returns a default icon (Icons.category).
  static IconData getIconData(String iconName) {
    return icons[iconName] ?? Icons.category;
  }

  /// Returns a list of all available icon names.
  static List<String> getAllIconNames() {
    return icons.keys.toList();
  }
}