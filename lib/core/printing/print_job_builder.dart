import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/order_entity.dart';

class PrintJobBuilder {
  pw.Document buildOrderDocument({
    required OrderEntity order,
    required String orderIdLabel,
    required String totalLabel,
  }) {
    final doc = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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
                'مذاق POS',
                style: pw.TextStyle(
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
                    '$orderIdLabel #${order.id}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    dateFormat.format(order.createdAt),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                order.orderType == OrderType.dineIn ? 'صالة' : 'دليفري',
                style: const pw.TextStyle(fontSize: 14),
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
                      _buildTableCell('الصنف', isHeader: true),
                      _buildTableCell('الكمية', isHeader: true),
                      _buildTableCell('السعر', isHeader: true),
                      _buildTableCell('الإجمالي', isHeader: true),
                    ],
                  ),
                  // Items
                  ...order.items.map(
                    (item) => pw.TableRow(
                      children: [
                        _buildTableCell(item.itemName),
                        _buildTableCell(item.quantity.toString()),
                        _buildTableCell(item.unitPrice.toStringAsFixed(2)),
                        _buildTableCell(item.lineTotal.toStringAsFixed(2)),
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
                  _buildTotalRow('الإجمالي الفرعي:', order.subtotal),
                  _buildTotalRow('الضريبة:', order.tax),
                  _buildTotalRow('الخصم:', order.discount),
                  pw.Divider(),
                  _buildTotalRow(
                    '$totalLabel:',
                    order.total,
                    isBold: true,
                    fontSize: 18,
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

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
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
                    fontSize: fontSize,
                    fontWeight: isBold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
                pw.Text(
                  amount.toStringAsFixed(2),
                  style: pw.TextStyle(
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
