import 'dart:typed_data';
import 'package:printing/printing.dart';

class ImageRasterService {
  static Future<Uint8List> pdfToImage(Uint8List pdfBytes) async {
    // Using printing package to rasterize PDF
    await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 200)) {
      final pngBytes = await page.toPng();
      return pngBytes;
    }
    throw Exception('Failed to rasterize PDF');
  }
}
