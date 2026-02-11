import '../../core/printing/printer_config.dart';

class PrinterSettingsEntity {
  final int id;
  final PrinterType type;
  final String? ip;
  final int? port;
  final String? usbModelKey;
  final DateTime updatedAt;

  const PrinterSettingsEntity({
    required this.id,
    required this.type,
    this.ip,
    this.port,
    this.usbModelKey,
    required this.updatedAt,
  });
}
