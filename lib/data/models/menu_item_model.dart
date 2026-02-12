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
  final ItemCategory category;

  const MenuItemModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.priceText,
    this.imagePath,
    required this.isActive,
    this.category = ItemCategory.both,
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
      category: _categoryFromDb(map[AppDbColumns.category] as String?),
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
      AppDbColumns.category: _categoryToDb(category),
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

  static String _categoryToDb(ItemCategory category) {
    switch (category) {
      case ItemCategory.dineIn:
        return AppDbValues.categoryDineIn;
      case ItemCategory.delivery:
        return AppDbValues.categoryDelivery;
      case ItemCategory.both:
        return AppDbValues.categoryBoth;
    }
  }

  static ItemCategory _categoryFromDb(String? value) {
    switch (value) {
      case AppDbValues.categoryDineIn:
        return ItemCategory.dineIn;
      case AppDbValues.categoryDelivery:
        return ItemCategory.delivery;
      default:
        return ItemCategory.both;
    }
  }
}
