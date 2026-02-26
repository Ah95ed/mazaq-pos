import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_db.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/localization/loc_extensions.dart';
import '../../../../services/pdf_generator_service.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../widgets/app_text_field.dart';
import './print_dialog_widget.dart';

class OrderSummaryPanel extends StatefulWidget {
  const OrderSummaryPanel({super.key});

  @override
  State<OrderSummaryPanel> createState() => _OrderSummaryPanelState();
}

class _OrderSummaryPanelState extends State<OrderSummaryPanel> {
  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _totalController = TextEditingController();
  String? _selectedPanelCategory;
  bool _isProcessingPrint = false;

  final _pdfService = PdfGeneratorService();

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  // New print workflow
  Future<void> _handlePrintWorkflow(OrderProvider provider) async {
    if (provider.draftItems.isEmpty || _isProcessingPrint) return;

    setState(() => _isProcessingPrint = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جار إنشاء الفاتورة...')));

    try {
      // 1. Convert cart items to simple maps
      final itemsAsMaps = provider.draftItems
          .map(
            (item) => {
              'name': item.itemName,
              'quantity': item.quantity,
              'price': item.unitPrice,
              'total': item.lineTotal,
            },
          )
          .toList();

      final subtotal = provider.draftSubtotal;
      final tax = provider.draftTotal - subtotal;

      // 2. Generate PDF bytes
      final pdfBytes = await _pdfService.generateInvoiceBytes(
        items: itemsAsMaps,
        subtotal: subtotal,
        tax: tax,
        total: provider.draftTotal,
        invoiceNumber: DateTime.now().millisecondsSinceEpoch
            .toString()
            .substring(7),
      );

      // 3. Show save dialog and get the saved file path
      final String? savedFilePath = await _pdfService.savePdfDialog(
        context,
        pdfBytes,
      );

      // 4. If the file was saved, show the print dialog
      if (savedFilePath != null && mounted) {
        showPrintDialog(context, filePath: savedFilePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPrint = false);
      }
    }
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
      if (value == null || value.trim().isEmpty) return null;
      final v = double.tryParse(value.trim());
      if (v == null) return context.tr(AppKeys.requiredField);
      return null;
    };
  }

  String _formatAmount(num value) {
    String text = value.toStringAsFixed(6);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'\.0+$'), '');
      text = text.replaceFirst(RegExp(r'(\.\d*?[1-9])0+$'), r'\1');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.md),
        child: Consumer2<OrderProvider, MenuProvider>(
          builder: (context, provider, menuProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(AppKeys.cart),
                  style: TextStyle(
                    fontSize: AppDimensions.textLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                DropdownButtonFormField<String?>(
                  initialValue:
                      menuProvider.filterCategories.contains(
                        _selectedPanelCategory,
                      )
                      ? _selectedPanelCategory
                      : null,
                  decoration: InputDecoration(
                    labelText: context.tr(AppKeys.itemCategory),
                    prefixIcon: Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.brand,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.tr(AppKeys.all)),
                    ),
                    ...menuProvider.filterCategories.map((category) {
                      var label = category;
                      if (category == AppDbValues.categoryDineIn) {
                        label = context.tr(AppKeys.dineIn);
                      } else if (category == AppDbValues.categoryDelivery) {
                        label = context.tr(AppKeys.delivery);
                      } else if (category == AppDbValues.categoryBoth) {
                        label = context.tr(AppKeys.both);
                      }
                      return DropdownMenuItem<String?>(
                        value: category,
                        child: Text(label),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPanelCategory = value;
                    });
                  },
                ),
                SizedBox(height: AppDimensions.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: provider.draftItems.length,
                    separatorBuilder: (_, unusedIndex) =>
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
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: context.tr(AppKeys.deleteItem),
                                onPressed: () =>
                                    provider.removeDraftItem(index),
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
                        child: Text(context.tr(AppKeys.cart)),
                      ),
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            (provider.draftItems.isEmpty || _isProcessingPrint)
                            ? null
                            : () => _handlePrintWorkflow(provider),
                        child: _isProcessingPrint
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                // child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.tr(AppKeys.print)),
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
}
