import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'file_picker_helper.dart';

import '../../domain/entities/order_entity.dart';
import 'esc_pos_printer_service.dart';
import 'print_job_builder.dart';
import 'printer_config.dart';
import 'printer_service.dart';

class TcpPrinterService implements PrinterService {
  /// ينشئ ملف PDF، يحفظه، ثم يرسله للطابعة ويعيد المسار
  @override
  /// ينشئ ملف PDF، يحفظه في مكان يختاره المستخدم أو تلقائياً، ثم يرسله للطابعة ويعيد المسار
  Future<String?> printOrder({
    required PrinterConfig printer,
    required OrderEntity order,
    bool pickSaveLocation = false,
  }) async {
    if (printer.ip == null || printer.port == null) {
      throw ArgumentError('TCP printer requires IP and port.');
    }

    String? pdfPath;
    try {
      // Try ESC/POS first (for thermal printers)
      final escPosService = EscPosPrinterService();
      await escPosService.printOrder(printer: printer, order: order);

      final builder = PrintJobBuilder();
      final doc = await builder.buildOrderDocument(
        order: order,
        orderIdLabel: 'Order',
        totalLabel: 'Total',
      );

      // اختيار مكان الحفظ إذا طلب المستخدم
      String fileName =
          'order_${order.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      if (pickSaveLocation) {
        pdfPath = await pickSavePath(fileName);
        if (pdfPath == null) {
          print('لم يتم اختيار مكان الحفظ');
          return null;
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        pdfPath = '${dir.path}/$fileName';
      }
      final file = File(pdfPath);
      await file.writeAsBytes(await doc.save());
      print('PDF saved to: $pdfPath');

      // إرسال الملف للطابعة من المسار
      await Printing.layoutPdf(
        onLayout: (_) async => await File(pdfPath!).readAsBytes(),
        name: fileName,
      );
      print('PDF sent to printer or preview.');
      return pdfPath;
    } catch (e) {
      print('Error generating or printing PDF: $e');
      return null;
    }
  }
}
