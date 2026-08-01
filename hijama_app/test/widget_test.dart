// Pure-Dart tests for the Hijri calendar core logic — no Firebase,
// no platform plugins, no network needed.

import 'package:flutter_test/flutter_test.dart';

import 'package:hijama_guide/services/hijri_calendar_service.dart';

void main() {
  test('a full Hijri month classifies every day', () {
    final days = HijriCalendarService.getDaysForHijriMonth(1448, 2);
    expect(days.length, greaterThanOrEqualTo(29));
    for (final day in days) {
      expect(day.hijriMonth, 2);
      expect(day.hijriYear, 1448);
    }
  });

  test('sunnah dates 17/19/21 get a sunnah status', () {
    final days = HijriCalendarService.getDaysForHijriMonth(1448, 2);
    for (final day in days.where((d) => [17, 19, 21].contains(d.hijriDay))) {
      expect(day.isSunnahDate, isTrue,
          reason: 'Hijri day ${day.hijriDay} must be a sunnah date');
    }
  });

  test('only sunnah-related statuses trigger notifications', () {
    expect(HijamaDayStatus.perfectSunnah.shouldNotify, isTrue);
    expect(HijamaDayStatus.sunnahDateWeekendOverride.shouldNotify, isTrue);
    expect(HijamaDayStatus.sunnahDateWednesdayWarning.shouldNotify, isTrue);
    expect(HijamaDayStatus.recommended.shouldNotify, isFalse);
    expect(HijamaDayStatus.allowed.shouldNotify, isFalse);
    expect(HijamaDayStatus.avoid.shouldNotify, isFalse);
  });
}
