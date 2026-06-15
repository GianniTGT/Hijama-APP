# Hijama Guide — Flutter App

Islamic cupping (Hijama) companion app following the Sunnah.
4 languages: German (DE), English (EN), Albanian (SQ), Arabic (AR/RTL)

---

## Projektstruktur

```
hijama_guide/
├── lib/
│   ├── main.dart                        ← App-Einstiegspunkt, Firebase-Init
│   ├── screens/
│   │   ├── home_screen.dart             ← Bottom Navigation (6 Tabs)
│   │   ├── today_screen.dart            ← Dashboard: Datum, Status, Hadithe
│   │   ├── calendar_screen.dart         ← Hijri-Kalender mit Farbmarkierung
│   │   └── other_screens.dart           ← Guide, Points, Hadith, Diary, Onboarding
│   ├── services/
│   │   ├── hijri_calendar_service.dart  ← Kernlogik: Hijri-Berechnung, Sunnah-Tage
│   │   ├── localization_service.dart    ← JSON-Laden, Sprachumschaltung, RTL
│   │   ├── diary_service.dart           ← Firestore CRUD für Tagebuch
│   │   └── notification_service.dart   ← Push-Benachrichtigungen (17/19/21 Hijri)
│   ├── models/                          ← (DiaryEntry in diary_service.dart)
│   ├── widgets/
│   │   └── hadith_card.dart             ← HadithCard, DayStatusBadge, Strips, Rows
│   └── utils/
│       ├── app_theme.dart               ← Grün/Gold Theme, Light+Dark, HijamaColors
│       └── app_state.dart               ← ChangeNotifier: Sprache, FirstLaunch
├── assets/
│   ├── l10n/
│   │   ├── de.json                      ← Alle Texte auf Deutsch
│   │   ├── en.json                      ← Alle Texte auf Englisch
│   │   ├── sq.json                      ← Alle Texte auf Albanisch
│   │   └── ar.json                      ← Alle Texte auf Arabisch (RTL)
│   ├── images/
│   │   └── body_points.png              ← (noch hinzufügen)
│   └── fonts/
│       └── ScheherazadeNew-Regular.ttf  ← Arabische Schriftart (herunterladen)
└── pubspec.yaml
```

---

## Setup

### 1. Flutter installieren
```bash
flutter --version   # mind. 3.0.0
```

### 2. Dependencies installieren
```bash
flutter pub get
```

### 3. Firebase einrichten
```bash
# Firebase CLI installieren
npm install -g firebase-tools
firebase login

# FlutterFire CLI
dart pub global activate flutterfire_cli

# Firebase-Projekt konfigurieren (erstellt google-services.json / GoogleService-Info.plist)
flutterfire configure
```

### 4. Arabische Schriftart
Scheherazade New von Google Fonts herunterladen:
https://fonts.google.com/specimen/Scheherazade+New
→ Datei in `assets/fonts/ScheherazadeNew-Regular.ttf` speichern.

### 5. App starten
```bash
flutter run
```

---

## Sunnah-Tage Logik (hijri_calendar_service.dart)

| Priorität | Bedingung | Status |
|-----------|-----------|--------|
| 1 | Hijri-Tag 17, 19 oder 21 | `sunnahDay` ✓✓ |
| 2 | Mo/Di/Do + empfohlener Hijri-Tag (15–23 odd) | `recommended` ✓ |
| 3 | Fr/Sa/So | `avoid` ✗ |
| 4 | Sonstiges | `allowed` ~ |

---

## Firebase Firestore Schema

```
users/{uid}/
  diary/{entryId}
    date: Timestamp
    hijriDay: int
    hijriMonth: int
    hijriYear: int
    pointsUsed: string[]   // ["kahil", "akhday_left", ...]
    notes: string
    createdAt: Timestamp
```

---

## Nächste Schritte (Phase 2)

- [ ] Firebase Authentication (Google + Apple Sign-In) vollständig implementieren
- [ ] Diary Screen vollständig (Sitzung hinzufügen, Verlauf anzeigen, nächster Termin)
- [ ] Körperpunkte-Bild mit interaktiven Markierungen (CustomPainter)
- [ ] AppState für Sprachumschaltung vollständig verdrahten (Provider + Rebuild)
- [ ] Onboarding: Sprache wählen → HomeScreen
- [ ] Monatliche Benachrichtigungen automatisch planen (1. jedes Hijri-Monats)
- [ ] Play Store Assets: Icon, Screenshots, Beschreibung (4 Sprachen)
- [ ] iOS: Info.plist Notification-Permissions, GoogleService-Info.plist

---

## Pakete (pubspec.yaml)

| Paket | Zweck |
|-------|-------|
| `hijri` | Hijri ↔ Gregorianisch Konversion |
| `firebase_core` + `firebase_auth` | Authentication |
| `cloud_firestore` | Tagebuch-Sync (Offline-First) |
| `firebase_messaging` | FCM Push-Notifications |
| `flutter_local_notifications` | Lokale Sunnah-Tag-Erinnerungen |
| `provider` | State Management (Sprache, Auth) |
| `shared_preferences` | Sprach-Einstellung lokal speichern |
| `google_fonts` | Nunito Sans Schriftart |
| `intl` | Datums-Formatierung |
