import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/local/menu_local_data_source.dart';
import '../models/menu_item_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuLocalDataSource localDataSource;

  MenuRepositoryImpl(this.localDataSource);

  @override
  Future<List<MenuItemEntity>> getAllItems() async {
    final items = await localDataSource.getAllItems();
    return items.map((item) => item.toEntity()).toList();
  }

  @override
  Future<List<String>> getAllCategories() {
    return localDataSource.getAllCategories();
  }

  @override
  Future<void> addItem(MenuItemEntity item) {
    return localDataSource.insertItem(MenuItemModel.fromEntity(item));
  }

  @override
  Future<void> addCategory(String categoryName) {
    return localDataSource.insertCategory(categoryName);
  }

  @override
  Future<void> updateItem(MenuItemEntity item) {
    return localDataSource.updateItem(MenuItemModel.fromEntity(item));
  }

  @override
  Future<void> deleteItem(int id) {
    return localDataSource.deleteItem(id);
  }
}
