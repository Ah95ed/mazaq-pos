import '../../core/constants/export_format.dart';

abstract class ExportRepository {
  Future<String> exportTable({
    required String tableName,
    required ExportFormat format,
  });
}
