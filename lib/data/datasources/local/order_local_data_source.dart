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

  Future<void> deleteOrder(int id) async {
    await database.transaction((txn) async {
      await txn.delete(
        AppDbTables.orderItems,
        where: '${AppDbColumns.orderId} = ?',
        whereArgs: [id],
      );
      await txn.delete(
        AppDbTables.sales,
        where: '${AppDbColumns.orderId} = ?',
        whereArgs: [id],
      );
      await txn.delete(
        AppDbTables.orders,
        where: '${AppDbColumns.id} = ?',
        whereArgs: [id],
      );
    });
  }
}
