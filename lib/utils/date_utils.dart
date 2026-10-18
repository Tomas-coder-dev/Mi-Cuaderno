import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _timeFormat = DateFormat('hh:mm a', 'es');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'es');
  static final DateFormat _fullFormat = DateFormat('dd MMM yyyy, hh:mm a', 'es');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM', 'es');

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatFull(DateTime dt) => _fullFormat.format(dt);
  static String formatDayMonth(DateTime dt) => _dayMonthFormat.format(dt);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  static bool isThisWeek(DateTime dt) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return dt.isAfter(startDay.subtract(const Duration(seconds: 1)));
  }

  static bool isThisMonth(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month;
  }

  static DateTime normalizeDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
