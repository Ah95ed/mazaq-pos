import 'package:flutter/material.dart';

import '../../domain/entities/sales_report_entity.dart';
import '../../domain/entities/sales_summary_entity.dart';
import '../../domain/usecases/sales/get_sales_report.dart';
import '../../domain/usecases/sales/get_sales_summary.dart';

class SalesProvider extends ChangeNotifier {
  final GetSalesSummary getSalesSummary;
  final GetSalesReport getSalesReport;

  SalesProvider({required this.getSalesSummary, required this.getSalesReport});

  SalesSummaryEntity? _summary;
  SalesSummaryEntity? get summary => _summary;

  SalesReportEntity? _dailyReport;
  SalesReportEntity? get dailyReport => _dailyReport;

  SalesReportEntity? _monthlyReport;
  SalesReportEntity? get monthlyReport => _monthlyReport;

  Future<void> loadSummary() async {
    _summary = await getSalesSummary();
    notifyListeners();
  }

  Future<void> loadReports() async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(milliseconds: 1));

    _summary = await getSalesSummary();
    _dailyReport = await getSalesReport(start: dayStart, end: dayEnd);
    _monthlyReport = await getSalesReport(start: monthStart, end: monthEnd);
    notifyListeners();
  }
}
