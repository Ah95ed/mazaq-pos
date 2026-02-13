import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class PdfGeneratorService {
  static Future<Uint8List> generateArabicInvoice({
    required String customer,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'فاتورة مبيعات',
                style: pw.TextStyle(font: font, fontSize: 20),
              ),
              pw.SizedBox(height: 10),
              pw.Text('العميل: $customer', style: pw.TextStyle(font: font)),
              pw.Divider(),
              ...items.map(
                (item) => pw.Text(
                  '${item['name']} - ${item['qty']} × ${item['price']} = ${item['total']}',
                  style: pw.TextStyle(font: font),
                ),
              ),
              pw.Divider(),
              pw.Text(
                'الإجمالي: $total',
                style: pw.TextStyle(font: font, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }
}
