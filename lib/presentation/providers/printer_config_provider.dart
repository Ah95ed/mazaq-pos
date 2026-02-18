import 'package:flutter/material.dart';

import '../../core/printing/printer_config_model.dart';
import '../../data/datasources/local/printer_config_local_data_source.dart';

class PrinterConfigProvider extends ChangeNotifier {
  final PrinterConfigLocalDataSource dataSource;

  PrinterConfigProvider({required this.dataSource});

  PrinterConfig? cashier;
  PrinterConfig? kitchen;
  PrinterConfig? grill;

  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      await dataSource.seedDefaults();
      final all = await dataSource.getAll();
      for (final cfg in all) {
        if (cfg.role == 'Cashier') cashier = cfg;
        if (cfg.role == 'Kitchen') kitchen = cfg;
        if (cfg.role == 'Grill') grill = cfg;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save({
    required String role,
    String? printerName,
    String? ip,
    int port = 9100,
  }) async {
    await dataSource.updateByRole(
      role: role,
      printerName: printerName?.isEmpty == true ? null : printerName,
      ip: ip?.isEmpty == true ? null : ip,
      port: port,
    );
    await load();
  }

  PrinterConfig? configForRole(String role) {
    if (role == 'Cashier') return cashier;
    if (role == 'Kitchen') return kitchen;
    if (role == 'Grill') return grill;
    return null;
  }
}
