import '../../domain/entities/order_entity.dart';
import 'printer_config.dart';
import 'printer_service.dart';

class UsbPrinterService implements PrinterService {
  @override
  Future<void> printOrder({
    required PrinterConfig printer,
    required OrderEntity order,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
