import '../../repositories/menu_repository.dart';

class DeleteMenuItem {
  final MenuRepository repository;

  DeleteMenuItem(this.repository);

  Future<void> call(int id) {
    return repository.deleteItem(id);
  }
}
