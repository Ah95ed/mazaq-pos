import 'dart:io';
import 'dart:typed_data';

class EscposImagePrinterService {
  static Future<void> printImageToEscPos({
    required String ip,
    required int port,
    required Uint8List imageBytes,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final socket = await Socket.connect(ip, port, timeout: timeout);
    // ملاحظة: يجب تحويل imageBytes إلى أوامر ESC/POS متوافقة (استخدم esc_pos_utils)
    socket.add([0x1B, 0x40]); // Initialize
    socket.add(
      imageBytes,
    ); // أرسل الصورة (يجب تحويلها لصيغة متوافقة مع ESC/POS)
    socket.add([0x0A]); // Line feed
    await socket.flush();
    await socket.close();
  }
}
