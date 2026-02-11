import 'order_item_entity.dart';

enum OrderType { dineIn, delivery }

enum OrderStatus { newOrder, inProgress, done, canceled }

class OrderEntity {
  final int id;
  final OrderType orderType;
  final OrderStatus status;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.orderType,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });
}
