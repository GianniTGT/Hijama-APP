// calendar_screen.dart
import 'package:flutter/material.dart';
import '../services/hijri_calendar_service.dart';
import '../services/localization_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late List<HijamaDayInfo> _days;

  @override
  void initState() {
    super.initState();
    _days = HijriCalendarService.getDaysForCurrentHijriMonth();
  }

  Color _colorForStatus(BuildContext ctx, HijamaDayStatus status) {
    switch (status) {
      case HijamaDayStatus.sunnahDay:
        return const Color(0xFF1A4A2E);
      case HijamaDayStatus.recommended:
        return const Color(0xFF2D7A4A);
      case HijamaDayStatus.avoid:
        return const Color(0xFF993C1D);
      case HijamaDayStatus.allowed:
        return Theme.of(ctx).colorScheme.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = localization;
    return Scaffold(
      appBar: AppBar(title: Text(t.t('calendar_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Legend
            Row(
              children: [
                _LegendDot(color: const Color(0xFF1A4A2E), label: t.t('calendar_legend_sunnah')),
                const SizedBox(width: 12),
                _LegendDot(color: const Color(0xFF2D7A4A), label: t.t('calendar_legend_recommended')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _days.length,
                itemBuilder: (ctx, i) {
                  final day = _days[i];
                  final isToday = day.gregorianDate.day == DateTime.now().day &&
                      day.gregorianDate.month == DateTime.now().month;
                  final bg = _colorForStatus(ctx, day.status);

                  return Container(
                    decoration: BoxDecoration(
                      color: bg.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(color: const Color(0xFF2D7A4A), width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.gregorianDate.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: day.isSunnahDay ? FontWeight.w700 : FontWeight.w400,
                            color: day.status == HijamaDayStatus.avoid
                                ? const Color(0xFF993C1D)
                                : Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${day.hijriDay}',
                          style: const TextStyle(fontSize: 9, color: Color(0xFF888780)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}
