import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_data_source.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl(this.localDataSource);

  @override
  Future<int> createOrder(OrderEntity order) {
    return localDataSource.insertOrder(_toModel(order));
  }

  @override
  Future<void> addOrderItem(OrderItemEntity item) {
    return localDataSource.insertOrderItem(OrderItemModel.fromEntity(item));
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    final orders = await localDataSource.getOrders();
    return orders.map((order) => order.toEntity()).toList();
  }

  @override
  Future<void> updateOrderStatus(int id, OrderStatus status) {
    return localDataSource.updateStatus(id, OrderModel.orderStatusToDb(status));
  }

  OrderModel _toModel(OrderEntity order) {
    return OrderModel(
      id: order.id,
      orderType: order.orderType,
      status: order.status,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      subtotal: order.subtotal,
      tax: order.tax,
      discount: order.discount,
      total: order.total,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }
}
