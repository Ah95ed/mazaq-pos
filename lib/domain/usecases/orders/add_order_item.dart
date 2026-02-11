import '../../entities/order_item_entity.dart';
import '../../repositories/order_repository.dart';

class AddOrderItem {
  final OrderRepository repository;

  AddOrderItem(this.repository);

  Future<void> call(OrderItemEntity item) {
    return repository.addOrderItem(item);
  }
}
