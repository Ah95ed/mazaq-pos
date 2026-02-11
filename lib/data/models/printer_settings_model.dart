import '../../core/constants/app_db.dart';
import '../../core/printing/printer_config.dart';
import '../../domain/entities/printer_settings_entity.dart';

class PrinterSettingsModel {
  final int id;
  final PrinterType type;
  final String? ip;
  final int? port;
  final String? usbModelKey;
  final DateTime updatedAt;

  const PrinterSettingsModel({
    required this.id,
    required this.type,
    this.ip,
    this.port,
    this.usbModelKey,
    required this.updatedAt,
  });

  factory PrinterSettingsModel.fromMap(Map<String, Object?> map) {
    return PrinterSettingsModel(
      id: map[AppDbColumns.id] as int,
      type: _typeFrom(map[AppDbColumns.printerType] as String),
      ip: map[AppDbColumns.printerIp] as String?,
      port: map[AppDbColumns.printerPort] as int?,
      usbModelKey: map[AppDbColumns.usbModelKey] as String?,
      updatedAt: DateTime.parse(map[AppDbColumns.updatedAt] as String),
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    final map = <String, Object?>{
      AppDbColumns.printerType: _typeTo(type),
      AppDbColumns.printerIp: ip,
      AppDbColumns.printerPort: port,
      AppDbColumns.usbModelKey: usbModelKey,
      AppDbColumns.updatedAt: updatedAt.toIso8601String(),
    };
    if (includeId) {
      map[AppDbColumns.id] = id;
    }
    return map;
  }

  PrinterSettingsEntity toEntity() {
    return PrinterSettingsEntity(
      id: id,
      type: type,
      ip: ip,
      port: port,
      usbModelKey: usbModelKey,
      updatedAt: updatedAt,
    );
  }

  factory PrinterSettingsModel.fromEntity(PrinterSettingsEntity entity) {
    return PrinterSettingsModel(
      id: entity.id,
      type: entity.type,
      ip: entity.ip,
      port: entity.port,
      usbModelKey: entity.usbModelKey,
      updatedAt: entity.updatedAt,
    );
  }

  static String _typeTo(PrinterType type) {
    switch (type) {
      case PrinterType.usb:
        return 'USB';
      case PrinterType.tcp:
        return 'TCP';
    }
  }

  static PrinterType _typeFrom(String value) {
    switch (value) {
      case 'USB':
        return PrinterType.usb;
      default:
        return PrinterType.tcp;
    }
  }
}
