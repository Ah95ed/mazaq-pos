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
    // 1. تحميل خط يدعم اللغة العربية (مثل Cairo أو Amiri)
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final fontArabic = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    // 2. إعداد الـ Theme الخاص بالـ PDF لتحديد الخط والنصوص المكتوبة من اليمين لليسار (RTL) تلقائياً.
    final theme = pw.ThemeData.withFont(base: fontArabic);

    // 3. تحديد قياسات الصفحة 80mm (الطابعات الحرارية)
    final pageFormat = PdfPageFormat.roll80.copyWith(
      marginTop: 2.0 * PdfPageFormat.mm,
      marginBottom: 2.0 * PdfPageFormat.mm,
      marginLeft: 2.0 * PdfPageFormat.mm,
      marginRight: 2.0 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: theme,
        textDirection: pw.TextDirection.rtl, // التوجيه الأساسي للمستند ككل
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // العنوان
              pw.Center(
                child: pw.Text(
                  'فاتورة مبيعات',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // الترويسة
              pw.Text('العميل: $customer', style: pw.TextStyle(fontSize: 14)),
              pw.Divider(thickness: 1),

              // أسماء أعمدة الجدول
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('الصنف', textAlign: pw.TextAlign.right),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('الكمية', textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('السعر', textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('الإجمالي', textAlign: pw.TextAlign.left),
                  ),
                ],
              ),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),

              // صفوف العناصر (البيانات)
              ...items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          '${item['name']}',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${item['qty']}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '${item['price']}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '${item['total']}',
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.Divider(thickness: 1),

              // الإجمالي النهائي
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'الإجمالي الكلي:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '$total',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'شكرا لزيارتكم',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}
