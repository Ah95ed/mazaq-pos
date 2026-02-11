import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class AddMenuItem {
  final MenuRepository repository;

  AddMenuItem(this.repository);

  Future<void> call(MenuItemEntity item) {
    return repository.addItem(item);
  }
}
