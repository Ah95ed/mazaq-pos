import '../../domain/entities/order_entity.dart';
import 'printer_config.dart';
import 'printer_service.dart';

class TcpPrinterService implements PrinterService {
  @override
  Future<void> printOrder({
    required PrinterConfig printer,
    required OrderEntity order,
  }) async {
    if (printer.ip == null || printer.port == null) {
      throw ArgumentError('TCP printer requires IP and port.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
