import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:printing/printing.dart';

import '../core/printing/printer_config_model.dart';
import '../core/printing/windows_printer_service.dart';

class PrinterService {
  /// Prints a PDF file to the given [config].
  /// Priority: IP (TCP Socket) → Windows Printer Name (Spooler API)
  Future<void> printToConfig(
    String pdfPath,
    PrinterConfig config, {
    required Function(String) onStatus,
  }) async {
    try {
      if (config.ip == null && config.printerName == null) {
        throw Exception(
          'طابعة "${config.role}" غير مُعدَّة. افتح إعدادات الطابعات وأضف IP أو اسم الطابعة.',
        );
      }

      onStatus('⏳ جار التحقق من الملف...');
      final file = File(pdfPath);
      if (!await file.exists()) {
        throw Exception('ملف الفاتورة غير موجود: $pdfPath');
      }

      onStatus('⏳ جار تحويل الفاتورة إلى صورة...');
      final image = await _renderPdfToImage(pdfPath);
      if (image == null) throw Exception('فشل تحويل PDF إلى صورة.');

      onStatus('⏳ جار تجهيز بيانات الطباعة...');
      final commands = await _generateEscPos(image);

      if (config.ip != null) {
        onStatus('⏳ الاتصال بـ ${config.ip}:${config.port}...');
        await _sendViaTcp(config.ip!, config.port, commands);
      } else {
        onStatus('⏳ إرسال إلى "${config.printerName}"...');
        final ok = WindowsPrinterService.sendRawBytes(
          config.printerName!,
          commands,
        );
        if (!ok) throw Exception('فشل الإرسال عبر Windows Spooler.');
      }

      onStatus('✅ تمت الطباعة بنجاح!');
    } catch (e) {
      final msg = '❌ ${e.toString()}';
      onStatus(msg);
      BotToast.showText(text: msg);
    }
  }

  Future<void> _sendViaTcp(String ip, int port, Uint8List data) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.add(data);
      await socket.flush();
    } catch (e) {
      throw Exception('فشل الاتصال بـ $ip:$port — $e');
    } finally {
      socket?.destroy();
    }
  }

  Future<img.Image?> _renderPdfToImage(String pdfPath) async {
    try {
      final pdfBytes = await File(pdfPath).readAsBytes();
      // دقة 203 DPI هي الدقة المثالية للطابعات الحرارية لضمان عدم وجود تشويش
      await for (final page in Printing.raster(
        pdfBytes,
        pages: [0],
        dpi: 203,
      )) {
        final png = await page.toPng();
        final rawImg = img.decodeImage(png);
        if (rawImg != null) {
          // تحجيم الصورة لتتناسب تمامًا مع عرض الطابعة (576 بكسل لورق 80 مم)
          // هذا يضمن تطابق عرض الـ PDF مع العرض الحقيقي للطابعة
          return img.copyResize(
            rawImg,
            width: 576,
            interpolation: img.Interpolation.linear,
          );
        }
      }
    } catch (e) {
      print('PDF render error: $e');
    }
    return null;
  }

  Future<Uint8List> _generateEscPos(img.Image image) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm80, profile);
    final bytes = <int>[
      ...gen.reset(), // إعادة تهيئة الطابعة للوضع الافتراضي
      ...gen.setGlobalCodeTable('CP864'), // تحديد الترميز العربي بشكل صريح
      ...gen.imageRaster(
        image,
        align: PosAlign.center,
      ), // إرسال بيانات الصورة النقطية
      ...gen.feed(2),
      ...gen.cut(),
    ];
    return Uint8List.fromList(bytes);
  }
}
