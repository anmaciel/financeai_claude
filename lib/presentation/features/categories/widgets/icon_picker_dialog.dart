import 'package:financeai/core/constants/icon_constants.dart';
import 'package:flutter/material.dart';

/// A dialog for picking an icon from the available icon set.
///
/// Displays a grid of icons for the user to choose from.
class IconPickerDialog extends StatelessWidget {
  final String? initialIconName;

  /// Creates an IconPickerDialog
  const IconPickerDialog({
    Key? key,
    this.initialIconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconNames = IconConstants.getAllIconNames();
    
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select an Icon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: iconNames.length,
                itemBuilder: (context, index) {
                  final iconName = iconNames[index];
                  final isSelected = iconName == initialIconName;
                  
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop(iconName);
                    },
                    child: CircleAvatar(
                      backgroundColor: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.surface,
                      child: Icon(
                        IconConstants.getIconData(iconName),
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimary 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the icon picker dialog and returns the selected icon name
  static Future<String?> show(BuildContext context, {String? initialIconName}) {
    return showDialog<String>(
      context: context,
      builder: (context) => IconPickerDialog(
        initialIconName: initialIconName,
      ),
    );
  }
}