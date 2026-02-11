import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class UpdateMenuItem {
  final MenuRepository repository;

  UpdateMenuItem(this.repository);

  Future<void> call(MenuItemEntity item) {
    return repository.updateItem(item);
  }
}
