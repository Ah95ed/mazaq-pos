import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_db.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';

class OrderLocalDataSource {
  final Database database;

  OrderLocalDataSource(this.database);

  Future<int> insertOrder(OrderModel order) async {
    return database.insert(
      AppDbTables.orders,
      order.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertOrderItem(OrderItemModel item) async {
    await database.insert(
      AppDbTables.orderItems,
      item.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OrderModel>> getOrders() async {
    final rows = await database.query(
      AppDbTables.orders,
      orderBy: '${AppDbColumns.createdAt} DESC',
    );
    return rows.map(OrderModel.fromMap).toList();
  }

  Future<void> updateStatus(int id, String status) async {
    await database.update(
      AppDbTables.orders,
      {
        AppDbColumns.status: status,
        AppDbColumns.updatedAt: DateTime.now().toIso8601String(),
      },
      where: '${AppDbColumns.id} = ?',
      whereArgs: [id],
    );
  }
}
