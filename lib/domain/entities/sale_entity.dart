class SaleEntity {
  final int id;
  final int orderId;
  final String orderType;
  final double total;
  final DateTime paidAt;

  const SaleEntity({
    required this.id,
    required this.orderId,
    required this.orderType,
    required this.total,
    required this.paidAt,
  });
}
