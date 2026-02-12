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

    // Header - Bold + Double size + Center
    commands.addAll([ESC, 0x61, 0x01]); // Center align
    commands.addAll([ESC, 0x21, 0x30]); // Double height + width
    commands.addAll([GS, 0x21, 0x11]); // Character size
    commands.addAll(utf8.encode('Mazaq POS'));
    commands.add(LF);

    // Reset to normal
    commands.addAll([ESC, 0x21, 0x00]);
    commands.addAll([GS, 0x21, 0x00]);
    commands.add(LF);

    // Separator line
    commands.addAll(_line());

    // Order info - Center align
    commands.addAll([ESC, 0x61, 0x01]); // Center
    commands.addAll([ESC, 0x21, 0x10]); // Bold
    commands.addAll(utf8.encode('Order #${order.id}'));
    commands.add(LF);
    commands.addAll([ESC, 0x21, 0x00]); // Normal

    commands.addAll(utf8.encode(dateFormat.format(order.createdAt)));
    commands.add(LF);

    final orderTypeText = order.orderType == OrderType.dineIn
        ? 'Dine-In'
        : 'Delivery';
    commands.addAll(utf8.encode(orderTypeText));
    commands.add(LF);
    commands.add(LF);

    // Separator
    commands.addAll(_line());

    // Items - Left align
    commands.addAll([ESC, 0x61, 0x00]); // Left align

    for (final item in order.items) {
      // Item name
      commands.addAll(utf8.encode(item.itemName));
      commands.add(LF);

      // Quantity and price on same line
      final qtyPrice =
          'x${item.quantity}     ${item.lineTotal.toStringAsFixed(2)}';
      commands.addAll(utf8.encode(qtyPrice));
      commands.add(LF);
    }

    commands.add(LF);
    commands.addAll(_line());

    // Totals
    commands.addAll(_printLine('Subtotal:', order.subtotal.toStringAsFixed(2)));
    commands.addAll(_printLine('Tax:', order.tax.toStringAsFixed(2)));
    commands.addAll(_printLine('Discount:', order.discount.toStringAsFixed(2)));

    commands.addAll(_line());

    // Total - Bold + Double size
    commands.addAll([ESC, 0x21, 0x30]); // Double size
    commands.addAll(_printLine('TOTAL:', order.total.toStringAsFixed(2)));
    commands.addAll([ESC, 0x21, 0x00]); // Normal

    commands.add(LF);
    commands.add(LF);

    // Thank you - Center
    commands.addAll([ESC, 0x61, 0x01]); // Center
    commands.addAll([ESC, 0x21, 0x10]); // Bold
    commands.addAll(utf8.encode('Thank You!'));
    commands.add(LF);

    // Feed and cut
    commands.addAll([ESC, 0x64, 0x03]); // Feed 3 lines
    commands.addAll([GS, 0x56, 0x00]); // Cut paper

    socket.add(commands);
  }

  List<int> _line() {
    return [...utf8.encode('================================'), LF];
  }

  List<int> _printLine(String label, String value) {
    final line = '$label${' ' * (20 - label.length)}$value';
    return [...utf8.encode(line), LF];
  }
}
