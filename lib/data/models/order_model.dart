import '../../core/constants/app_db.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel {
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

  const OrderModel({
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
  });

  factory OrderModel.fromMap(Map<String, Object?> map) {
    return OrderModel(
      id: map[AppDbColumns.id] as int,
      orderType: orderTypeFromDb(map[AppDbColumns.orderType] as String),
      status: orderStatusFromDb(map[AppDbColumns.status] as String),
      customerName: map[AppDbColumns.customerName] as String?,
      customerPhone: map[AppDbColumns.customerPhone] as String?,
      customerAddress: map[AppDbColumns.customerAddress] as String?,
      subtotal: (map[AppDbColumns.subtotal] as num).toDouble(),
      tax: (map[AppDbColumns.tax] as num).toDouble(),
      discount: (map[AppDbColumns.discount] as num).toDouble(),
      total: (map[AppDbColumns.total] as num).toDouble(),
      createdAt: DateTime.parse(map[AppDbColumns.createdAt] as String),
      updatedAt: DateTime.parse(map[AppDbColumns.updatedAt] as String),
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    final map = <String, Object?>{
      AppDbColumns.orderType: orderTypeToDb(orderType),
      AppDbColumns.status: orderStatusToDb(status),
      AppDbColumns.customerName: customerName,
      AppDbColumns.customerPhone: customerPhone,
      AppDbColumns.customerAddress: customerAddress,
      AppDbColumns.subtotal: subtotal,
      AppDbColumns.tax: tax,
      AppDbColumns.discount: discount,
      AppDbColumns.total: total,
      AppDbColumns.createdAt: createdAt.toIso8601String(),
      AppDbColumns.updatedAt: updatedAt.toIso8601String(),
    };
    if (includeId) {
      map[AppDbColumns.id] = id;
    }
    return map;
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderType: orderType,
      status: status,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String orderTypeToDb(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return AppDbValues.orderTypeDineIn;
      case OrderType.delivery:
        return AppDbValues.orderTypeDelivery;
    }
  }

  static OrderType orderTypeFromDb(String value) {
    switch (value) {
      case AppDbValues.orderTypeDelivery:
        return OrderType.delivery;
      default:
        return OrderType.dineIn;
    }
  }

  static String orderStatusToDb(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return AppDbValues.orderStatusNew;
      case OrderStatus.inProgress:
        return AppDbValues.orderStatusInProgress;
      case OrderStatus.done:
        return AppDbValues.orderStatusDone;
      case OrderStatus.canceled:
        return AppDbValues.orderStatusCanceled;
    }
  }

  static OrderStatus orderStatusFromDb(String value) {
    switch (value) {
      case AppDbValues.orderStatusInProgress:
        return OrderStatus.inProgress;
      case AppDbValues.orderStatusDone:
        return OrderStatus.done;
      case AppDbValues.orderStatusCanceled:
        return OrderStatus.canceled;
      default:
        return OrderStatus.newOrder;
    }
  }
}
