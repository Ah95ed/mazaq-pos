import '../../core/printing/printer_config.dart';
import '../../domain/entities/printer_settings_entity.dart';
import '../../domain/repositories/printer_settings_repository.dart';
import '../datasources/local/printer_settings_local_data_source.dart';
import '../models/printer_settings_model.dart';

class PrinterSettingsRepositoryImpl implements PrinterSettingsRepository {
  final PrinterSettingsLocalDataSource localDataSource;

  PrinterSettingsRepositoryImpl(this.localDataSource);

  @override
  Future<PrinterSettingsEntity?> getByType(PrinterType type) async {
    final model = await localDataSource.getByType(type);
    return model?.toEntity();
  }

  @override
  Future<PrinterSettingsEntity?> getByRole(String role) async {
    final model = await localDataSource.getByRole(role);
    return model?.toEntity();
  }

  @override
  Future<void> save(PrinterSettingsEntity settings) {
    final model = PrinterSettingsModel.fromEntity(settings);
    return localDataSource.upsert(model);
  }
}
