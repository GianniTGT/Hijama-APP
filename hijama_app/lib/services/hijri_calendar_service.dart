import 'package:hijri/hijri_calendar.dart';

/// 5-stufiges Ampel-System nach Fiqh-Priorisierung der Gelehrten.
///
/// Theologische Grundlage:
/// - Die Monatsdaten 17/19/21 (Hidschri) haben grundsätzlich Vorrang
///   über die Wochentags-Makruh-Regel (Freitag/Samstag/Sonntag).
/// - Ausnahme: Mittwoch ist besonders problematisch (spezifische Hadithe
///   warnen vor Krankheiten am Mittwoch) — gilt auch an Sunnah-Daten.
/// - Perfekte Kombination: Sunnah-Datum (17/19/21) + guter Wochentag (Mo/Di/Do)
enum HijamaDayStatus {
  /// DUNKELGRÜN — Perfekte Kombination
  /// 17/19/21 Hijri UND Montag/Dienstag/Donnerstag
  /// → Benachrichtigung senden, höchste Empfehlung
  perfectSunnah,

  /// HELLGRÜN — Guter Sunnah-Tag mit leichter Einschränkung
  /// 17/19/21 Hijri, aber Freitag/Samstag/Sonntag
  /// → Erlaubt! Datum hat Vorrang. Benachrichtigung mit Hinweis senden.
  sunnahDateWeekendOverride,

  /// ORANGE — Vorsicht: Sunnah-Datum trifft Mittwoch
  /// 17/19/21 Hijri, aber Mittwoch
  /// → Warnung. Wenn möglich auf anderen Sunnah-Tag ausweichen.
  sunnahDateWednesdayWarning,

  /// BLAU/NORMAL — Empfohlener Wochentag, kein Sunnah-Datum
  /// Montag/Dienstag/Donnerstag, aber kein spezieller Hijri-Tag
  recommended,

  /// GRAU — Erlaubt, keine besondere Empfehlung
  /// Dienstag/Mittwoch oder sonstige Tage ohne Sunnah-Datum
  allowed,

  /// ROT/GRAU — Besser meiden
  /// Freitag/Samstag/Sonntag ohne Sunnah-Datum
  avoid,
}

/// Erweiterung: Menschenlesbare Informationen zu jedem Status
extension HijamaDayStatusInfo on HijamaDayStatus {
  /// Farb-Code für die UI (Hex-Wert als String)
  String get colorHex {
    switch (this) {
      case HijamaDayStatus.perfectSunnah:
        return '#1A4A2E'; // Dunkelgrün
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return '#5DCAA5'; // Hellgrün/Türkis
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return '#C4922A'; // Orange/Gold
      case HijamaDayStatus.recommended:
        return '#2D7A4A'; // Mittelgrün
      case HijamaDayStatus.allowed:
        return '#888780'; // Grau
      case HijamaDayStatus.avoid:
        return '#993C1D'; // Rot
    }
  }

  /// Soll eine Benachrichtigung gesendet werden?
  bool get shouldNotify {
    switch (this) {
      case HijamaDayStatus.perfectSunnah:
        return true;  // Ja — perfekter Tag
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return true;  // Ja — Datum hat Vorrang, aber mit Hinweis
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return true;  // Ja — aber mit Warnhinweis
      case HijamaDayStatus.recommended:
        return false; // Optional — kann der User einstellen
      case HijamaDayStatus.allowed:
        return false;
      case HijamaDayStatus.avoid:
        return false;
    }
  }

  /// Ist es ein Sunnah-Datum (17/19/21)?
  bool get isSunnahDate {
    return this == HijamaDayStatus.perfectSunnah ||
           this == HijamaDayStatus.sunnahDateWeekendOverride ||
           this == HijamaDayStatus.sunnahDateWednesdayWarning;
  }

  /// Anzeigestufe für die Ampel (1=beste, 6=schlechteste)
  int get priority {
    switch (this) {
      case HijamaDayStatus.perfectSunnah:               return 1;
      case HijamaDayStatus.sunnahDateWeekendOverride:   return 2;
      case HijamaDayStatus.recommended:                 return 3;
      case HijamaDayStatus.sunnahDateWednesdayWarning:  return 4;
      case HijamaDayStatus.allowed:                     return 5;
      case HijamaDayStatus.avoid:                       return 6;
    }
  }
}

class HijriCalendarService {
  // ─── Konstanten ───────────────────────────────────────────────────────────

  /// Die drei Sunnah-Tage des Monats nach dem Hadith (Abu Dawud, Ibn Majah)
  static const List<int> sunnahHijriDays = [17, 19, 21];

  /// Weitere empfohlene Hijri-Tage (ungerade Tage der letzten Monatshälfte)
  static const List<int> recommendedHijriDays = [15, 16, 18, 20, 22, 23, 25, 27];

  /// Makruh-Wochentage: Fr=5, Sa=6, So=7 (Dart: 1=Mo … 7=So)
  static const List<int> avoidWeekdays = [5, 6, 7];

  /// Bevorzugte Wochentage: Mo=1, Di=2, Do=4
  static const List<int> preferredWeekdays = [1, 2, 4];

  /// Mittwoch = 3 — spezifische Hadithe warnen vor Krankheiten am Mittwoch
  static const int wednesday = 3;

  // ─── Kernlogik: Ampel-Berechnung ──────────────────────────────────────────

  /// Berechnet den [HijamaDayStatus] für ein gegebenes gregorianisches Datum.
  ///
  /// Priorität der Regeln (nach Fiqh-Konsens):
  ///   1. Ist es ein Sunnah-Datum (17/19/21 Hijri)?
  ///      a. + Mo/Di/Do → perfectSunnah             🟢🟢
  ///      b. + Fr/Sa/So → sunnahDateWeekendOverride  🟢  (Datum hat Vorrang)
  ///      c. + Mittwoch → sunnahDateWednesdayWarning 🟠  (Warnung)
  ///      d. + Sonstige → perfectSunnah              🟢  (Di/Neutraltag)
  ///   2. Kein Sunnah-Datum:
  ///      a. Mittwoch    → allowed (mit Hinweis)
  ///      b. Fr/Sa/So    → avoid
  ///      c. Mo/Di/Do    → recommended
  ///      d. Sonstiges   → allowed
  static HijamaDayStatus getDayStatus(DateTime date) {
    final hijri = fromGregorian(date);
    final weekday = date.weekday; // 1=Mo, 2=Di, 3=Mi, 4=Do, 5=Fr, 6=Sa, 7=So

    // ── Regel 1: Sunnah-Datum (17/19/21) ──────────────────────────────────
    if (sunnahHijriDays.contains(hijri.hDay)) {
      if (weekday == wednesday) {
        // Mittwoch + Sunnah-Datum → Warnung, aber erlaubt
        return HijamaDayStatus.sunnahDateWednesdayWarning;
      }
      if (avoidWeekdays.contains(weekday)) {
        // Fr/Sa/So + Sunnah-Datum → Datum hat Vorrang nach Fiqh
        // Erlaubt & segensreich, aber mit erklärendem Hinweis
        return HijamaDayStatus.sunnahDateWeekendOverride;
      }
      // Mo/Di/Do oder neutraler Wochentag + Sunnah-Datum → perfekt
      return HijamaDayStatus.perfectSunnah;
    }

    // ── Regel 2: Kein Sunnah-Datum ────────────────────────────────────────
    if (weekday == wednesday) {
      // Mittwoch ohne Sunnah-Datum → allowed mit Vorsicht
      return HijamaDayStatus.allowed;
    }
    if (avoidWeekdays.contains(weekday)) {
      // Fr/Sa/So → meiden
      return HijamaDayStatus.avoid;
    }
    if (preferredWeekdays.contains(weekday)) {
      // Mo/Di/Do → empfohlen
      return HijamaDayStatus.recommended;
    }

    return HijamaDayStatus.allowed;
  }

  // ─── Hilfsmethoden ────────────────────────────────────────────────────────

  static HijriCalendar get todayHijri => HijriCalendar.now();

  static HijriCalendar fromGregorian(DateTime date) =>
      HijriCalendar.fromDate(date);

  /// Alle Tage des aktuellen Hijri-Monats mit ihrem Status.
  static List<HijamaDayInfo> getDaysForCurrentHijriMonth() {
    final today = HijriCalendar.now();
    return getDaysForHijriMonth(today.hYear, today.hMonth);
  }

  /// Alle Tage eines bestimmten Hijri-Jahres/Monats.
  static List<HijamaDayInfo> getDaysForHijriMonth(int hYear, int hMonth) {
    final List<HijamaDayInfo> days = [];
    final daysInMonth = HijriCalendar.getDaysInMonth(hYear, hMonth);

    for (int day = 1; day <= daysInMonth; day++) {
      final hijri = HijriCalendar()
        ..hYear = hYear
        ..hMonth = hMonth
        ..hDay = day;
      final gregorianDate = hijri.hijriToGregorian(hYear, hMonth, day);
      final status = getDayStatus(gregorianDate);
      days.add(HijamaDayInfo(
        hijriDay: day,
        hijriMonth: hMonth,
        hijriYear: hYear,
        gregorianDate: gregorianDate,
        status: status,
      ));
    }
    return days;
  }

  /// Nächste [count] Tage, für die eine Benachrichtigung gesendet werden soll.
  /// Gibt nur Tage zurück, bei denen [HijamaDayStatus.shouldNotify] true ist.
  static List<HijamaDayInfo> getUpcomingNotifiableDays({int count = 5}) {
    final List<HijamaDayInfo> result = [];
    DateTime cursor = DateTime.now().add(const Duration(days: 1));
    int maxSearch = 90;

    while (result.length < count && maxSearch > 0) {
      final status = getDayStatus(cursor);
      if (status.shouldNotify) {
        final hijri = fromGregorian(cursor);
        result.add(HijamaDayInfo(
          hijriDay: hijri.hDay,
          hijriMonth: hijri.hMonth,
          hijriYear: hijri.hYear,
          gregorianDate: cursor,
          status: status,
        ));
      }
      cursor = cursor.add(const Duration(days: 1));
      maxSearch--;
    }
    return result;
  }

  /// Nächste [count] empfehlenswerte Tage (für das Kalender-Strip auf der Heute-Seite).
  /// Schließt auch recommended-Tage ein (nicht nur Sunnah-Daten).
  static List<HijamaDayInfo> getUpcomingGoodDays({int count = 7}) {
    final List<HijamaDayInfo> result = [];
    DateTime cursor = DateTime.now();
    int maxSearch = 90;

    while (result.length < count && maxSearch > 0) {
      final status = getDayStatus(cursor);
      if (status.priority <= 3) { // perfectSunnah, weekendOverride, recommended
        final hijri = fromGregorian(cursor);
        result.add(HijamaDayInfo(
          hijriDay: hijri.hDay,
          hijriMonth: hijri.hMonth,
          hijriYear: hijri.hYear,
          gregorianDate: cursor,
          status: status,
        ));
      }
      cursor = cursor.add(const Duration(days: 1));
      maxSearch--;
    }
    return result;
  }

  /// Formatiert ein Hijri-Datum als lesbaren String.
  static String formatHijriDate(HijriCalendar hijri, String languageCode) {
    final monthName = _getHijriMonthName(hijri.hMonth, languageCode);
    if (languageCode == 'ar') {
      return '${_toArabicNumerals(hijri.hDay)} $monthName ${_toArabicNumerals(hijri.hYear)}';
    }
    return '${hijri.hDay}. $monthName ${hijri.hYear}';
  }

  /// Tage bis zum nächsten benachrichtigungswürdigen Tag.
  static int daysUntilNextNotifiableDay() {
    DateTime cursor = DateTime.now().add(const Duration(days: 1));
    for (int i = 0; i < 60; i++) {
      if (getDayStatus(cursor).shouldNotify) return i + 1;
      cursor = cursor.add(const Duration(days: 1));
    }
    return -1;
  }

  static String _toArabicNumerals(int n) {
    const western = '0123456789';
    const arabic  = '٠١٢٣٤٥٦٧٨٩';
    return n.toString().split('').map((c) {
      final i = western.indexOf(c);
      return i >= 0 ? arabic[i] : c;
    }).join();
  }

  static String _getHijriMonthName(int month, String lang) {
    const names = [
      '', 'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Akhir",
      "Jumada al-Ula", "Jumada al-Akhira", "Rajab", "Sha'ban",
      'Ramadan', 'Shawwal', "Dhul-Qi'dah", 'Dhul-Hijjah',
    ];
    const ar = [
      '', 'مُحَرَّم', 'صَفَر', 'رَبِيع الأَوَّل', 'رَبِيع الآخِر',
      'جُمَادَى الأُولَى', 'جُمَادَى الآخِرَة', 'رَجَب', 'شَعْبَان',
      'رَمَضَان', 'شَوَّال', 'ذُو القَعْدَة', 'ذُو الحِجَّة',
    ];
    return lang == 'ar' ? ar[month] : names[month];
  }
}

/// Datensatz für einen einzelnen Tag mit Hijama-Relevanz.
class HijamaDayInfo {
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final DateTime gregorianDate;
  final HijamaDayStatus status;

  const HijamaDayInfo({
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.gregorianDate,
    required this.status,
  });

  bool get isPerfect   => status == HijamaDayStatus.perfectSunnah;
  bool get isSunnahDate => status.isSunnahDate;
  bool get shouldNotify => status.shouldNotify;

  @override
  String toString() =>
      'HijamaDayInfo($hijriDay/$hijriMonth/$hijriYear = '
      '${gregorianDate.toIso8601String().substring(0, 10)}, $status)';
}
