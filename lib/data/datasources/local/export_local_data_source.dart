import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_files.dart';
import '../../../core/constants/export_format.dart';

class ExportLocalDataSource {
  final Database database;

  ExportLocalDataSource(this.database);

  Future<String> exportTable({
    required String tableName,
    required ExportFormat format,
  }) async {
    final rows = await database.query(tableName);
    final dir = await getApplicationDocumentsDirectory();
    final extension = _getExtension(format);
    final fileName =
        '${tableName}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final file = File(path.join(dir.path, fileName));

    if (format == ExportFormat.json) {
      await file.writeAsString(jsonEncode(rows));
      return file.path;
    }

    if (rows.isEmpty) {
      await file.writeAsString('');
      return file.path;
    }

    final headers = rows.first.keys.toList();
    final csvData = <List<dynamic>>[
      headers,
      ...rows.map((row) => headers.map((key) => row[key]).toList()),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    return file.path;
  }

  String _getExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return AppFiles.csvExtension;
      case ExportFormat.json:
        return AppFiles.jsonExtension;
    }
  }
}
