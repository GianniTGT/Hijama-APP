import 'package:hijri/hijri_calendar.dart';
import '../models/hijama_day.dart';

class HijriCalendarService {
  static const List<int> sunnahDates = [17, 19, 21];

  // weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
  static const List<int> recommendedWeekdays = [1, 2, 4]; // Mo, Di, Do
  static const List<int> avoidWeekdays = [5, 6, 7];       // Fr, Sa, So

  HijamaDay evaluate(DateTime gregorianDate) {
    final hijri = HijriCalendar.fromDate(gregorianDate);
    final hijriDay = hijri.hDay;
    final weekday = gregorianDate.weekday;
    final isSunnah = sunnahDates.contains(hijriDay);

    HijamaDayStatus status;

    if (isSunnah && recommendedWeekdays.contains(weekday)) {
      status = HijamaDayStatus.perfectSunnah;
    } else if (isSunnah && avoidWeekdays.contains(weekday)) {
      status = HijamaDayStatus.sunnahDateWeekendOverride;
    } else if (isSunnah && weekday == 3) {
      status = HijamaDayStatus.sunnahDateWednesdayWarning;
    } else if (recommendedWeekdays.contains(weekday)) {
      status = HijamaDayStatus.recommended;
    } else if (avoidWeekdays.contains(weekday)) {
      status = HijamaDayStatus.avoid;
    } else {
      status = HijamaDayStatus.neutral;
    }

    return HijamaDay(
      gregorian: gregorianDate,
      hijriDay: hijri.hDay,
      hijriMonth: hijri.hMonth,
      hijriYear: hijri.hYear,
      status: status,
      isSunnahDate: isSunnah,
    );
  }

  List<HijamaDay> evaluateMonth(int year, int month) {
    final daysInMonth = DateTimeRange(
      start: DateTime(year, month, 1),
      end: DateTime(year, month + 1, 1),
    ).duration.inDays;

    return List.generate(daysInMonth, (i) {
      return evaluate(DateTime(year, month, i + 1));
    });
  }

  HijamaDay get today => evaluate(DateTime.now());

  List<DateTime> upcomingSunnahDays({int count = 3}) {
    final results = <DateTime>[];
    DateTime cursor = DateTime.now();
    int checked = 0;

    while (results.length < count && checked < 60) {
      final day = evaluate(cursor);
      if (day.isSunnahDate) results.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
      checked++;
    }
    return results;
  }

  String hijriMonthName(int month) {
    const names = [
      'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
      "Jumada al-Awwal", "Jumada al-Thani", 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
    ];
    return names[(month - 1).clamp(0, 11)];
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
  Duration get duration => end.difference(start);
}
