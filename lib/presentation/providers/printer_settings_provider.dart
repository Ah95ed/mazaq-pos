import 'package:flutter/material.dart';

import '../../core/constants/printer_options.dart';
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

  PrinterSettingsEntity? _usbSettings;
  PrinterSettingsEntity? _wifiSettings;

  PrinterSettingsEntity? get usbSettings => _usbSettings;
  PrinterSettingsEntity? get wifiSettings => _wifiSettings;

  String get defaultUsbModelKey => PrinterOptions.usbModelKeys.first;

  Future<void> load() async {
    _usbSettings = await getSettings(PrinterType.usb);
    _wifiSettings = await getSettings(PrinterType.tcp);
    notifyListeners();
  }

  Future<void> saveUsb({required String modelKey}) async {
    final settings = PrinterSettingsEntity(
      id: _usbSettings?.id ?? 0,
      type: PrinterType.usb,
      usbModelKey: modelKey,
      updatedAt: DateTime.now(),
    );
    await saveSettings(settings);
    _usbSettings = settings;
    notifyListeners();
  }

  Future<void> saveWifi({required String ip, required int port}) async {
    final settings = PrinterSettingsEntity(
      id: _wifiSettings?.id ?? 0,
      type: PrinterType.tcp,
      ip: ip,
      port: port,
      updatedAt: DateTime.now(),
    );
    await saveSettings(settings);
    _wifiSettings = settings;
    notifyListeners();
  }
}
