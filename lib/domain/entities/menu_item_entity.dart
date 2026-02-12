enum ItemCategory { dineIn, delivery, both }

class MenuItemEntity {
  final int id;
  final String nameAr;
  final String nameEn;
  final double price;
  final String? priceText;
  final String? imagePath;
  final bool isActive;
  final ItemCategory category;

  const MenuItemEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.priceText,
    this.imagePath,
    required this.isActive,
    this.category = ItemCategory.both,
  });
}
