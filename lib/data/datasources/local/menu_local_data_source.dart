import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_db.dart';
import '../../models/menu_item_model.dart';

class MenuLocalDataSource {
  final Database database;

  MenuLocalDataSource(this.database);

  Future<List<MenuItemModel>> getAllItems() async {
    final rows = await database.query(
      AppDbTables.items,
      orderBy: '${AppDbColumns.id} DESC',
    );
    return rows.map(MenuItemModel.fromMap).toList();
  }

  Future<void> insertItem(MenuItemModel item) async {
    await database.insert(
      AppDbTables.items,
      item.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(MenuItemModel item) async {
    await database.update(
      AppDbTables.items,
      item.toMap(),
      where: '${AppDbColumns.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(int id) async {
    await database.delete(
      AppDbTables.items,
      where: '${AppDbColumns.id} = ?',
      whereArgs: [id],
    );
  }
}
