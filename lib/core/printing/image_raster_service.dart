import 'dart:typed_data';
import 'package:pdf_render/pdf_render.dart';

class ImageRasterService {
  static Future<Uint8List> pdfToImage(Uint8List pdfBytes) async {
    final doc = await PdfDocument.openData(pdfBytes);
    final page = await doc.getPage(1);
    final img = await page.render(
      width: page.width.toInt(),
      height: page.height.toInt(),
    );
    final bytes = img.pixels;
    img.dispose();
    await doc.dispose();
    return bytes;
  }
}
