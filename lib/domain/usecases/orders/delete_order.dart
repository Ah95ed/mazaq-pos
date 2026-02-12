import '../../repositories/order_repository.dart';

class DeleteOrder {
  final OrderRepository repository;

  DeleteOrder(this.repository);

  Future<void> call(int id) {
    return repository.deleteOrder(id);
  }
}
