import 'package:financeai/core/constants/category_types.dart';
import 'package:financeai/core/constants/icon_constants.dart';
import 'package:financeai/core/utils/color_utils.dart';
import 'package:financeai/data/models/category.dart';
import 'package:financeai/presentation/features/categories/providers/providers.dart';
import 'package:financeai/presentation/features/categories/widgets/icon_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Screen for adding or editing a category.
class CategoryFormScreen extends ConsumerStatefulWidget {
  final Category? category;

  /// Creates a CategoryFormScreen
  ///
  /// If [category] is provided, the screen will be in edit mode.
  /// Otherwise, it will be in add mode.
  const CategoryFormScreen({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late CategoryType _selectedType;
  late Color _selectedColor;
  late String _selectedIconName;
  bool _isEditing = false;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }

  void _initializeFormValues() {
    _isEditing = widget.category != null;
    
    if (_isEditing) {
      final category = widget.category!;
      _nameController.text = category.name;
      _selectedType = category.type;
      _selectedColor = ColorUtils.fromHex(category.color);
      _selectedIconName = category.icon;
      _isDefault = category.isDefault;
    } else {
      _selectedType = CategoryType.EXPENSE;
      _selectedColor = Colors.blue;
      _selectedIconName = 'category';
      _isDefault = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              enabled: !_isDefault, // Disable for default categories
            ),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildIconSelector(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isDefault ? null : _saveCategory,
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
            if (_isDefault) ...[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Default categories cannot be modified',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category Type'),
        const SizedBox(height: 8),
        SegmentedButton<CategoryType>(
          segments: CategoryType.values.map((type) => 
            ButtonSegment<CategoryType>(
              value: type,
              label: Text(type.getLocalizedName(false)),
              icon: Icon(type == CategoryType.INCOME 
                ? Icons.arrow_upward 
                : Icons.arrow_downward),
            )
          ).toList(),
          selected: {_selectedType},
          onSelectionChanged: _isDefault 
              ? null 
              : (Set<CategoryType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isDefault ? null : _openColorPicker,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.of(context).pop();
            },
            availableColors: ColorUtils.getPredefinedColors(),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isDefault ? null : _openIconPicker,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Center(
              child: Icon(
                IconConstants.getIconData(_selectedIconName),
                size: 40,
                color: _selectedColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openIconPicker() async {
    final selectedIcon = await IconPickerDialog.show(
      context,
      initialIconName: _selectedIconName,
    );
    
    if (selectedIcon != null) {
      setState(() {
        _selectedIconName = selectedIcon;
      });
    }
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = ref.read(categoryListViewModelProvider.notifier);
    final category = Category(
      id: _isEditing ? widget.category!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      color: ColorUtils.toHex(_selectedColor),
      icon: _selectedIconName,
      isDefault: _isDefault,
    );

    bool success;
    if (_isEditing) {
      success = await viewModel.updateCategory(category);
    } else {
      success = await viewModel.createCategory(category);
    }

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save category'),
          ),
        );
      }
    }
  }
}