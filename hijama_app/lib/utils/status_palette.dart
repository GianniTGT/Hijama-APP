import 'package:flutter/material.dart';
import '../services/hijri_calendar_service.dart';

/// Visuelle Darstellung eines [HijamaDayStatus].
///
/// Einzige Quelle der Wahrheit für Kalenderzellen, Legende und Badges — so
/// können eine Zelle und ihr Legendenkästchen nicht auseinanderlaufen.
///
/// Wichtig: Die Deckkraft steigt mit der Priorität des Status. Der beste Tag
/// des Monats ist damit auch der auffälligste auf dem Bildschirm.
class HijamaStatusStyle {
  const HijamaStatusStyle({
    required this.color,
    required this.fillOpacity,
    this.outlined = false,
  });

  /// Farbton, der die Bedeutung trägt.
  final Color color;

  /// Wie stark [color] eine Zelle füllt.
  final double fillOpacity;

  /// Sunnah-Daten (17/19/21) bekommen zusätzlich eine Kontur, damit sie als
  /// Gruppe lesbar sind — unabhängig vom Wochentag.
  final bool outlined;

  static HijamaStatusStyle of(HijamaDayStatus status) {
    switch (status) {
      case HijamaDayStatus.perfectSunnah:
        // Hellstes Grün + kräftigste Füllung: der beste Tag des Monats.
        return const HijamaStatusStyle(
          color: Color(0xFF3DBE74),
          fillOpacity: 0.42,
          outlined: true,
        );
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return const HijamaStatusStyle(
          color: Color(0xFF5DCAA5),
          fillOpacity: 0.30,
          outlined: true,
        );
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return const HijamaStatusStyle(
          color: Color(0xFFC4922A),
          fillOpacity: 0.30,
          outlined: true,
        );
      case HijamaDayStatus.recommended:
        return const HijamaStatusStyle(
          color: Color(0xFF2D7A4A),
          fillOpacity: 0.22,
        );
      case HijamaDayStatus.avoid:
        return const HijamaStatusStyle(
          color: Color(0xFF993C1D),
          fillOpacity: 0.22,
        );
      case HijamaDayStatus.allowed:
        return const HijamaStatusStyle(
          color: Color(0xFF888780),
          fillOpacity: 0.12,
        );
    }
  }

  /// Füllfarbe einer Kalenderzelle.
  Color get fill => color.withOpacity(fillOpacity);

  /// Übersetzungsschlüssel für die Kurzbezeichnung dieses Status.
  static String labelKey(HijamaDayStatus status) {
    switch (status) {
      case HijamaDayStatus.perfectSunnah:
        return 'status_perfect';
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return 'status_sunnah_weekend';
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return 'status_sunnah_wednesday';
      case HijamaDayStatus.recommended:
        return 'status_recommended';
      case HijamaDayStatus.allowed:
        return 'status_allowed';
      case HijamaDayStatus.avoid:
        return 'status_avoid';
    }
  }
}
