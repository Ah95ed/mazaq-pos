import 'package:flutter/material.dart';

import '../../core/constants/app_db.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/usecases/menu/add_menu_category.dart';
import '../../domain/usecases/menu/add_menu_item.dart';
import '../../domain/usecases/menu/delete_menu_item.dart';
import '../../domain/usecases/menu/get_all_menu_categories.dart';
import '../../domain/usecases/menu/get_all_menu_items.dart';
import '../../domain/usecases/menu/update_menu_item.dart';

class MenuProvider extends ChangeNotifier {
  final GetAllMenuItems getAllItems;
  final GetAllMenuCategories getAllCategories;
  final AddMenuCategory addMenuCategory;
  final AddMenuItem addItem;
  final UpdateMenuItem updateItem;
  final DeleteMenuItem deleteItem;

  MenuProvider({
    required this.getAllItems,
    required this.getAllCategories,
    required this.addMenuCategory,
    required this.addItem,
    required this.updateItem,
    required this.deleteItem,
  });

  List<MenuItemEntity> _allItems = [];
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  List<String> _savedCategories = [];

  List<String> get filterCategories {
    final categories = <String>[];
    for (final category in _savedCategories) {
      final normalized = category.trim();
      if (normalized.isEmpty) {
        continue;
      }
      final exists = categories.any(
        (item) => item.toLowerCase() == normalized.toLowerCase(),
      );
      if (!exists) {
        categories.add(normalized);
      }
    }
    return categories;
  }

  List<String> get itemCategories => [
    ...filterCategories,
    AppDbValues.categoryBoth,
  ];

  List<MenuItemEntity> get items {
    if (_selectedCategory == null) {
      return _allItems;
    }
    return _allItems.where((item) {
      if (item.category == AppDbValues.categoryBoth) return true;
      return item.category == _selectedCategory;
    }).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addCategory(String categoryName) async {
    final normalized = categoryName.trim();
    if (normalized.isEmpty) {
      return;
    }
    if (normalized == AppDbValues.categoryBoth) {
      return;
    }

    final exists = filterCategories.any(
      (category) => category.toLowerCase() == normalized.toLowerCase(),
    );
    if (!exists) {
      await addMenuCategory(normalized);
      _savedCategories = await getAllCategories();
    }

    _selectedCategory = normalized;
    notifyListeners();
  }

  Future<void> loadItems() async {
    _setLoading(true);
    _allItems = await getAllItems();
    _savedCategories = await getAllCategories();
    if (_selectedCategory != null &&
        !filterCategories.any(
          (category) =>
              category.toLowerCase() == _selectedCategory!.toLowerCase(),
        )) {
      _selectedCategory = null;
    }
    _setLoading(false);
  }

  Future<void> createItem(MenuItemEntity item) async {
    await addItem(item);
    await loadItems();
  }

  Future<void> editItem(MenuItemEntity item) async {
    await updateItem(item);
    await loadItems();
  }

  Future<void> removeItem(int id) async {
    await deleteItem(id);
    await loadItems();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
