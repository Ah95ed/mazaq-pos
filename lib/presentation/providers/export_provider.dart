import 'package:flutter/material.dart';

import '../../core/constants/app_db.dart';
import '../../core/constants/export_format.dart';
import '../../domain/usecases/export/export_table.dart';

class ExportProvider extends ChangeNotifier {
  final ExportTable exportTable;

  ExportProvider({required this.exportTable});

  String? _lastExportPath;
  String? get lastExportPath => _lastExportPath;

  Future<void> exportItems(ExportFormat format) async {
    _lastExportPath = await exportTable(
      tableName: AppDbTables.items,
      format: format,
    );
    notifyListeners();
  }

  Future<void> exportOrders(ExportFormat format) async {
    _lastExportPath = await exportTable(
      tableName: AppDbTables.orders,
      format: format,
    );
    notifyListeners();
  }

  Future<void> exportSales(ExportFormat format) async {
    _lastExportPath = await exportTable(
      tableName: AppDbTables.sales,
      format: format,
    );
    notifyListeners();
  }
}
