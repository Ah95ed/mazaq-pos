import '../entities/menu_item_entity.dart';

abstract class MenuRepository {
  Future<List<MenuItemEntity>> getAllItems();
  Future<List<String>> getAllCategories();
  Future<void> addItem(MenuItemEntity item);
  Future<void> addCategory(String categoryName);
  Future<void> updateItem(MenuItemEntity item);
  Future<void> deleteItem(int id);
}
