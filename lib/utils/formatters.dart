import 'package:intl/intl.dart';

/// Philippine Peso currency & date formatting shared across BLOOM.
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final NumberFormat _currencyCompact = NumberFormat.compactCurrency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 1,
  );

  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _mediumDate = DateFormat('MMM d');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _monthShort = DateFormat('MMM');

  static String currency(num value) => _currency.format(value);

  static String currencyCompact(num value) => _currencyCompact.format(value);

  static String signedCurrency(num value, {required bool isPositive}) {
    final formatted = _currency.format(value.abs());
    return isPositive ? '+$formatted' : '-$formatted';
  }

  static String shortDate(DateTime date) => _shortDate.format(date);

  static String mediumDate(DateTime date) => _mediumDate.format(date);

  static String monthYear(DateTime date) => _monthYear.format(date);

  static String monthShort(DateTime date) => _monthShort.format(date);

  static String percent(double fraction, {int decimals = 0}) {
    return '${(fraction * 100).toStringAsFixed(decimals)}%';
  }

  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';
    return shortDate(date);
  }
}
