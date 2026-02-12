import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_db.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/usecases/orders/add_order_item.dart';
import '../../domain/usecases/orders/create_order.dart';
import '../../domain/usecases/orders/delete_order.dart';
import '../../domain/usecases/orders/get_orders.dart';
import '../../domain/usecases/orders/update_order_status.dart';

class OrderProvider extends ChangeNotifier {
  final CreateOrder createOrder;
  final AddOrderItem addOrderItem;
  final GetOrders getOrders;
  final UpdateOrderStatus updateOrderStatus;
  final DeleteOrder deleteOrder;

  OrderProvider({
    required this.createOrder,
    required this.addOrderItem,
    required this.getOrders,
    required this.updateOrderStatus,
    required this.deleteOrder,
  });

  OrderType _orderType = OrderType.dineIn;
  OrderType get orderType => _orderType;

  final List<OrderItemEntity> _draftItems = [];
  List<OrderItemEntity> get draftItems => List.unmodifiable(_draftItems);

  double _manualTax = 0;
  double _manualDiscount = 0;
  double? _manualTotal;

  double get manualTax => _manualTax;
  double get manualDiscount => _manualDiscount;
  double? get manualTotal => _manualTotal;

  List<OrderEntity> _orders = [];
  List<OrderEntity> get orders => _orders;

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void addToDraft(OrderItemEntity item) {
    _draftItems.add(item);
    notifyListeners();
  }

  void clearDraft() {
    _draftItems.clear();
    _manualTax = 0;
    _manualDiscount = 0;
    _manualTotal = null;
    notifyListeners();
  }

  double get draftSubtotal {
    return _draftItems.fold(0, (sum, item) => sum + item.lineTotal);
  }

  double get draftTotal {
    if (_manualTotal != null) {
      return _manualTotal!;
    }
    return draftSubtotal + _manualTax - _manualDiscount;
  }

  void updateItemQuantity(int index, int quantity) {
    if (index < 0 || index >= _draftItems.length) {
      return;
    }
    if (quantity < 1) {
      return;
    }
    final item = _draftItems[index];
    _draftItems[index] = OrderItemEntity(
      id: item.id,
      orderId: item.orderId,
      itemId: item.itemId,
      itemName: item.itemName,
      unitPrice: item.unitPrice,
      quantity: quantity,
      lineTotal: item.unitPrice * quantity,
    );
    notifyListeners();
  }

  void updateItemPrice(int index, double unitPrice) {
    if (index < 0 || index >= _draftItems.length) {
      return;
    }
    final item = _draftItems[index];
    _draftItems[index] = OrderItemEntity(
      id: item.id,
      orderId: item.orderId,
      itemId: item.itemId,
      itemName: item.itemName,
      unitPrice: unitPrice,
      quantity: item.quantity,
      lineTotal: unitPrice * item.quantity,
    );
    notifyListeners();
  }

  void setManualTotals({
    required double tax,
    required double discount,
    double? total,
  }) {
    _manualTax = tax;
    _manualDiscount = discount;
    _manualTotal = total;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _orders = await getOrders();
    notifyListeners();
  }

  Future<void> submitDraft({
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) async {
    final now = DateTime.now();
    final subtotal = draftSubtotal;
    final tax = _manualTax != 0 ? _manualTax : subtotal * AppConfig.taxRate;
    final discount = _manualDiscount != 0
        ? _manualDiscount
        : AppConfig.defaultDiscount;
    final computedTotal = subtotal + tax - discount;
    final total = _manualTotal ?? computedTotal;
    final order = OrderEntity(
      id: 0,
      orderType: _orderType,
      status: OrderStatus.newOrder,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      subtotal: subtotal,
      tax: tax,
      discount: _manualTotal == null ? discount : subtotal + tax - total,
      total: total,
      createdAt: now,
      updatedAt: now,
    );

    final orderId = await createOrder(order);
    for (final item in _draftItems) {
      await addOrderItem(
        OrderItemEntity(
          id: 0,
          orderId: orderId,
          itemId: item.itemId,
          itemName: item.itemName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          lineTotal: item.lineTotal,
        ),
      );
    }

    clearDraft();
    await loadOrders();
  }

  Future<void> setStatus(int orderId, OrderStatus status) async {
    await updateOrderStatus(orderId, status);
    await loadOrders();
  }

  Future<void> removeOrder(int orderId) async {
    await deleteOrder(orderId);
    await loadOrders();
  }

  String orderTypeToDb(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return AppDbValues.orderTypeDineIn;
      case OrderType.delivery:
        return AppDbValues.orderTypeDelivery;
    }
  }
}
