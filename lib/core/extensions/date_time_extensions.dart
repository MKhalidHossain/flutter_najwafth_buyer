import 'package:intl/intl.dart';

extension DateTimeFormatX on DateTime {
  String get dayMonthYear => DateFormat.yMMMd().format(this);
  String get hourMinute => DateFormat.jm().format(this);
  String get dayMonthYearTime => DateFormat.yMMMd().add_jm().format(this);
}
