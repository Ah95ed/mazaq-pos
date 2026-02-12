import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/export_format.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../../domain/entities/sales_section_report_entity.dart';
import '../../providers/export_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/language_switcher.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(AppKeys.salesTab)),
        actions: [
          const LanguageSwitcher(),
          IconButton(
            onPressed: () => _showExportSheet(context),
            icon: const Icon(Icons.file_download),
            tooltip: context.tr(AppKeys.export),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Consumer<SalesProvider>(
          builder: (context, provider, _) {
            final summary = provider.summary;
            final dailyReport = provider.dailyReport;
            final monthlyReport = provider.monthlyReport;
            if (summary == null) {
              return EmptyState(
                message: context.tr(AppKeys.emptySales),
                icon: Icons.bar_chart,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(AppKeys.salesSummary),
                  style: TextStyle(
                    fontSize: AppDimensions.textLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      final sections = [
                        _SalesSectionCard(
                          title: context.tr(AppKeys.dineIn),
                          totalLabel: context.tr(AppKeys.totalDineIn),
                          totalValue: _formatAmount(summary.dineInTotal),
                          daily: dailyReport?.dineIn,
                          monthly: monthlyReport?.dineIn,
                          localeCode: Localizations.localeOf(
                            context,
                          ).languageCode,
                          color: AppColors.brandSoft,
                        ),
                        _SalesSectionCard(
                          title: context.tr(AppKeys.delivery),
                          totalLabel: context.tr(AppKeys.totalDelivery),
                          totalValue: _formatAmount(summary.deliveryTotal),
                          daily: dailyReport?.delivery,
                          monthly: monthlyReport?.delivery,
                          localeCode: Localizations.localeOf(
                            context,
                          ).languageCode,
                          color: AppColors.surfaceAlt,
                        ),
                      ];

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(child: sections[0]),
                            SizedBox(width: AppDimensions.lg),
                            Expanded(child: sections[1]),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          sections[0],
                          SizedBox(height: AppDimensions.md),
                          sections[1],
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                _SummaryCard(
                  label: context.tr(AppKeys.totalSales),
                  value: _formatAmount(summary.overallTotal),
                  color: AppColors.brand,
                  isBold: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    final text = value.toStringAsFixed(6);
    final trimmed = text
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  Future<void> _showExportSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ExportRow(
                label: context.tr(AppKeys.exportItems),
                onCsv: () => _export(context, ExportFormat.csv, _Table.items),
                onJson: () => _export(context, ExportFormat.json, _Table.items),
              ),
              SizedBox(height: AppDimensions.md),
              _ExportRow(
                label: context.tr(AppKeys.exportOrders),
                onCsv: () => _export(context, ExportFormat.csv, _Table.orders),
                onJson: () =>
                    _export(context, ExportFormat.json, _Table.orders),
              ),
              SizedBox(height: AppDimensions.md),
              _ExportRow(
                label: context.tr(AppKeys.exportSales),
                onCsv: () => _export(context, ExportFormat.csv, _Table.sales),
                onJson: () => _export(context, ExportFormat.json, _Table.sales),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _export(
    BuildContext context,
    ExportFormat format,
    _Table table,
  ) async {
    final provider = context.read<ExportProvider>();
    switch (table) {
      case _Table.items:
        await provider.exportItems(format);
        break;
      case _Table.orders:
        await provider.exportOrders(format);
        break;
      case _Table.sales:
        await provider.exportSales(format);
        break;
    }

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);
    final path = provider.lastExportPath;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr(AppKeys.exportDone)}: $path')),
      );
    }
  }
}

class _SalesSectionCard extends StatelessWidget {
  final String title;
  final String totalLabel;
  final String totalValue;
  final SalesSectionReportEntity? daily;
  final SalesSectionReportEntity? monthly;
  final String localeCode;
  final Color color;

  const _SalesSectionCard({
    required this.title,
    required this.totalLabel,
    required this.totalValue,
    required this.daily,
    required this.monthly,
    required this.localeCode,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.textLg,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalLabel,
                  style: TextStyle(
                    fontSize: AppDimensions.textMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  totalValue,
                  style: TextStyle(
                    fontSize: AppDimensions.textLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.lg),
            _ReportSection(
              title: context.tr(AppKeys.dailyReport),
              report: daily,
              localeCode: localeCode,
            ),
            SizedBox(height: AppDimensions.md),
            _ReportSection(
              title: context.tr(AppKeys.monthlyReport),
              report: monthly,
              localeCode: localeCode,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final SalesSectionReportEntity? report;
  final String localeCode;

  const _ReportSection({
    required this.title,
    required this.report,
    required this.localeCode,
  });

  @override
  Widget build(BuildContext context) {
    final data = report;
    if (data == null || data.ordersCount == 0) {
      return Text(
        '$title: ${context.tr(AppKeys.noOrders)}',
        style: TextStyle(
          fontSize: AppDimensions.textSm,
          color: AppColors.inkSoft,
        ),
      );
    }

    final dateFormat = DateFormat.yMd(localeCode).add_Hm();
    final lastOrderText = data.lastOrderAt == null
        ? context.tr(AppKeys.noOrders)
        : '${data.lastOrderId ?? ''} • ${dateFormat.format(data.lastOrderAt!)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppDimensions.textMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.sm),
        _StatRow(
          label: context.tr(AppKeys.ordersCount),
          value: data.ordersCount.toString(),
        ),
        _StatRow(
          label: context.tr(AppKeys.averageTicket),
          value: _formatAmount(data.averageTicket),
        ),
        _StatRow(
          label: context.tr(AppKeys.total),
          value: _formatAmount(data.total),
        ),
        _StatRow(label: context.tr(AppKeys.lastOrder), value: lastOrderText),
      ],
    );
  }

  String _formatAmount(double value) {
    final text = value.toStringAsFixed(6);
    final trimmed = text
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.textSm,
              color: AppColors.inkSoft,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppDimensions.textSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Table { items, orders, sales }

class _ExportRow extends StatelessWidget {
  final String label;
  final VoidCallback onCsv;
  final VoidCallback onJson;

  const _ExportRow({
    required this.label,
    required this.onCsv,
    required this.onJson,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.textMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: onCsv,
          child: Text(context.tr(AppKeys.exportCsv)),
        ),
        TextButton(
          onPressed: onJson,
          child: Text(context.tr(AppKeys.exportJson)),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.textMd,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? Colors.white : AppColors.ink,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: AppDimensions.textLg,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
