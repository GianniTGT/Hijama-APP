// widgets/hadith_card.dart
import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/app_theme.dart';

class HadithCard extends StatelessWidget {
  const HadithCard({super.key, required this.hadith, this.compact = false});
  final HadithEntry hadith;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<HijamaColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: colors.hadithBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colors.gold, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hadith.arabic,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: compact ? 14 : 17,
              fontFamily: 'Scheherazade',
              height: 1.9,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hadith.translation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(
            hadith.source,
            style: TextStyle(fontSize: 11, color: colors.gold, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// widgets/day_status_badge.dart
class DayStatusBadge extends StatelessWidget {
  const DayStatusBadge({super.key, required this.status});
  final dynamic status; // HijamaDayStatus

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final colors = Theme.of(context).extension<HijamaColors>()!;

    Color bg; Color fg; String label;
    switch (status.toString()) {
      case 'HijamaDayStatus.sunnahDay':
        bg = colors.sunnahBadge; fg = colors.sunnahBadgeText;
        label = t.t('status_sunnah'); break;
      case 'HijamaDayStatus.recommended':
        bg = colors.sunnahBadge.withOpacity(0.7); fg = colors.sunnahBadgeText;
        label = t.t('status_recommended'); break;
      case 'HijamaDayStatus.avoid':
        bg = colors.avoidBadge; fg = colors.avoidBadgeText;
        label = t.t('status_avoid'); break;
      default:
        bg = Theme.of(context).colorScheme.surfaceVariant;
        fg = Theme.of(context).colorScheme.onSurfaceVariant;
        label = t.t('status_allowed');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// widgets/upcoming_days_strip.dart
import '../services/hijri_calendar_service.dart';

class UpcomingDaysStrip extends StatelessWidget {
  const UpcomingDaysStrip({super.key, required this.days});
  final List<HijamaDayInfo> days;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (ctx, i) {
          final day = days[i];
          final isToday = day.gregorianDate.day == DateTime.now().day;
          final color = day.isSunnahDay
              ? const Color(0xFF1A4A2E)
              : const Color(0xFFC4922A);

          return Container(
            width: 50,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday ? color : color.withOpacity(0.3),
                width: isToday ? 1.5 : 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${day.gregorianDate.day}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                    color: Theme.of(ctx).colorScheme.onSurface)),
                Text('${day.hijriDay}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF888780))),
                Container(
                  width: 5, height: 5, margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// widgets/rule_row.dart
class RuleRow extends StatelessWidget {
  const RuleRow({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
