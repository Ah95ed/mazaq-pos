import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../../core/printing/printer_config_model.dart';
import '../../../core/printing/windows_printer_service.dart';
import '../../providers/printer_config_provider.dart';
import '../../widgets/language_switcher.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<String> _windowsPrinters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      _windowsPrinters = WindowsPrinterService.listPrinters();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<PrinterConfigProvider>().load();
        });
      }
    } catch (e) {
      debugPrint('Init error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(AppKeys.printerSettings)),
        actions: const [LanguageSwitcher()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<PrinterConfigProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: EdgeInsets.all(AppDimensions.lg),
                  children: [
                    _PrinterCard(
                      config: provider.cashier,
                      role: 'Cashier',
                      label: 'طابعة الكاشير',
                      icon: Icons.point_of_sale,
                      color: Colors.blue,
                      windowsPrinters: _windowsPrinters,
                    ),
                    SizedBox(height: AppDimensions.lg),
                    _PrinterCard(
                      config: provider.kitchen,
                      role: 'Kitchen',
                      label: 'طابعة المطبخ',
                      icon: Icons.restaurant,
                      color: Colors.orange,
                      windowsPrinters: _windowsPrinters,
                    ),
                    SizedBox(height: AppDimensions.lg),
                    _PrinterCard(
                      config: provider.grill,
                      role: 'Grill',
                      label: 'طابعة الشواء',
                      icon: Icons.local_fire_department,
                      color: Colors.red,
                      windowsPrinters: _windowsPrinters,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _PrinterCard extends StatefulWidget {
  final PrinterConfig? config;
  final String role;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> windowsPrinters;

  const _PrinterCard({
    required this.config,
    required this.role,
    required this.label,
    required this.icon,
    required this.color,
    required this.windowsPrinters,
  });

  @override
  State<_PrinterCard> createState() => _PrinterCardState();
}

class _PrinterCardState extends State<_PrinterCard> {
  late TextEditingController _ipCtrl;
  late TextEditingController _portCtrl;
  String? _selectedPrinter;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ipCtrl = TextEditingController(text: widget.config?.ip ?? '');
    _portCtrl = TextEditingController(
      text: (widget.config?.port ?? 9100).toString(),
    );
    _selectedPrinter = widget.config?.printerName;
  }

  @override
  void didUpdateWidget(_PrinterCard old) {
    super.didUpdateWidget(old);
    if (widget.config != old.config) {
      _ipCtrl.text = widget.config?.ip ?? '';
      _portCtrl.text = (widget.config?.port ?? 9100).toString();
      _selectedPrinter = widget.config?.printerName;
    }
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<PrinterConfigProvider>().save(
        role: widget.role,
        printerName: _selectedPrinter,
        ip: _ipCtrl.text.trim().isEmpty ? null : _ipCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text.trim()) ?? 9100,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم حفظ إعدادات ${widget.label}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.color.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Windows Printer Dropdown
            DropdownButtonFormField<String>(
              value: widget.windowsPrinters.contains(_selectedPrinter)
                  ? _selectedPrinter
                  : null,
              decoration: const InputDecoration(
                labelText: 'طابعة Windows (اختياري)',
                prefixIcon: Icon(Icons.print),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('— بدون —')),
                ...widget.windowsPrinters.map(
                  (n) => DropdownMenuItem(value: n, child: Text(n)),
                ),
              ],
              onChanged: (v) => setState(() => _selectedPrinter = v),
            ),
            const SizedBox(height: 12),

            // IP + Port row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ipCtrl,
                    decoration: const InputDecoration(
                      labelText: 'عنوان IP',
                      hintText: '192.168.1.100',
                      prefixIcon: Icon(Icons.wifi),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _portCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '9100',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'جار الحفظ...' : 'حفظ الإعدادات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
