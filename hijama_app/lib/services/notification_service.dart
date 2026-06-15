import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'hijri_calendar_service.dart';

/// Benachrichtigungs-Texte pro Status und Sprache.
/// Jeder Status bekommt einen eigenen Ton und Text.
class _NotificationContent {
  final String title;
  final String body;
  const _NotificationContent(this.title, this.body);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _baseId = 1000;
  static const String _channelId   = 'hijama_reminders';
  static const String _channelName = 'Hijama Erinnerungen';

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  /// Plant Benachrichtigungen für alle kommenden benachrichtigungswürdigen Tage.
  /// Texte unterscheiden sich je nach [HijamaDayStatus].
  static Future<void> scheduleUpcomingReminders({
    required String langCode,
    int daysToSchedule = 5,
  }) async {
    await cancelAllReminders();

    final upcoming = HijriCalendarService.getUpcomingNotifiableDays(
        count: daysToSchedule);

    for (int i = 0; i < upcoming.length; i++) {
      final day = upcoming[i];
      final content = _buildContent(day, langCode);

      final scheduledDate = tz.TZDateTime(
        tz.local,
        day.gregorianDate.year,
        day.gregorianDate.month,
        day.gregorianDate.day,
        7, 0, // 07:00 Uhr morgens
      );

      if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        await _plugin.zonedSchedule(
          _baseId + i,
          content.title,
          content.body,
          scheduledDate,
          _buildDetails(importance: _importanceFor(day.status)),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> cancelAllReminders() async {
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(_baseId + i);
    }
  }

  // ─── Inhalt je Status ──────────────────────────────────────────────────

  static _NotificationContent _buildContent(
      HijamaDayInfo day, String lang) {
    switch (day.status) {

      // 🟢🟢 Perfekter Tag
      case HijamaDayStatus.perfectSunnah:
        return _NotificationContent(
          _t(lang,
            de: '🌙 Perfekter Hijama-Tag heute!',
            en: '🌙 Perfect Hijama day today!',
            sq: '🌙 Ditë e përsosur e Hixhames sot!',
            ar: '🌙 يوم الحجامة المثالي اليوم!'),
          _t(lang,
            de: 'Heute ist der ${day.hijriDay}. Hidschri '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}) — '
                'perfekte Kombination aus Sunnah-Datum und Wochentag.',
            en: 'Today is the ${day.hijriDay}th Hijri '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}) — '
                'perfect combination of Sunnah date and weekday.',
            sq: 'Sot është ${day.hijriDay} Hixhri '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}) — '
                'kombinim i përsosur i datës dhe ditës.',
            ar: 'اليوم ${_toAr(day.hijriDay)} هجري '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}) — '
                'الجمع المثالي بين تاريخ السنة ويوم الأسبوع.'),
        );

      // 🟢 Sunnah-Datum, aber Fr/Sa/So
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return _NotificationContent(
          _t(lang,
            de: '🌙 Sunnah-Tag: ${day.hijriDay}. Hidschri',
            en: '🌙 Sunnah day: ${day.hijriDay}th Hijri',
            sq: '🌙 Ditë Sunneti: ${day.hijriDay} Hixhri',
            ar: '🌙 يوم السنة: ${_toAr(day.hijriDay)} هجري'),
          _t(lang,
            de: 'Heute ist der ${day.hijriDay}. Hidschri '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}). '
                'Das Sunnah-Datum hat Vorrang — Hijama ist erlaubt und segensreich.',
            en: 'Today is the ${day.hijriDay}th Hijri '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}). '
                'The Sunnah date takes precedence — Hijama is permitted and blessed.',
            sq: 'Sot është ${day.hijriDay} Hixhri '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}). '
                'Data e Sunnetit ka përparësi — hixhameja është e lejuar dhe e bekuar.',
            ar: 'اليوم ${_toAr(day.hijriDay)} هجري '
                '(${_weekdayName(day.gregorianDate.weekday, lang)}). '
                'تاريخ السنة له الأولوية — الحجامة مباحة ومباركة.'),
        );

      // 🟠 Sunnah-Datum, aber Mittwoch
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return _NotificationContent(
          _t(lang,
            de: '⚠️ Sunnah-Tag (Mittwoch) — mit Vorsicht',
            en: '⚠️ Sunnah day (Wednesday) — with caution',
            sq: '⚠️ Ditë Sunneti (e mërkurë) — me kujdes',
            ar: '⚠️ يوم السنة (الأربعاء) — بحذر'),
          _t(lang,
            de: 'Heute ist der ${day.hijriDay}. Hidschri, aber ein Mittwoch. '
                'Hadithe raten zur Vorsicht am Mittwoch. '
                'Wenn möglich auf den ${day.hijriDay == 17 ? 19 : day.hijriDay == 19 ? 21 : 17}. ausweichen.',
            en: 'Today is the ${day.hijriDay}th Hijri, but a Wednesday. '
                'Hadiths advise caution on Wednesdays. '
                'If possible, prefer the ${day.hijriDay == 17 ? 19 : day.hijriDay == 19 ? 21 : 17}th instead.',
            sq: 'Sot është ${day.hijriDay} Hixhri, por e mërkurë. '
                'Hadithet këshillojnë kujdes të mërkurën. '
                'Nëse është e mundur, prefer ${day.hijriDay == 17 ? 19 : day.hijriDay == 19 ? 21 : 17}.',
            ar: 'اليوم ${_toAr(day.hijriDay)} هجري لكنه الأربعاء. '
                'تحذّر الأحاديث من الأربعاء. '
                'إن أمكن، يُستحسن تفضيل ${_toAr(day.hijriDay == 17 ? 19 : day.hijriDay == 19 ? 21 : 17)}.'),
        );

      // Andere (recommended etc.) — werden aktuell nicht benachrichtigt
      default:
        return _NotificationContent('Hijama', '');
    }
  }

  static Importance _importanceFor(HijamaDayStatus status) {
    switch (status) {
      case HijamaDayStatus.perfectSunnah:
        return Importance.high;
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return Importance.defaultImportance;
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return Importance.defaultImportance;
      default:
        return Importance.low;
    }
  }

  static NotificationDetails _buildDetails({
      required Importance importance}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId, _channelName,
        channelDescription: 'Hijama Sunnah-Tag Erinnerungen',
        importance: importance,
        priority: importance == Importance.high ? Priority.high : Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      ),
    );
  }

  // ─── Hilfsfunktionen ───────────────────────────────────────────────────

  static String _t(String lang,
      {required String de, required String en,
       required String sq, required String ar}) {
    switch (lang) {
      case 'en': return en;
      case 'sq': return sq;
      case 'ar': return ar;
      default:   return de;
    }
  }

  static String _weekdayName(int weekday, String lang) {
    const de = ['', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
    const en = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const sq = ['', 'e hënë', 'e martë', 'e mërkurë', 'e enjte', 'e premte', 'e shtunë', 'e diel'];
    const ar = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    switch (lang) {
      case 'en': return en[weekday];
      case 'sq': return sq[weekday];
      case 'ar': return ar[weekday];
      default:   return de[weekday];
    }
  }

  static String _toAr(int n) {
    const w = '0123456789';
    const a = '٠١٢٣٤٥٦٧٨٩';
    return n.toString().split('').map((c) {
      final i = w.indexOf(c); return i >= 0 ? a[i] : c;
    }).join();
  }
}
