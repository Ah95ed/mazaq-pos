import '../../core/constants/app_db.dart';
import '../../domain/entities/menu_item_entity.dart';

class MenuItemModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final double price;
  final String? priceText;
  final String? imagePath;
  final bool isActive;
  final String category;

  const MenuItemModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.priceText,
    this.imagePath,
    required this.isActive,
    this.category = AppDbValues.categoryBoth,
  });

  factory MenuItemModel.fromMap(Map<String, Object?> map) {
    return MenuItemModel(
      id: map[AppDbColumns.id] as int,
      nameAr: map[AppDbColumns.nameAr] as String,
      nameEn: map[AppDbColumns.nameEn] as String,
      price: (map[AppDbColumns.price] as num).toDouble(),
      priceText: map[AppDbColumns.priceText] as String?,
      imagePath: map[AppDbColumns.imagePath] as String?,
      isActive: (map[AppDbColumns.isActive] as int) == 1,
      category:
          (map[AppDbColumns.category] as String?) ?? AppDbValues.categoryBoth,
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    final map = <String, Object?>{
      AppDbColumns.nameAr: nameAr,
      AppDbColumns.nameEn: nameEn,
      AppDbColumns.price: price,
      AppDbColumns.priceText: priceText,
      AppDbColumns.imagePath: imagePath,
      AppDbColumns.isActive: isActive ? 1 : 0,
      AppDbColumns.category: category,
      AppDbColumns.createdAt: DateTime.now().toIso8601String(),
      AppDbColumns.updatedAt: DateTime.now().toIso8601String(),
    };
    if (includeId) {
      map[AppDbColumns.id] = id;
    }
    return map;
  }

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      price: price,
      priceText: priceText,
      imagePath: imagePath,
      isActive: isActive,
      category: category,
    );
  }

  factory MenuItemModel.fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      price: entity.price,
      priceText: entity.priceText,
      imagePath: entity.imagePath,
      isActive: entity.isActive,
      category: entity.category,
    );
  }
}
