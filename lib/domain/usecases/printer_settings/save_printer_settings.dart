import '../../entities/printer_settings_entity.dart';
import '../../repositories/printer_settings_repository.dart';

class SavePrinterSettings {
  final PrinterSettingsRepository repository;

  SavePrinterSettings(this.repository);

  Future<void> call(PrinterSettingsEntity settings) {
    return repository.save(settings);
  }
}
