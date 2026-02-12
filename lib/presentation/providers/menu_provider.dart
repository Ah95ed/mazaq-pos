import 'package:flutter/material.dart';

import '../../domain/entities/menu_item_entity.dart';
import '../../domain/usecases/menu/add_menu_item.dart';
import '../../domain/usecases/menu/delete_menu_item.dart';
import '../../domain/usecases/menu/get_all_menu_items.dart';
import '../../domain/usecases/menu/update_menu_item.dart';

class MenuProvider extends ChangeNotifier {
  final GetAllMenuItems getAllItems;
  final AddMenuItem addItem;
  final UpdateMenuItem updateItem;
  final DeleteMenuItem deleteItem;

  MenuProvider({
    required this.getAllItems,
    required this.addItem,
    required this.updateItem,
    required this.deleteItem,
  });

  List<MenuItemEntity> _allItems = [];
  ItemCategory? _selectedCategory;
  ItemCategory? get selectedCategory => _selectedCategory;

  List<MenuItemEntity> get items {
    if (_selectedCategory == null) {
      return _allItems;
    }
    return _allItems.where((item) {
      if (item.category == ItemCategory.both) return true;
      return item.category == _selectedCategory;
    }).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setCategory(ItemCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadItems() async {
    _setLoading(true);
    _allItems = await getAllItems();
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
