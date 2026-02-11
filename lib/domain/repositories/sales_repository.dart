import '../entities/sale_entity.dart';
import '../entities/sales_report_entity.dart';
import '../entities/sales_summary_entity.dart';

abstract class SalesRepository {
  Future<void> recordSale(SaleEntity sale);
  Future<List<SaleEntity>> getSales();
  Future<SalesSummaryEntity> getSalesSummary();
  Future<SalesReportEntity> getSalesReport({
    required DateTime start,
    required DateTime end,
  });
}
