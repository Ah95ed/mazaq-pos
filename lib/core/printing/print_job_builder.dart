import 'package:bidi/bidi.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:project/domain/entities/order_entity.dart' show OrderEntity, OrderType;

// دالة لمعالجة النص العربي
String reshapeArabic(String text) {
  final reshaper = ArabicReshaper();
  final reshaped = reshaper.reshape(text);
  final visual = logicalToVisual(reshaped);
  return String.fromCharCodes(visual);
}

class PrintJobBuilder {
  Future<pw.Document> buildOrderDocument({
    required OrderEntity order,
    required String orderIdLabel,
    required String totalLabel,
  }) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    // تحميل خط Cairo العربي من الأصول
    final arabicFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final arabicFontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                reshapeArabic('مذاق POS'),
                style: pw.TextStyle(
                  font: arabicFontBold,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Order Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    reshapeArabic('$orderIdLabel #${order.id}'),
                    style: pw.TextStyle(
                      font: arabicFontBold,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    dateFormat.format(order.createdAt),
                    style: pw.TextStyle(font: arabicFont, fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                reshapeArabic(
                  order.orderType == OrderType.dineIn ? 'صالة' : 'دليفري',
                ),
                style: pw.TextStyle(font: arabicFont, fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell(
                        reshapeArabic('الصنف'),
                        isHeader: true,
                        font: arabicFont,
                        fontBold: arabicFontBold,
                      ),
                      _buildTableCell(
                        reshapeArabic('الكمية'),
                        isHeader: true,
                        font: arabicFont,
                        fontBold: arabicFontBold,
                      ),
                      _buildTableCell(
                        reshapeArabic('السعر'),
                        isHeader: true,
                        font: arabicFont,
                        fontBold: arabicFontBold,
                      ),
                      _buildTableCell(
                        reshapeArabic('الإجمالي'),
                        isHeader: true,
                        font: arabicFont,
                        fontBold: arabicFontBold,
                      ),
                    ],
                  ),
                  // Items
                  ...order.items.map(
                    (item) => pw.TableRow(
                      children: [
                        _buildTableCell(
                          reshapeArabic(item.itemName),
                          font: arabicFont,
                          fontBold: arabicFontBold,
                        ),
                        _buildTableCell(
                          item.quantity.toString(),
                          font: arabicFont,
                          fontBold: arabicFontBold,
                        ),
                        _buildTableCell(
                          item.unitPrice.toStringAsFixed(2),
                          font: arabicFont,
                          fontBold: arabicFontBold,
                        ),
                        _buildTableCell(
                          item.lineTotal.toStringAsFixed(2),
                          font: arabicFont,
                          fontBold: arabicFontBold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Totals
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildTotalRow(
                    reshapeArabic('الإجمالي الفرعي:'),
                    order.subtotal,
                    font: arabicFont,
                    fontBold: arabicFontBold,
                  ),
                  _buildTotalRow(
                    reshapeArabic('الضريبة:'),
                    order.tax,
                    font: arabicFont,
                    fontBold: arabicFontBold,
                  ),
                  _buildTotalRow(
                    reshapeArabic('الخصم:'),
                    order.discount,
                    font: arabicFont,
                    fontBold: arabicFontBold,
                  ),
                  pw.Divider(),
                  _buildTotalRow(
                    reshapeArabic('$totalLabel:'),
                    order.total,
                    isBold: true,
                    fontSize: 18,
                    font: arabicFont,
                    fontBold: arabicFontBold,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return doc;
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.Font? font,
    pw.Font? fontBold,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isHeader ? fontBold : font,
          fontSize: isHeader ? 14 : 12,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 14,
    pw.Font? font,
    pw.Font? fontBold,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.SizedBox()),
          pw.Container(
            width: 200,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    font: isBold ? fontBold : font,
                    fontSize: fontSize,
                    fontWeight: isBold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
                pw.Text(
                  amount.toStringAsFixed(2),
                  style: pw.TextStyle(
                    font: isBold ? fontBold : font,
                    fontSize: fontSize,
                    fontWeight: isBold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
