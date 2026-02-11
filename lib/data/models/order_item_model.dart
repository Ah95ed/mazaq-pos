import '../../core/constants/app_db.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int itemId;
  final String itemName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromMap(Map<String, Object?> map) {
    return OrderItemModel(
      id: map[AppDbColumns.id] as int,
      orderId: map[AppDbColumns.orderId] as int,
      itemId: map[AppDbColumns.itemId] as int,
      itemName: map[AppDbColumns.itemName] as String,
      unitPrice: (map[AppDbColumns.unitPrice] as num).toDouble(),
      quantity: map[AppDbColumns.quantity] as int,
      lineTotal: (map[AppDbColumns.lineTotal] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    final map = <String, Object?>{
      AppDbColumns.orderId: orderId,
      AppDbColumns.itemId: itemId,
      AppDbColumns.itemName: itemName,
      AppDbColumns.unitPrice: unitPrice,
      AppDbColumns.quantity: quantity,
      AppDbColumns.lineTotal: lineTotal,
    };
    if (includeId) {
      map[AppDbColumns.id] = id;
    }
    return map;
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      orderId: orderId,
      itemId: itemId,
      itemName: itemName,
      unitPrice: unitPrice,
      quantity: quantity,
      lineTotal: lineTotal,
    );
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      itemId: entity.itemId,
      itemName: entity.itemName,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
      lineTotal: entity.lineTotal,
    );
  }
}
