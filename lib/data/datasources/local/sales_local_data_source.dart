import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_db.dart';
import '../../models/sales_report_model.dart';
import '../../models/sales_section_report_model.dart';
import '../../models/sale_model.dart';

class SalesLocalDataSource {
  final Database database;

  SalesLocalDataSource(this.database);

  Future<void> insertSale(SaleModel sale) async {
    await database.insert(
      AppDbTables.sales,
      sale.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SaleModel>> getSales() async {
    final rows = await database.query(
      AppDbTables.sales,
      orderBy: '${AppDbColumns.paidAt} DESC',
    );
    return rows.map(SaleModel.fromMap).toList();
  }

  Future<Map<String, double>> getSalesSummary() async {
    final result = await database.rawQuery('''
      SELECT ${AppDbColumns.orderType} as type, SUM(${AppDbColumns.total}) as sum
      FROM ${AppDbTables.sales}
      GROUP BY ${AppDbColumns.orderType}
      ''');

    double dineIn = 0;
    double delivery = 0;
    double overall = 0;

    for (final row in result) {
      final type = row['type'] as String? ?? '';
      final value = (row['sum'] as num?)?.toDouble() ?? 0;
      overall += value;
      if (type == AppDbValues.orderTypeDineIn) {
        dineIn += value;
      } else if (type == AppDbValues.orderTypeDelivery) {
        delivery += value;
      }
    }

    return {'dineIn': dineIn, 'delivery': delivery, 'overall': overall};
  }

  Future<SalesReportModel> getSalesReport({
    required DateTime start,
    required DateTime end,
  }) async {
    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();

    final totals = await database.rawQuery(
      '''
      SELECT ${AppDbColumns.orderType} as type,
             COUNT(*) as count,
             SUM(${AppDbColumns.total}) as sum
      FROM ${AppDbTables.sales}
      WHERE ${AppDbColumns.paidAt} BETWEEN ? AND ?
      GROUP BY ${AppDbColumns.orderType}
      ''',
      [startIso, endIso],
    );

    SalesSectionReportModel dineIn = const SalesSectionReportModel(
      ordersCount: 0,
      total: 0,
      averageTicket: 0,
    );
    SalesSectionReportModel delivery = const SalesSectionReportModel(
      ordersCount: 0,
      total: 0,
      averageTicket: 0,
    );

    for (final row in totals) {
      final type = row['type'] as String? ?? '';
      final count = (row['count'] as num?)?.toInt() ?? 0;
      final total = (row['sum'] as num?)?.toDouble() ?? 0;
      final avg = count == 0 ? 0.0 : total / count;

      final lastOrder = await _getLastOrder(
        type: type,
        startIso: startIso,
        endIso: endIso,
      );

      final lastOrderId = lastOrder['id'];
      final lastOrderAt = lastOrder['createdAt'];

      final model = SalesSectionReportModel(
        ordersCount: count,
        total: total,
        averageTicket: avg,
        lastOrderId: lastOrderId is int ? lastOrderId : null,
        lastOrderAt: lastOrderAt is DateTime ? lastOrderAt : null,
      );

      if (type == AppDbValues.orderTypeDineIn) {
        dineIn = model;
      } else if (type == AppDbValues.orderTypeDelivery) {
        delivery = model;
      }
    }

    return SalesReportModel(dineIn: dineIn, delivery: delivery);
  }

  Future<Map<String, Object?>> _getLastOrder({
    required String type,
    required String startIso,
    required String endIso,
  }) async {
    if (type.isEmpty) {
      return {};
    }
    final rows = await database.query(
      AppDbTables.orders,
      columns: [AppDbColumns.id, AppDbColumns.createdAt],
      where:
          '${AppDbColumns.orderType} = ? AND ${AppDbColumns.createdAt} BETWEEN ? AND ?',
      whereArgs: [type, startIso, endIso],
      orderBy: '${AppDbColumns.createdAt} DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return {};
    }
    return {
      'id': rows.first[AppDbColumns.id] as int?,
      'createdAt': DateTime.tryParse(
        rows.first[AppDbColumns.createdAt] as String? ?? '',
      ),
    };
  }
}
