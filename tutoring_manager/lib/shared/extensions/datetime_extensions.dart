import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  // Formatting
  String toDisplayDate() => DateFormat('dd/MM/yyyy').format(this);
  String toDisplayTime() => DateFormat('HH:mm').format(this);
  String toDisplayDateTime() => DateFormat('dd/MM/yyyy HH:mm').format(this);
  String toApiDate() => DateFormat('yyyy-MM-dd').format(this);
  String toApiDateTime() => DateFormat('yyyy-MM-ddTHH:mm:ss').format(this);
  
  // Vietnamese day of week
  String toVietnameseDayOfWeek() {
    const days = {
      1: 'Thứ Hai',
      2: 'Thứ Ba',
      3: 'Thứ Tư',
      4: 'Thứ Năm',
      5: 'Thứ Sáu',
      6: 'Thứ Bảy',
      7: 'Chủ Nhật',
    };
    return days[weekday] ?? '';
  }
  
  // Relative time
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  
  // Age calculation
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
  
  // Start and end of day
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  
  // Start and end of week
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }
  
  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6)).endOfDay;
  }
  
  // Start and end of month
  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 1).subtract(const Duration(days: 1)).endOfDay;
  
  // Start and end of year
  DateTime get startOfYear => DateTime(year, 1, 1);
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);
  
  // Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
  
  // Check if same week
  bool isSameWeek(DateTime other) {
    final thisWeekStart = startOfWeek;
    final thisWeekEnd = endOfWeek;
    return other.isAfter(thisWeekStart.subtract(const Duration(seconds: 1))) &&
           other.isBefore(thisWeekEnd.add(const Duration(seconds: 1)));
  }
  
  // Check if same month
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
  
  // Check if same year
  bool isSameYear(DateTime other) {
    return year == other.year;
  }
  
  // Check if today
  bool get isToday => isSameDay(DateTime.now());
  
  // Check if yesterday
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));
  
  // Check if tomorrow
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));
  
  // Check if this week
  bool get isThisWeek => isSameWeek(DateTime.now());
  
  // Check if this month
  bool get isThisMonth => isSameMonth(DateTime.now());
  
  // Check if this year
  bool get isThisYear => isSameYear(DateTime.now());
  
  // Check if weekend
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;
  
  // Check if weekday
  bool get isWeekday => !isWeekend;
  
  // Add business days (skip weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;
    
    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) {
        addedDays++;
      }
    }
    
    return result;
  }
  
  // Get next business day
  DateTime get nextBusinessDay {
    DateTime result = add(const Duration(days: 1));
    while (!result.isWeekday) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }
  
  // Get previous business day
  DateTime get previousBusinessDay {
    DateTime result = subtract(const Duration(days: 1));
    while (!result.isWeekday) {
      result = result.subtract(const Duration(days: 1));
    }
    return result;
  }
}

extension StringDateExtensions on String {
  // Parse from display format
  DateTime? toDateFromDisplay() {
    try {
      return DateFormat('dd/MM/yyyy').parse(this);
    } catch (e) {
      return null;
    }
  }
  
  // Parse from API format
  DateTime? toDateFromApi() {
    try {
      return DateFormat('yyyy-MM-dd').parse(this);
    } catch (e) {
      return null;
    }
  }
  
  // Parse from API datetime format
  DateTime? toDateTimeFromApi() {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }
}
