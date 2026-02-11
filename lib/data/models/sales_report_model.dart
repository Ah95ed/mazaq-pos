import '../../domain/entities/sales_report_entity.dart';
import 'sales_section_report_model.dart';

class SalesReportModel {
  final SalesSectionReportModel dineIn;
  final SalesSectionReportModel delivery;

  const SalesReportModel({required this.dineIn, required this.delivery});

  SalesReportEntity toEntity() {
    return SalesReportEntity(
      dineIn: dineIn.toEntity(),
      delivery: delivery.toEntity(),
    );
  }
}
