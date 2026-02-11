import '../../entities/sales_summary_entity.dart';
import '../../repositories/sales_repository.dart';

class GetSalesSummary {
  final SalesRepository repository;

  GetSalesSummary(this.repository);

  Future<SalesSummaryEntity> call() {
    return repository.getSalesSummary();
  }
}
