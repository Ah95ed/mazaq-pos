import '../../repositories/menu_repository.dart';

class AddMenuCategory {
  final MenuRepository repository;

  AddMenuCategory(this.repository);

  Future<void> call(String categoryName) {
    return repository.addCategory(categoryName);
  }
}
