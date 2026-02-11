import '../../../core/printing/printer_config.dart';
import '../../entities/printer_settings_entity.dart';
import '../../repositories/printer_settings_repository.dart';

class GetPrinterSettings {
  final PrinterSettingsRepository repository;

  GetPrinterSettings(this.repository);

  Future<PrinterSettingsEntity?> call(PrinterType type) {
    return repository.getByType(type);
  }
}
