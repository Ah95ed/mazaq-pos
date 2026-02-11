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

  List<MenuItemEntity> _items = [];
  List<MenuItemEntity> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _setLoading(true);
    _items = await getAllItems();
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
