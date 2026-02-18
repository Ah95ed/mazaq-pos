class AppDbTables {
  static const String items = 'items';
  static const String itemCategories = 'item_categories';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String sales = 'sales';
  static const String printerSettings = 'printer_settings';
  static const String printerConfigs = 'printer_configs';
}

class AppDbColumns {
  static const String id = 'id';
  static const String nameAr = 'name_ar';
  static const String nameEn = 'name_en';
  static const String price = 'price';
  static const String priceText = 'price_text';
  static const String imagePath = 'image_path';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String orderType = 'order_type';
  static const String status = 'status';
  static const String customerName = 'customer_name';
  static const String customerPhone = 'customer_phone';
  static const String customerAddress = 'customer_address';
  static const String subtotal = 'subtotal';
  static const String tax = 'tax';
  static const String discount = 'discount';
  static const String total = 'total';

  static const String orderId = 'order_id';
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';
  static const String unitPrice = 'unit_price';
  static const String quantity = 'quantity';
  static const String lineTotal = 'line_total';
  static const String category = 'category';

  static const String paidAt = 'paid_at';

  static const String printerType = 'printer_type';
  static const String printerIp = 'printer_ip';
  static const String printerPort = 'printer_port';
  static const String printerName = 'printer_name';
  static const String printerRole = 'printer_role';
  static const String usbModelKey = 'usb_model_key';
}

class AppDbValues {
  static const String orderTypeDineIn = 'DINE_IN';
  static const String orderTypeDelivery = 'DELIVERY';

  static const String orderStatusNew = 'NEW';
  static const String orderStatusInProgress = 'IN_PROGRESS';
  static const String orderStatusDone = 'DONE';
  static const String orderStatusCanceled = 'CANCELED';

  static const String categoryDineIn = 'DINE_IN';
  static const String categoryDelivery = 'DELIVERY';
  static const String categoryBoth = 'BOTH';
}
