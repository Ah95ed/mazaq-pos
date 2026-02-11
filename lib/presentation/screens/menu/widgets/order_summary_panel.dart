import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/loc_extensions.dart';
import '../../../../core/printing/print_job_builder.dart';
import '../../../../core/printing/printer_config.dart';
import '../../../../core/printing/tcp_printer_service.dart';
import '../../../../core/printing/usb_printer_service.dart';
import '../../../widgets/app_text_field.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../providers/printer_settings_provider.dart';
import '../../../providers/order_provider.dart';

class OrderSummaryPanel extends StatefulWidget {
  const OrderSummaryPanel({super.key});

  @override
  State<OrderSummaryPanel> createState() => _OrderSummaryPanelState();
}

class _OrderSummaryPanelState extends State<OrderSummaryPanel> {
  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _totalController = TextEditingController();

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _showPriceEditor(
    BuildContext context,
    OrderProvider provider,
    int index,
    double currentPrice,
  ) async {
    final controller = TextEditingController(text: _formatAmount(currentPrice));
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(AppKeys.editItemPrice)),
          content: Form(
            key: formKey,
            child: AppTextField(
              controller: controller,
              label: context.tr(AppKeys.price),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _requiredValidator(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final value = double.parse(controller.text.trim());
                provider.updateItemPrice(index, value);
                Navigator.pop(context);
              },
              child: Text(context.tr(AppKeys.save)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTotalsEditor(
    BuildContext context,
    OrderProvider provider,
  ) async {
    _taxController.text = _formatAmount(provider.manualTax);
    _discountController.text = _formatAmount(provider.manualDiscount);
    _totalController.text = provider.manualTotal == null
        ? ''
        : _formatAmount(provider.manualTotal!);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(AppKeys.adjustTotals)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _taxController,
                  label: context.tr(AppKeys.tax),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _optionalNumberValidator(context),
                ),
                SizedBox(height: AppDimensions.md),
                AppTextField(
                  controller: _discountController,
                  label: context.tr(AppKeys.discount),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _optionalNumberValidator(context),
                ),
                SizedBox(height: AppDimensions.md),
                AppTextField(
                  controller: _totalController,
                  label: context.tr(AppKeys.manualTotal),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _optionalNumberValidator(context),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final tax = double.tryParse(_taxController.text.trim()) ?? 0;
                final discount =
                    double.tryParse(_discountController.text.trim()) ?? 0;
                final totalText = _totalController.text.trim();
                final total = totalText.isEmpty
                    ? null
                    : double.parse(totalText);
                provider.setManualTotals(
                  tax: tax,
                  discount: discount,
                  total: total,
                );
                Navigator.pop(context);
              },
              child: Text(context.tr(AppKeys.save)),
            ),
          ],
        );
      },
    );
  }

  String? Function(String?) _requiredValidator(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.tr(AppKeys.requiredField);
      }
      return null;
    };
  }

  String? Function(String?) _optionalNumberValidator(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
      if (double.tryParse(value.trim()) == null) {
        return context.tr(AppKeys.requiredField);
      }
      return null;
    };
  }

  String _formatAmount(double value) {
    final text = value.toStringAsFixed(6);
    final trimmed = text
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.md),
        child: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(AppKeys.order),
                  style: TextStyle(
                    fontSize: AppDimensions.textLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: provider.draftItems.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.outline),
                    itemBuilder: (context, index) {
                      final item = provider.draftItems[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: TextStyle(fontSize: AppDimensions.textSm),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: item.quantity > 1
                                    ? () => provider.updateItemQuantity(
                                        index,
                                        item.quantity - 1,
                                      )
                                    : null,
                              ),
                              Text(
                                '${context.tr(AppKeys.quantity)}: ${item.quantity}',
                                style: TextStyle(
                                  fontSize: AppDimensions.textSm,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => provider.updateItemQuantity(
                                  index,
                                  item.quantity + 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: AppDimensions.sm),
                          GestureDetector(
                            onTap: () => _showPriceEditor(
                              context,
                              provider,
                              index,
                              item.unitPrice,
                            ),
                            child: Text(
                              _formatAmount(item.lineTotal),
                              style: TextStyle(
                                fontSize: AppDimensions.textSm,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr(AppKeys.total)),
                    Row(
                      children: [
                        Text(_formatAmount(provider.draftTotal)),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showTotalsEditor(context, provider),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: provider.draftItems.isEmpty
                            ? null
                            : () {
                                provider.submitDraft();
                              },
                        child: Text(context.tr(AppKeys.order)),
                      ),
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: provider.draftItems.isEmpty
                            ? null
                            : () => _showPrintOptions(context, provider),
                        child: Text(context.tr(AppKeys.print)),
                      ),
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

  Future<void> _showPrintOptions(
    BuildContext context,
    OrderProvider provider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.usb),
                title: Text(context.tr(AppKeys.usbPrinter)),
                onTap: () {
                  Navigator.pop(context);
                  _printUsb(context, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wifi),
                title: Text(context.tr(AppKeys.wifiPrinter)),
                onTap: () {
                  Navigator.pop(context);
                  _printWifi(context, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(context.tr(AppKeys.printerSettings)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.printerSettings);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _printUsb(BuildContext context, OrderProvider provider) async {
    final order = _buildDraftOrder(provider);
    final builder = PrintJobBuilder();
    builder.buildOrderDocument(
      order: order,
      orderIdLabel: context.tr(AppKeys.orderIdLabel),
      totalLabel: context.tr(AppKeys.totalLabel),
    );

    final printer = PrinterConfig(
      id: 'usb_1',
      name: context.tr(AppKeys.usbPrinter),
      type: PrinterType.usb,
    );

    await UsbPrinterService().printOrder(printer: printer, order: order);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(AppKeys.printUsbSuccess))),
    );
  }

  Future<void> _printWifi(BuildContext context, OrderProvider provider) async {
    final settings = context.read<PrinterSettingsProvider>().wifiSettings;
    if (settings?.ip == null || settings?.port == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(AppKeys.printerNotConfigured))),
      );
      return;
    }

    final order = _buildDraftOrder(provider);
    final builder = PrintJobBuilder();
    builder.buildOrderDocument(
      order: order,
      orderIdLabel: context.tr(AppKeys.orderIdLabel),
      totalLabel: context.tr(AppKeys.totalLabel),
    );

    final printer = PrinterConfig(
      id: 'wifi_1',
      name: context.tr(AppKeys.wifiPrinter),
      type: PrinterType.tcp,
      ip: settings?.ip,
      port: settings?.port,
    );

    await TcpPrinterService().printOrder(printer: printer, order: order);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(AppKeys.printWifiSuccess))),
    );
  }

  OrderEntity _buildDraftOrder(OrderProvider provider) {
    final subtotal = provider.draftSubtotal;
    final tax = subtotal * AppConfig.taxRate;
    final discount = AppConfig.defaultDiscount;
    final total = subtotal + tax - discount;
    final now = DateTime.now();

    return OrderEntity(
      id: 0,
      orderType: provider.orderType,
      status: OrderStatus.newOrder,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      createdAt: now,
      updatedAt: now,
      items: provider.draftItems,
    );
  }
}
