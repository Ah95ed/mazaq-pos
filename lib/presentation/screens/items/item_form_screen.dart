import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_db.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../../domain/entities/menu_item_entity.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/language_switcher.dart';

class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  MenuItemEntity? _editingItem;
  String _selectedCategory = AppDbValues.categoryBoth;
  bool _didLoadCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadCategories) {
      _didLoadCategories = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.read<MenuProvider>().loadItems();
      });
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MenuItemEntity && _editingItem == null) {
      _editingItem = args;
      _nameController.text = args.nameAr.isNotEmpty ? args.nameAr : args.nameEn;
      _priceController.text = args.priceText ?? args.price.toString();
      _selectedCategory = args.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingItem != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
            isEditing ? AppKeys.editItemTitle : AppKeys.createItemTitle,
          ),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: context.tr(AppKeys.itemName),
                validator: _requiredValidator(context),
              ),
              SizedBox(height: AppDimensions.md),
              AppTextField(
                controller: _priceController,
                label: context.tr(AppKeys.price),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _priceValidator(context),
              ),
              SizedBox(height: AppDimensions.md),
              Consumer<MenuProvider>(
                builder: (context, menuProvider, _) {
                  final categories = [...menuProvider.filterCategories];
                  if (!categories.contains(_selectedCategory)) {
                    if (_editingItem != null && _selectedCategory.isNotEmpty) {
                      categories.add(_selectedCategory);
                    } else if (categories.isNotEmpty) {
                      _selectedCategory = categories.first;
                    } else {
                      _selectedCategory = AppDbValues.categoryBoth;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: categories.contains(_selectedCategory)
                        ? _selectedCategory
                        : null,
                    decoration: InputDecoration(
                      labelText: context.tr(AppKeys.itemCategory),
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: AppColors.brand,
                      ),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(_categoryLabel(context, category)),
                          ),
                        )
                        .toList(),
                    onChanged: categories.isEmpty
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                  );
                },
              ),
              SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.tr(AppKeys.cancel)),
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onSave,
                      child: Text(context.tr(AppKeys.save)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.tr(AppKeys.requiredField);
      }
      return null;
    };
  }

  String? Function(String?) _priceValidator(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.tr(AppKeys.requiredField);
      }
      final parsed = double.tryParse(value.trim());
      if (parsed == null) {
        return context.tr(AppKeys.requiredField);
      }
      return null;
    };
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final provider = context.read<MenuProvider>();
    final priceText = _priceController.text.trim();
    final price = double.parse(priceText);
    final name = _nameController.text.trim();
    final item = MenuItemEntity(
      id: _editingItem?.id ?? 0,
      nameAr: name,
      nameEn: name,
      price: price,
      priceText: priceText,
      imagePath: _editingItem?.imagePath,
      isActive: _editingItem?.isActive ?? true,
      category: _selectedCategory,
    );

    if (_editingItem == null) {
      provider.createItem(item);
    } else {
      provider.editItem(item);
    }

    Navigator.pop(context);
  }

  String _categoryLabel(BuildContext context, String category) {
    if (category == AppDbValues.categoryDineIn) {
      return context.tr(AppKeys.dineIn);
    }
    if (category == AppDbValues.categoryDelivery) {
      return context.tr(AppKeys.delivery);
    }
    return category;
  }
}
