import '../../core/printing/printer_config.dart';
import '../entities/printer_settings_entity.dart';

abstract class PrinterSettingsRepository {
  Future<PrinterSettingsEntity?> getByType(PrinterType type);
  Future<PrinterSettingsEntity?> getByRole(String role);
  Future<void> save(PrinterSettingsEntity settings);
}
