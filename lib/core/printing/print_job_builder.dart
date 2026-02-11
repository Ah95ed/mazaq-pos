import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/order_entity.dart';

class PrintJobBuilder {
  pw.Document buildOrderDocument({
    required OrderEntity order,
    required String orderIdLabel,
    required String totalLabel,
  }) {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$orderIdLabel #${order.id}'),
              pw.SizedBox(height: 12),
              pw.Text('$totalLabel: ${order.total.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );
    return doc;
  }
}
