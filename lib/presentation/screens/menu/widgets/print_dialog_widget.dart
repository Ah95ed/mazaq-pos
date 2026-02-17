import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

import '../../../../services/printer_service.dart';
import '../../settings/printer_settings_screen.dart';

// The function now passes the original BuildContext to be used for navigation.
void showPrintDialog(BuildContext context, {required String filePath}) {
  BotToast.showEnhancedWidget(
    onlyOne: true,
    toastBuilder: (cancelFunc) {
      return Material(
        color: Colors.black26,
        child: Center(
          child: PrintDialogWidget(
            navigatorContext: context, // Pass the valid context here
            filePath: filePath,
            onCancel: cancelFunc,
          ),
        ),
      );
    },
  );
}

class PrintDialogWidget extends StatefulWidget {
  final BuildContext navigatorContext; // Context that has a Navigator
  final String filePath;
  final VoidCallback onCancel;

  const PrintDialogWidget({
    super.key,
    required this.navigatorContext,
    required this.filePath,
    required this.onCancel,
  });

  @override
  State<PrintDialogWidget> createState() => _PrintDialogWidgetState();
}

class _PrintDialogWidgetState extends State<PrintDialogWidget> {
  String? _loadingStatus;
  bool get _isLoading => _loadingStatus != null;

  final _printerService = PrinterService();

  Future<void> _handlePrint(String printerName, String ip) async {
    if (_isLoading) return;

    setState(() {
      _loadingStatus = '⏳ جار الطباعة على $printerName...';
    });

    await _printerService.printPdfAsImage(
      widget.filePath,
      ip,
      9100, // Standard port
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _loadingStatus = status;
          });
        }
      },
    );

    if (_loadingStatus?.startsWith('✅') ?? false) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onCancel();
    }
  }

  void _navigateToSettings() {
    // First, close the current dialog.
    widget.onCancel();
    // Then, use the valid navigator context to push the new screen.
    Navigator.of(widget.navigatorContext).push(
      MaterialPageRoute(builder: (context) => const PrinterSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Card(
        margin: const EdgeInsets.all(24),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isLoading ? _buildLoadingView() : _buildSelectionView(),
        ),
      ),
    );
  }

  // Store IPs for each printer
  final Map<String, String> _printerIps = {
    'طابعة الشواء': '192.168.0.100',
    'طابعة المطبخ': '192.168.0.165',
    'طابعة الكاشير': '192.168.0.166',
  };

  @override
  void initState() {
    super.initState();
    _loadPrinterIps();
  }

  Future<void> _loadPrinterIps() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _printerIps.keys) {
      final savedIp = prefs.getString('printer_ip_$key');
      if (savedIp != null && savedIp.isNotEmpty) {
        setState(() {
          _printerIps[key] = savedIp;
        });
      }
    }
  }

  Future<void> _savePrinterIp(String printerName, String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_ip_$printerName', ip);
  }

  void _changePrinterIp(String printerName) async {
    // Close the main dialog first
    widget.onCancel();
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Wait for dialog to close

    String ipValue = _printerIps[printerName] ?? '';
    final controller = TextEditingController(text: ipValue);
    String? newIp = await showDialog<String>(
      context: widget.navigatorContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('تغيير IP لـ $printerName'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: 'IP جديد'),
            controller: controller,
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('حفظ'),
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            ),
          ],
        );
      },
    );
    if (newIp != null && newIp.isNotEmpty) {
      await _savePrinterIp(printerName, newIp);
      if (mounted) {
        setState(() {
          _printerIps[printerName] = newIp;
        });
      }
    }
  }

  Widget _buildSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'اختر طابعة',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        _PrinterButton(
          label: 'طابعة الشواء',
          ip: _printerIps['طابعة الشواء']!,
          icon: Icons.local_fire_department,
          onPrint: () =>
              _handlePrint('طابعة الشواء', _printerIps['طابعة الشواء']!),
          onSettings: _navigateToSettings,
          onChangeIp: () => _changePrinterIp('طابعة الشواء'),
        ),
        _PrinterButton(
          label: 'طابعة المطبخ',
          ip: _printerIps['طابعة المطبخ']!,
          icon: Icons.kitchen,
          onPrint: () =>
              _handlePrint('طابعة المطبخ', _printerIps['طابعة المطبخ']!),
          onSettings: _navigateToSettings,
          onChangeIp: () => _changePrinterIp('طابعة المطبخ'),
        ),
        _PrinterButton(
          label: 'طابعة الكاشير',
          ip: _printerIps['طابعة الكاشير']!,
          icon: Icons.point_of_sale,
          onPrint: () =>
              _handlePrint('طابعة الكاشير', _printerIps['طابعة الكاشير']!),
          onSettings: _navigateToSettings,
          onChangeIp: () => _changePrinterIp('طابعة الكاشير'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextButton(
            onPressed: widget.onCancel,
            child: const Text('إلغاء'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            _loadingStatus ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_loadingStatus?.startsWith('❌') ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: widget.onCancel,
                child: const Text('إغلاق'),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrinterButton extends StatelessWidget {
  final String label;
  final String ip;
  final IconData icon;
  final VoidCallback onPrint;
  final VoidCallback onSettings;
  final VoidCallback? onChangeIp;

  const _PrinterButton({
    required this.label,
    required this.ip,
    required this.icon,
    required this.onPrint,
    required this.onSettings,
    this.onChangeIp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Text('IP: $ip'),
      onTap: onPrint,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onChangeIp != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onChangeIp,
            ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: onSettings),
        ],
      ),
      contentPadding: const EdgeInsets.only(left: 20, right: 12),
    );
  }
}
