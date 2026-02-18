import '../../entities/printer_settings_entity.dart';
import '../../repositories/printer_settings_repository.dart';

class GetPrinterSettings {
  final PrinterSettingsRepository repository;

  GetPrinterSettings(this.repository);

  Future<PrinterSettingsEntity?> byRole(String role) {
    return repository.getByRole(role);
  }

  // Keep this for legacy or specialized use if needed
  Future<PrinterSettingsEntity?> call(dynamic typeOrRole) {
    if (typeOrRole is String) {
      return repository.getByRole(typeOrRole);
    }
    return repository.getByType(typeOrRole);
  }
}
