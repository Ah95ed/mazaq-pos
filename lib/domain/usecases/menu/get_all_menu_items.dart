import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class GetAllMenuItems {
  final MenuRepository repository;

  GetAllMenuItems(this.repository);

  Future<List<MenuItemEntity>> call() {
    return repository.getAllItems();
  }
}
