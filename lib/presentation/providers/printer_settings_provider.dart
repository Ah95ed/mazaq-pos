import 'package:flutter/material.dart';

import '../../core/printing/printer_config.dart';
import '../../domain/entities/printer_settings_entity.dart';
import '../../domain/usecases/printer_settings/get_printer_settings.dart';
import '../../domain/usecases/printer_settings/save_printer_settings.dart';

class PrinterSettingsProvider extends ChangeNotifier {
  final GetPrinterSettings getSettings;
  final SavePrinterSettings saveSettings;

  PrinterSettingsProvider({
    required this.getSettings,
    required this.saveSettings,
  });

  PrinterSettingsEntity? _kitchenSettings;
  PrinterSettingsEntity? _grillSettings;
  PrinterSettingsEntity? _cashierSettings;

  PrinterSettingsEntity? get kitchenSettings => _kitchenSettings;
  PrinterSettingsEntity? get grillSettings => _grillSettings;
  PrinterSettingsEntity? get cashierSettings => _cashierSettings;

  Future<void> load() async {
    _kitchenSettings = await getSettings.byRole('Kitchen');
    _grillSettings = await getSettings.byRole('Grill');
    _cashierSettings = await getSettings.byRole('Cashier');
    notifyListeners();
  }

  Future<void> saveRole({
    required String role,
    String? printerName,
    String? ip,
    int? port,
  }) async {
    final existing = await getSettings.byRole(role);
    final settings = PrinterSettingsEntity(
      id: existing?.id ?? 0,
      type: PrinterType.tcp,
      printerName: printerName,
      ip: ip,
      port: port,
      role: role,
      updatedAt: DateTime.now(),
    );
    await saveSettings(settings);

    // Update local state
    if (role == 'Kitchen') _kitchenSettings = settings;
    if (role == 'Grill') _grillSettings = settings;
    if (role == 'Cashier') _cashierSettings = settings;

    notifyListeners();
  }
}
