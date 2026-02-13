import 'dart:io';
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:pdf_render/pdf_render.dart';

class PrinterService {
  Future<void> printPdfAsImage(
    String pdfPath,
    String ip,
    int port, {
    required Function(String) onStatus,
  }) async {
    try {
      // 1. Render PDF to Image
      onStatus('⏳ جار تحويل الفاتورة إلى صورة...');
      final image = await _renderPdfToImage(pdfPath);
      if (image == null) {
        throw Exception('فشل تحويل PDF إلى صورة.');
      }

      // 2. Connect to the printer
      onStatus('⏳ جار الاتصال بالطابعة...');
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      // 3. Generate ESC/POS commands
      onStatus('⏳ جار تجهيز بيانات الطباعة...');
      final commands = await _generatePrintCommands(image);

      // 4. Send to printer
      onStatus('⏳ جار إرسال البيانات للطابعة...');
      socket.add(commands);
      await socket.flush();
      socket.destroy();

      onStatus('✅ تمت الطباعة بنجاح!');
    } catch (e) {
      onStatus('❌ فشلت الطباعة: ${e.toString()}');
      BotToast.showText(
        text: 'فشلت الطباعة: ${e.toString()}',
      ); // Show detailed error
    }
  }

  Future<img.Image?> _renderPdfToImage(String pdfPath) async {
    final doc = await PdfDocument.openFile(pdfPath);
    try {
      final page = await doc.getPage(1); // Render the first page

      // Corrected the height calculation to be an integer
      final pageImage = await page.render(
        width: 384,
        height: (page.height * (384 / page.width)).round(),
      );

      // Corrected to use pageImage.pixels
      return img.decodeImage(pageImage.pixels);
    } finally {
      doc.dispose();
    }
  }

  Future<Uint8List> _generatePrintCommands(img.Image image) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Add commands to print the image
    bytes += generator.imageRaster(image);
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }
}
