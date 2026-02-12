import 'package:printing/printing.dart';

import '../../domain/entities/order_entity.dart';
import 'esc_pos_printer_service.dart';
import 'print_job_builder.dart';
import 'printer_config.dart';
import 'printer_service.dart';

class TcpPrinterService implements PrinterService {
  @override
  Future<void> printOrder({
    required PrinterConfig printer,
    required OrderEntity order,
  }) async {
    if (printer.ip == null || printer.port == null) {
      throw ArgumentError('TCP printer requires IP and port.');
    }

    // Try ESC/POS first (for thermal printers)
    try {
      final escPosService = EscPosPrinterService();
      await escPosService.printOrder(printer: printer, order: order);
      return;
    } catch (e) {
      // If ESC/POS fails, fallback to PDF printing
      print('ESC/POS printing failed, falling back to PDF: $e');
    }

    // Fallback: PDF printing
    final builder = PrintJobBuilder();
    final doc = builder.buildOrderDocument(
      order: order,
      orderIdLabel: 'Order',
      totalLabel: 'Total',
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'order_${order.id}.pdf',
    );
  }
}
