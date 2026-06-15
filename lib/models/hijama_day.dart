enum HijamaDayStatus {
  perfectSunnah,
  sunnahDateWeekendOverride,
  sunnahDateWednesdayWarning,
  recommended,
  avoid,
  neutral,
}

class HijamaDay {
  final DateTime gregorian;
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final HijamaDayStatus status;
  final bool isSunnahDate;

  const HijamaDay({
    required this.gregorian,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.status,
    required this.isSunnahDate,
  });

  String get statusKey {
    switch (status) {
      case HijamaDayStatus.perfectSunnah:
        return 'perfectSunnah';
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return 'sunnahDateWeekendOverride';
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return 'sunnahDateWednesdayWarning';
      case HijamaDayStatus.recommended:
        return 'recommended';
      case HijamaDayStatus.avoid:
        return 'avoid';
      case HijamaDayStatus.neutral:
        return 'neutral';
    }
  }
}
