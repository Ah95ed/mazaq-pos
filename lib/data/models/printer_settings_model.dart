import '../../core/constants/app_db.dart';
import '../../core/printing/printer_config.dart';
import '../../domain/entities/printer_settings_entity.dart';

class PrinterSettingsModel {
  final int id;
  final PrinterType type;
  final String? ip;
  final int? port;
  final String? usbModelKey;
  final String? printerName;
  final String? role;
  final DateTime updatedAt;

  const PrinterSettingsModel({
    required this.id,
    required this.type,
    this.ip,
    this.port,
    this.usbModelKey,
    this.printerName,
    this.role,
    required this.updatedAt,
  });

  factory PrinterSettingsModel.fromMap(Map<String, Object?> map) {
    return PrinterSettingsModel(
      id: map[AppDbColumns.id] as int,
      type: _typeFrom(map[AppDbColumns.printerType] as String),
      ip: map[AppDbColumns.printerIp] as String?,
      port: map[AppDbColumns.printerPort] as int?,
      usbModelKey: map[AppDbColumns.usbModelKey] as String?,
      printerName: map[AppDbColumns.printerName] as String?,
      role: map[AppDbColumns.printerRole] as String?,
      updatedAt: DateTime.parse(map[AppDbColumns.updatedAt] as String),
    );
  }

  Map<String, Object?> toMap({bool includeId = true}) {
    final map = <String, Object?>{
      AppDbColumns.printerType: _typeTo(type),
      AppDbColumns.printerIp: ip,
      AppDbColumns.printerPort: port,
      AppDbColumns.usbModelKey: usbModelKey,
      AppDbColumns.printerName: printerName,
      AppDbColumns.printerRole: role,
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
      printerName: printerName,
      role: role,
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
      printerName: entity.printerName,
      role: entity.role,
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
