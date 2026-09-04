import 'package:intl/intl.dart';

abstract class AppDateUtils {
  AppDateUtils._();

  static String formatDuration(Duration duration) {
    final isNegative = duration.isNegative;
    final absDuration = duration.abs();
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    final hours = twoDigits(absDuration.inHours);
    final minutes = twoDigits(absDuration.inMinutes.remainder(60));
    final seconds = twoDigits(absDuration.inSeconds.remainder(60));
    
    final formatted = "$hours:$minutes:$seconds";
    return isNegative ? "-$formatted" : formatted;
  }

  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}