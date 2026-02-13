import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// FINAL, DECOUPLED VERSION: This service has NO external project imports.

class PdfGeneratorService {
  Future<Uint8List> generateInvoice({
    // Accepts a list of simple Maps to be fully independent.
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    required String invoiceNumber,
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final arabicTheme = pw.ThemeData.withFont(
      base: ttf,
      bold: pw.Font.ttf(await rootBundle.load("assets/fonts/Cairo-Bold.ttf")),
    );

    pdf.addPage(
      pw.Page(
        theme: arabicTheme,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text('فاتورة ضريبية مبسطة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 22)),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('اسم المطعم: مذاق', style: const pw.TextStyle(fontSize: 16)),
                        pw.Text('فاتورة رقم: $invoiceNumber', style: const pw.TextStyle(fontSize: 16)),
                      ]),
                  pw.Text('الرقم الضريبي: 123456789012345', style: const pw.TextStyle(fontSize: 16)),
                  pw.Divider(height: 30),
                  _buildHeader(),
                  pw.Divider(),
                  ...items.map((item) => _buildInvoiceItem(item)).toList(),
                  pw.Divider(height: 30),
                  _buildTotals(subtotal, tax, total),
                  pw.Spacer(),
                  pw.Center(
                      child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'Invoice Data: $invoiceNumber',
                    width: 80,
                    height: 80,
                  )),
                  pw.SizedBox(height: 10),
                  pw.Center(child: pw.Text('شكراً لزيارتكم!', style: const pw.TextStyle(fontSize: 14))),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(flex: 3, child: pw.Text('الصنف', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Expanded(flex: 1, child: pw.Text('الكمية', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
        pw.Expanded(flex: 1, child: pw.Text('سعر الوحدة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
        pw.Expanded(flex: 1, child: pw.Text('الإجمالي', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
      ],
    );
  }

  // This function now takes a simple Map, removing the broken dependency.
  pw.Widget _buildInvoiceItem(Map<String, dynamic> item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(flex: 3, child: pw.Text(item['name'].toString())),
          pw.Expanded(flex: 1, child: pw.Text(item['quantity'].toString(), textAlign: pw.TextAlign.center)),
          pw.Expanded(flex: 1, child: pw.Text((item['price'] as num).toStringAsFixed(2), textAlign: pw.TextAlign.center)),
          pw.Expanded(flex: 1, child: pw.Text((item['total'] as num).toStringAsFixed(2), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  pw.Widget _buildTotals(double subtotal, double tax, double total) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('المجموع الفرعي:'),
        pw.Text('ضريبة القيمة المضافة (15%):'),
        pw.Divider(),
        pw.Text('الإجمالي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ]),
      pw.SizedBox(width: 20),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.Text(subtotal.toStringAsFixed(2)),
        pw.Text(tax.toStringAsFixed(2)),
        pw.Divider(),
        pw.Text(total.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ]),
    ]);
  }
}
