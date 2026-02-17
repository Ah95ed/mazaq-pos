import 'dart:io';
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:pdf_render/pdf_render.dart';

class PrinterService {
  // The method now accepts a file path instead of raw bytes.
  Future<void> printPdfAsImage(
    String pdfPath,
    String ip,
    int port, {
    required Function(String) onStatus,
  }) async {
    try {
      // 0. Read the file from the provided path
      onStatus('⏳ جار قراءة الملف...');
      final file = File(pdfPath);
      if (!await file.exists()) {
        throw Exception('ملف الفاتورة غير موجود في المسار المحدد.');
      }
      final Uint8List pdfBytes = await file.readAsBytes();

      // 1. Render PDF from bytes to Image
      onStatus('⏳ جار تحويل الفاتورة إلى صورة...');
      final image = await _renderPdfToImage(pdfBytes);
      if (image == null) {
        throw Exception('فشل تحويل PDF إلى صورة.');
      }

      // 2. Connect to the printer
      onStatus('⏳ جار الاتصال بالطابعة ($ip)...');
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));

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
      final errorMsg = '❌ فشلت الطباعة: ${e.toString()}';
      onStatus(errorMsg);
      BotToast.showText(text: errorMsg); // Show detailed error in a toast
    }
  }

  Future<img.Image?> _renderPdfToImage(Uint8List pdfBytes) async {
    final doc = await PdfDocument.openData(pdfBytes);
    try {
      final page = await doc.getPage(1);
      final pageImage = await page.render(width: 384, height: (page.height * (384 / page.width)).round());
      return img.decodeImage(pageImage.pixels);
    } finally {
      doc.dispose();
    }
  }

  Future<Uint8List> _generatePrintCommands(img.Image image) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.imageRaster(image, align: PosAlign.center);
    bytes += generator.feed(2);
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }
}
