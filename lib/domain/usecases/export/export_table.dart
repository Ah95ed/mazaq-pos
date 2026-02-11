import '../../../core/constants/export_format.dart';
import '../../repositories/export_repository.dart';

class ExportTable {
  final ExportRepository repository;

  ExportTable(this.repository);

  Future<String> call({
    required String tableName,
    required ExportFormat format,
  }) {
    return repository.exportTable(tableName: tableName, format: format);
  }
}
