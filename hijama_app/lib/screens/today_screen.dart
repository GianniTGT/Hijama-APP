import 'package:flutter/material.dart';
import '../services/hijri_calendar_service.dart';
import '../services/localization_service.dart';
import '../utils/app_theme.dart';
import '../widgets/hadith_card.dart';
import '../widgets/day_status_badge.dart';
import '../widgets/upcoming_days_strip.dart';
import '../widgets/rule_row.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final hijri = HijriCalendarService.todayHijri;
    final today = DateTime.now();
    final status = HijriCalendarService.getDayStatus(today);
    final upcoming = HijriCalendarService.getUpcomingGoodDays(count: 7);
    final hadiths = t.getHadiths();
    final colors = Theme.of(context).extension<HijamaColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('app_name')),
        actions: [
          // Language selector in top-right
          _LanguageSelector(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                HijriCalendarService.formatHijriDate(
                                    hijri, t.currentLanguage),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${today.day}.${today.month}.${today.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ),
                        DayStatusBadge(status: status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Daily Hadith
            if (hadiths.isNotEmpty)
              HadithCard(hadith: hadiths[0], compact: true),
            const SizedBox(height: 16),

            // Upcoming good days strip
            Text(
              t.t('today_best_days'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
            const SizedBox(height: 8),
            UpcomingDaysStrip(days: upcoming),
            const SizedBox(height: 16),

            // Key rules
            Text(
              t.t('settings_notifications'), // reuse label as section header placeholder
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
            const SizedBox(height: 8),
            RuleRow(icon: Icons.schedule, text: t.t('guide_before_steps') is List ? t.t('today_hijri_date') : t.t('today_hijri_date')),
            // Rules are loaded from the guide steps; simplified here
            Card(
              child: Column(
                children: [
                  _RuleItem(icon: Icons.schedule_outlined, text: t.t('diary_no_entries').isNotEmpty ? _rule1(t) : ''),
                  const Divider(height: 1),
                  _RuleItem(icon: Icons.nightlight_outlined, text: _rule2(t)),
                  const Divider(height: 1),
                  _RuleItem(icon: Icons.water_drop_outlined, text: _rule3(t)),
                  const Divider(height: 1),
                  _RuleItem(icon: Icons.favorite_outline, text: _rule4(t)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rule1(LocalizationService t) {
    final steps = t.tList('guide_before_steps');
    return steps.length > 1 ? steps[1]['title'] as String : '';
  }

  String _rule2(LocalizationService t) {
    final steps = t.tList('guide_before_steps');
    return steps.isNotEmpty ? steps[0]['title'] as String : '';
  }

  String _rule3(LocalizationService t) {
    final hadiths = t.getHadiths();
    return hadiths.length > 3 ? hadiths[3]['topic'] ?? '' : '';
  }

  String _rule4(LocalizationService t) {
    final points = t.getCuppingPoints();
    return points.isNotEmpty ? points[0].name : '';
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (code) {
        // Handled via AppState in production
      },
      itemBuilder: (_) => LocalizationService.supportedLanguages
          .map((l) => PopupMenuItem(
                value: l.code,
                child: Text(l.nativeLabel),
              ))
          .toList(),
    );
  }
}
