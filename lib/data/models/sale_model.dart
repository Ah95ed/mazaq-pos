import '../../core/constants/app_db.dart';
import '../../domain/entities/sale_entity.dart';

class SaleModel {
  final int id;
  final int orderId;
  final String orderType;
  final double total;
  final DateTime paidAt;

  const SaleModel({
    required this.id,
    required this.orderId,
    required this.orderType,
    required this.total,
    required this.paidAt,
  });

  factory SaleModel.fromMap(Map<String, Object?> map) {
    return SaleModel(
      id: map[AppDbColumns.id] as int,
      orderId: map[AppDbColumns.orderId] as int,
      orderType: map[AppDbColumns.orderType] as String,
      total: (map[AppDbColumns.total] as num).toDouble(),
      paidAt: DateTime.parse(map[AppDbColumns.paidAt] as String),
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    final map = <String, Object?>{
      AppDbColumns.orderId: orderId,
      AppDbColumns.orderType: orderType,
      AppDbColumns.total: total,
      AppDbColumns.paidAt: paidAt.toIso8601String(),
    };
    if (includeId) {
      map[AppDbColumns.id] = id;
    }
    return map;
  }

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      orderId: orderId,
      orderType: orderType,
      total: total,
      paidAt: paidAt,
    );
  }

  factory SaleModel.fromEntity(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      orderId: entity.orderId,
      orderType: entity.orderType,
      total: entity.total,
      paidAt: entity.paidAt,
    );
  }
}
