import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../domain/entities/order_entity.dart';
import 'printer_config.dart';

/// خدمة طباعة عبر Socket مباشر لدعم الطابعات الحرارية
/// تستخدم أوامر ESC/POS الأساسية بدون مكتبات خارجية
class EscPosPrinterService {
  // ESC/POS commands
  static const ESC = 0x1B;
  static const GS = 0x1D;
  static const LF = 0x0A;

  Future<void> printOrder({
    required PrinterConfig printer,
    required OrderEntity order,
  }) async {
    if (printer.ip == null || printer.port == null) {
      throw ArgumentError('Network printer requires IP and port.');
    }

    Socket? socket;
    try {
      socket = await Socket.connect(
        printer.ip!,
        printer.port!,
        timeout: const Duration(seconds: 5),
      );

      await _buildReceipt(socket, order);
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      socket?.destroy();
    }
  }

  Future<void> _buildReceipt(Socket socket, OrderEntity order) async {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final commands = <int>[];

    // Initialize printer
    commands.addAll([ESC, 0x40]); // ESC @ - Initialize

    // Header - Bold + Double size + Center (Arabic)
    commands.addAll([ESC, 0x61, 0x01]); // Center align
    commands.addAll([ESC, 0x21, 0x30]); // Double height + width
    commands.addAll([GS, 0x21, 0x11]); // Character size
    // Arabic title using PC1001 encoding
    commands.addAll(_encodeArabic('مذاق POS'));
    commands.add(LF);

    // Reset to normal
    commands.addAll([ESC, 0x21, 0x00]);
    commands.addAll([GS, 0x21, 0x00]);
    commands.add(LF);

    // Separator line
    commands.addAll(_line());

    // Order info - Center align (Arabic)
    commands.addAll([ESC, 0x61, 0x01]); // Center
    commands.addAll([ESC, 0x21, 0x10]); // Bold
    commands.addAll(_encodeArabic('طلب رقم ${order.id}'));
    commands.add(LF);
    commands.addAll([ESC, 0x21, 0x00]); // Normal

    commands.addAll(_encodeArabic(dateFormat.format(order.createdAt)));
    commands.add(LF);

    final orderTypeText = order.orderType == OrderType.dineIn
        ? 'صالة'
        : 'دليفري';
    commands.addAll(_encodeArabic(orderTypeText));
    commands.add(LF);
    commands.add(LF);

    // Separator
    commands.addAll(_line());

    // Items - Left align (Arabic)
    commands.addAll([ESC, 0x61, 0x00]); // Left align

    for (final item in order.items) {
      // Item name (Arabic)
      commands.addAll(_encodeArabic(item.itemName));
      commands.add(LF);

      // Quantity and price on same line
      final qtyPrice =
          'x${item.quantity}     ${item.lineTotal.toStringAsFixed(2)}';
      commands.addAll(_encodeArabic(qtyPrice));
      commands.add(LF);
    }

    commands.add(LF);
    commands.addAll(_line());

    // Totals (Arabic)
    commands.addAll(
      _printLineAr('الإجمالي الفرعي:', order.subtotal.toStringAsFixed(2)),
    );
    commands.addAll(_printLineAr('الضريبة:', order.tax.toStringAsFixed(2)));
    commands.addAll(_printLineAr('الخصم:', order.discount.toStringAsFixed(2)));

    commands.addAll(_line());

    // Total - Bold + Small size - Center
    commands.addAll([ESC, 0x61, 0x01]); // Center align
    commands.addAll([ESC, 0x21, 0x01]); // Small font
    commands.addAll(
      _printLineAr('الإجمالي:', order.total.toStringAsFixed(2), center: true),
    );
    commands.addAll([ESC, 0x21, 0x00]); // Normal

    commands.add(LF);
    commands.add(LF);

    // Thank you - Center (Arabic)
    commands.addAll([ESC, 0x61, 0x01]); // Center
    commands.addAll([ESC, 0x21, 0x10]); // Bold
    commands.addAll(_encodeArabic('شكراً لاختياركم'));
    commands.add(LF);

    // Feed and cut
    commands.addAll([ESC, 0x64, 0x03]); // Feed 3 lines
    commands.addAll([GS, 0x56, 0x00]); // Cut paper

    socket.add(commands);
  }

  List<int> _line() {
    return [..._encodeArabic('================================'), LF];
  }

  // Arabic line print helper
  List<int> _printLineAr(String label, String value, {bool center = false}) {
    // Shorter line, smaller font, center if needed
    String line = center
        ? '$label $value'
        : '$label${' ' * (20 - label.length)}$value';
    return [..._encodeArabic(line), LF];
  }

  // Encode Arabic string to PC1001 (code page 864)
  List<int> _encodeArabic(String text) {
    // Set code page to PC1001 (Arabic)
    // ESC t n, n=22 for PC1001
    return [ESC, 0x74, 22] + latin1.encode(text);
  }
}
