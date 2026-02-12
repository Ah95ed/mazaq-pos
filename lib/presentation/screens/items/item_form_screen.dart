import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  ItemCategory _selectedCategory = ItemCategory.both;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
              Text(
                context.tr(AppKeys.itemCategory),
                style: TextStyle(
                  fontSize: AppDimensions.textMd,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = ItemCategory.dineIn;
                        });
                      },
                      icon: Icon(
                        _selectedCategory == ItemCategory.dineIn
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(context.tr(AppKeys.dineIn)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            _selectedCategory == ItemCategory.dineIn
                            ? AppColors.brandSoft
                            : null,
                        foregroundColor:
                            _selectedCategory == ItemCategory.dineIn
                            ? AppColors.brand
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = ItemCategory.delivery;
                        });
                      },
                      icon: Icon(
                        _selectedCategory == ItemCategory.delivery
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(context.tr(AppKeys.delivery)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            _selectedCategory == ItemCategory.delivery
                            ? AppColors.brandSoft
                            : null,
                        foregroundColor:
                            _selectedCategory == ItemCategory.delivery
                            ? AppColors.brand
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = ItemCategory.both;
                        });
                      },
                      icon: Icon(
                        _selectedCategory == ItemCategory.both
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(context.tr(AppKeys.both)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedCategory == ItemCategory.both
                            ? AppColors.brandSoft
                            : null,
                        foregroundColor: _selectedCategory == ItemCategory.both
                            ? AppColors.brand
                            : null,
                      ),
                    ),
                  ),
                ],
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
}
