import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/pdf_generator_service.dart';
import '../../../../services/printer_service.dart';

// The function to show the bottom sheet. It's now simplified.
void showPrintSheet(BuildContext context) {
  BotToast.showEnhancedWidget(
    allowClick: true,
    crossPage: false,
    onlyOne: true,
    toastBuilder: (cancelFunc) => Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        // Pass the cancelFunc to the dialog to allow it to close itself.
        child: PrintDialogWidget(onCancel: cancelFunc),
      ),
    ),
    duration: const Duration(minutes: 10),
    clickClose: true,
    backgroundColor: Colors.transparent,
  );
}

class PrintDialogWidget extends StatefulWidget {
  // Callback to close the bottom sheet (provided by BotToast)
  final VoidCallback onCancel;

  const PrintDialogWidget({super.key, required this.onCancel});

  @override
  State<PrintDialogWidget> createState() => _PrintDialogWidgetState();
}

class _PrintDialogWidgetState extends State<PrintDialogWidget> {
  String? _loadingStatus;
  bool get _isLoading => _loadingStatus != null;

  final _pdfService = PdfGeneratorService();
  final _printerService = PrinterService();

  Future<void> _handlePrint(String printerName, String ip, int port) async {
    if (_isLoading) return;

    setState(() {
      _loadingStatus = '⏳ جار تهيئة الفاتورة...';
    });

    try {
      // 1. Generate PDF
      final pdfPath = await _pdfService.generateInvoice();
      
      // 2. Print
      await _printerService.printPdfAsImage(
        pdfPath,
        ip,
        port,
        onStatus: (status) {
          if (mounted) {
            setState(() {
              _loadingStatus = status;
            });
          }
        },
      );

      // On success, wait a moment then close the dialog.
      if (_loadingStatus?.startsWith('✅') ?? false) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          widget.onCancel();
        }
      } else {
        // On failure, wait a bit longer so user can see the error, then close.
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) {
          widget.onCancel();
        }
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStatus = '❌ خطأ فادح: ${e.toString()}';
        });
         await Future.delayed(const Duration(seconds: 4));
        if (mounted) {
          widget.onCancel();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent user from dismissing the sheet while printing.
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isLoading ? _buildLoadingView() : _buildSelectionView(),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.inkSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Text(
          'اختر الطابعة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _PrinterButton(
          icon: Icons.local_fire_department,
          label: 'طابعة الشواء',
          iconColor: AppColors.brand,
          onTap: () => _handlePrint('طابعة الشواء', '192.168.0.100', 9100),
          isEnabled: !_isLoading,
        ),
        const SizedBox(height: 12),
        _PrinterButton(
          icon: Icons.kitchen,
          label: 'طابعة المطبخ',
          iconColor: AppColors.success,
          onTap: () => _handlePrint('طابعة المطبخ', '192.168.0.165', 9100),
          isEnabled: !_isLoading,
        ),
        const SizedBox(height: 12),
        _PrinterButton(
          icon: Icons.point_of_sale,
          label: 'طابعة الكاشير',
          iconColor: AppColors.warning,
          onTap: () => _handlePrint('طابعة الكاشير', '192.168.0.166', 9100),
          isEnabled: !_isLoading,
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _loadingStatus ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PrinterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isEnabled;

  const _PrinterButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEnabled ? AppColors.surfaceAlt : Theme.of(context).disabledColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isEnabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 16),
                Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
