import '../../domain/entities/order_entity.dart';
import 'printer_config.dart';

abstract class PrinterService {
  Future<void> printOrder({
    required PrinterConfig printer,
    required OrderEntity order,
  });
}
