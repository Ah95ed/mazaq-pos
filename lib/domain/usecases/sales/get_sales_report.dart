import '../../entities/sales_report_entity.dart';
import '../../repositories/sales_repository.dart';

class GetSalesReport {
  final SalesRepository repository;

  GetSalesReport(this.repository);

  Future<SalesReportEntity> call({
    required DateTime start,
    required DateTime end,
  }) {
    return repository.getSalesReport(start: start, end: end);
  }
}
