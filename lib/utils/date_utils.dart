import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _timeFormat = DateFormat('hh:mm a', 'es');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'es');
  static final DateFormat _fullFormat = DateFormat('dd MMM yyyy, hh:mm a', 'es');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM', 'es');
  static final DateFormat _friendlyFormat = DateFormat('EEEE d \'de\' MMMM', 'es');

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatFull(DateTime dt) => _fullFormat.format(dt);
  static String formatDayMonth(DateTime dt) => _dayMonthFormat.format(dt);
  static String formatFriendly(DateTime dt) {
    final s = _friendlyFormat.format(dt);
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt, [DateTime? ahora]) => isSameDay(dt, ahora ?? DateTime.now());

  /// Semana que empieza el lunes y termina el domingo, sin fechas futuras.
  static bool isThisWeek(DateTime dt, [DateTime? ahora]) {
    final now = ahora ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return !dt.isBefore(start) && dt.isBefore(end);
  }

  static bool isThisMonth(DateTime dt, [DateTime? ahora]) {
    final now = ahora ?? DateTime.now();
    return dt.year == now.year && dt.month == now.month;
  }

  static DateTime normalizeDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static String textoEnLocal(int dias) {
    if (dias <= 0) return 'Llegó hoy';
    if (dias == 1) return 'Lleva 1 día en el local';
    return 'Lleva $dias días en el local';
  }
}
