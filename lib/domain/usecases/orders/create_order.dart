import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<int> call(OrderEntity order) {
    return repository.createOrder(order);
  }
}
