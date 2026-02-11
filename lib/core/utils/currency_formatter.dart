import 'package:intl/intl.dart';

class CurrencyFormatter {
  final NumberFormat _format;

  CurrencyFormatter(String locale)
    : _format = NumberFormat.currency(locale: locale, symbol: '');

  String format(double value) {
    return _format.format(value).trim();
  }
}
