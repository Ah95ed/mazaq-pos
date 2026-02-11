import '../../core/constants/export_format.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/local/export_local_data_source.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportLocalDataSource localDataSource;

  ExportRepositoryImpl(this.localDataSource);

  @override
  Future<String> exportTable({
    required String tableName,
    required ExportFormat format,
  }) {
    return localDataSource.exportTable(tableName: tableName, format: format);
  }
}
