import '../../repositories/menu_repository.dart';

class GetAllMenuCategories {
  final MenuRepository repository;

  GetAllMenuCategories(this.repository);

  Future<List<String>> call() {
    return repository.getAllCategories();
  }
}
