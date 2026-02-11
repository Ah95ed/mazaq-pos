import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';

abstract class OrderRepository {
  Future<int> createOrder(OrderEntity order);
  Future<void> addOrderItem(OrderItemEntity item);
  Future<List<OrderEntity>> getOrders();
  Future<void> updateOrderStatus(int id, OrderStatus status);
}
