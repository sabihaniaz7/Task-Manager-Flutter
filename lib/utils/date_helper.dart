import 'package:intl/intl.dart';

class DateHelper {
  static String formatDay(DateTime date) => DateFormat('d').format(date);
  static String formatMonth(DateTime date) => DateFormat('MMM').format(date);
  static String formatShort(DateTime date) => DateFormat('d MMM').format(date);
  static String formatRange(DateTime start, DateTime end) =>
      '${formatShort(start)} - ${formatShort(end)}';
}
