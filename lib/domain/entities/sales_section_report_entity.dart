class SalesSectionReportEntity {
  final int ordersCount;
  final double total;
  final double averageTicket;
  final int? lastOrderId;
  final DateTime? lastOrderAt;

  const SalesSectionReportEntity({
    required this.ordersCount,
    required this.total,
    required this.averageTicket,
    this.lastOrderId,
    this.lastOrderAt,
  });
}
