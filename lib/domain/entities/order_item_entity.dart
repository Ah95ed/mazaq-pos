class OrderItemEntity {
  final int id;
  final int orderId;
  final int itemId;
  final String itemName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });
}
