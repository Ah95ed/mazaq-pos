import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// FIXED: Added the missing import for rootBundle
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGeneratorService {
  // This method generates the PDF as raw data.
  Future<Uint8List> generateInvoiceBytes({
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
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              children: [
                pw.Text(
                  'غصن البان',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('رقم الفاتورة: $invoiceNumber'),
                pw.Divider(),
                _buildHeader(),
                pw.Divider(),
                ...items.map((item) => _buildInvoiceItem(item)),
                pw.Divider(),
                _buildTotals(subtotal, tax, total),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // This new method handles saving the PDF and returns the file path.
  Future<String?> savePdfDialog(
    BuildContext context,
    Uint8List pdfBytes,
  ) async {
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('حفظ الفاتورة'),
        content: const Text('اختر مكان حفظ ملف الـ PDF قبل الطباعة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          // Save to Downloads option
          FilledButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('حفظ في التنزيلات'),
            onPressed: () async {
              try {
                final dir = await getDownloadsDirectory();
                if (dir == null)
                  throw Exception('لا يمكن الوصول لمجلد التنزيلات');
                final path =
                    '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
                await File(path).writeAsBytes(pdfBytes);
                Navigator.pop(ctx, path);
              } catch (e) {
                Navigator.pop(ctx, null);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
              }
            },
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHeader() {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            'الصنف',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'الكمية',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'السعر',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceItem(Map<String, dynamic> item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 2, child: pw.Text(item['name'].toString())),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              item['quantity'].toString(),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              (item['total'] as num).toStringAsFixed(2),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotals(double subtotal, double tax, double total) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('المجموع الفرعي:'),
            pw.Text(subtotal.toStringAsFixed(2)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('ضريبة القيمة المضافة (15%):'),
            pw.Text(tax.toStringAsFixed(2)),
          ],
        ),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'الإجمالي:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15),
            ),
            pw.Text(
              total.toStringAsFixed(2),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}
