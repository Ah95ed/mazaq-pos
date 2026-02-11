import '../../domain/entities/sales_section_report_entity.dart';

class SalesSectionReportModel {
  final int ordersCount;
  final double total;
  final double averageTicket;
  final int? lastOrderId;
  final DateTime? lastOrderAt;

  const SalesSectionReportModel({
    required this.ordersCount,
    required this.total,
    required this.averageTicket,
    this.lastOrderId,
    this.lastOrderAt,
  });

  SalesSectionReportEntity toEntity() {
    return SalesSectionReportEntity(
      ordersCount: ordersCount,
      total: total,
      averageTicket: averageTicket,
      lastOrderId: lastOrderId,
      lastOrderAt: lastOrderAt,
    );
  }
}
