import 'package:flutter/material.dart';
import 'package:project/presentation/providers/printer_config_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/printing/printer_config_model.dart';
import '../../../../services/printer_service.dart';

void showPrintDialog(BuildContext context, {required String filePath}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PrintDialogWidget(
      filePath: filePath,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

class PrintDialogWidget extends StatefulWidget {
  final String filePath;
  final VoidCallback onClose;

  const PrintDialogWidget({
    super.key,
    required this.filePath,
    required this.onClose,
  });

  @override
  State<PrintDialogWidget> createState() => _PrintDialogWidgetState();
}

class _PrintDialogWidgetState extends State<PrintDialogWidget> {
  final _service = PrinterService();
  String _status = 'اختر الطابعة المطلوبة';
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterConfigProvider>().load();
    });
  }

  Future<void> _print(PrinterConfig? config, String label) async {
    if (config == null || (config.ip == null && config.printerName == null)) {
      setState(
        () => _status =
            '⚠️ طابعة "$label" غير مُعدَّة. افتح الإعدادات وأضف IP أو اسم الطابعة.',
      );
      return;
    }
    setState(() {
      _isPrinting = true;
      _status = '⏳ جار الطباعة إلى $label...';
    });
    await _service.printToConfig(
      widget.filePath,
      config,
      onStatus: (s) {
        if (mounted) setState(() => _status = s);
      },
    );
    if (mounted) setState(() => _isPrinting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.md),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.lg),
        width: 380,
        child: Consumer<PrinterConfigProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'خيارات الطباعة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _PrintBtn(
                  label: 'طباعة كاشير',
                  icon: Icons.point_of_sale,
                  color: Colors.blue,
                  subtitle: _configSubtitle(provider.cashier),
                  disabled: _isPrinting,
                  onTap: () => _print(provider.cashier, 'الكاشير'),
                ),
                const SizedBox(height: 10),
                _PrintBtn(
                  label: 'طباعة مطبخ',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  subtitle: _configSubtitle(provider.kitchen),
                  disabled: _isPrinting,
                  onTap: () => _print(provider.kitchen, 'المطبخ'),
                ),
                const SizedBox(height: 10),
                _PrintBtn(
                  label: 'طباعة شواء',
                  icon: Icons.local_fire_department,
                  color: Colors.red,
                  subtitle: _configSubtitle(provider.grill),
                  disabled: _isPrinting,
                  onTap: () => _print(provider.grill, 'الشواء'),
                ),

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _status.contains('❌')
                          ? Colors.red
                          : _status.contains('✅')
                          ? Colors.green
                          : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('إعدادات الطابعات'),
                      onPressed: () {
                        widget.onClose();
                        Navigator.pushNamed(context, '/printer-settings');
                      },
                    ),
                    TextButton(
                      onPressed: _isPrinting ? null : widget.onClose,
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _configSubtitle(PrinterConfig? c) {
    if (c == null) return 'غير مُعدَّة';
    if (c.ip != null) return '${c.ip}:${c.port}';
    if (c.printerName != null) return c.printerName!;
    return 'غير مُعدَّة';
  }
}

class _PrintBtn extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool disabled;
  final VoidCallback onTap;

  const _PrintBtn({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey : color,
          foregroundColor: Colors.white,
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: disabled ? null : onTap,
      ),
    );
  }
}
