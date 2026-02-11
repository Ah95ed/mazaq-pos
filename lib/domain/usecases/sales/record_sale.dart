import '../../entities/sale_entity.dart';
import '../../repositories/sales_repository.dart';

class RecordSale {
  final SalesRepository repository;

  RecordSale(this.repository);

  Future<void> call(SaleEntity sale) {
    return repository.recordSale(sale);
  }
}
