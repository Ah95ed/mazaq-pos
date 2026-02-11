import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class UpdateOrderStatus {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call(int id, OrderStatus status) {
    return repository.updateOrderStatus(id, status);
  }
}
