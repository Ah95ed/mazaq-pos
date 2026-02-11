import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/entities/sales_summary_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/local/sales_local_data_source.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource localDataSource;

  SalesRepositoryImpl(this.localDataSource);

  @override
  Future<void> recordSale(SaleEntity sale) {
    return localDataSource.insertSale(SaleModel.fromEntity(sale));
  }

  @override
  Future<List<SaleEntity>> getSales() async {
    final sales = await localDataSource.getSales();
    return sales.map((sale) => sale.toEntity()).toList();
  }

  @override
  Future<SalesSummaryEntity> getSalesSummary() async {
    final summary = await localDataSource.getSalesSummary();
    return SalesSummaryEntity(
      dineInTotal: summary['dineIn'] ?? 0,
      deliveryTotal: summary['delivery'] ?? 0,
      overallTotal: summary['overall'] ?? 0,
    );
  }

  @override
  Future<SalesReportEntity> getSalesReport({
    required DateTime start,
    required DateTime end,
  }) async {
    final report = await localDataSource.getSalesReport(start: start, end: end);
    return report.toEntity();
  }
}
