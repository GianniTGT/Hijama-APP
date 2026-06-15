import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../services/hijri_calendar_service.dart';
import '../services/localization_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _hYear;
  late int _hMonth;
  late List<HijamaDayInfo> _days;
  HijamaDayInfo? _selected;

  @override
  void initState() {
    super.initState();
    final today = HijriCalendar.now();
    _hYear = today.hYear;
    _hMonth = today.hMonth;
    _loadDays();
  }

  void _loadDays() {
    _days = HijriCalendarService.getDaysForHijriMonth(_hYear, _hMonth);
    _selected = null;
  }

  void _prevMonth() {
    setState(() {
      _hMonth--;
      if (_hMonth < 1) {
        _hMonth = 12;
        _hYear--;
      }
      _loadDays();
    });
  }

  void _nextMonth() {
    setState(() {
      _hMonth++;
      if (_hMonth > 12) {
        _hMonth = 1;
        _hYear++;
      }
      _loadDays();
    });
  }

  Color _bgColor(HijamaDayStatus status) {
    switch (status) {
      case HijamaDayStatus.perfectSunnah:
        return const Color(0xFF1A4A2E);
      case HijamaDayStatus.sunnahDateWeekendOverride:
        return const Color(0xFF5DCAA5);
      case HijamaDayStatus.sunnahDateWednesdayWarning:
        return const Color(0xFFC4922A);
      case HijamaDayStatus.recommended:
        return const Color(0xFF2D7A4A);
      case HijamaDayStatus.avoid:
        return const Color(0xFF993C1D);
      case HijamaDayStatus.allowed:
        return const Color(0xFF888780);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final lang = t.currentLanguage;
    final monthName = HijriCalendarService.formatHijriDate(
      HijriCalendar()
        ..hYear = _hYear
        ..hMonth = _hMonth
        ..hDay = 1,
      lang,
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.t('calendar_title'))),
      body: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Expanded(
                  child: Text(
                    '$_hYear H — $monthName',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: (d == 'Fr' || d == 'Sa' || d == 'So')
                                  ? const Color(0xFF993C1D)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _CalendarGrid(
                days: _days,
                onSelect: (d) => setState(() => _selected = d),
                selected: _selected,
                bgColor: _bgColor,
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _LegendItem(color: const Color(0xFF1A4A2E), label: t.t('calendar_legend_perfect')),
                _LegendItem(color: const Color(0xFF5DCAA5), label: t.t('calendar_legend_sunnah_override')),
                _LegendItem(color: const Color(0xFFC4922A), label: t.t('calendar_legend_sunnah_warning')),
                _LegendItem(color: const Color(0xFF2D7A4A), label: t.t('calendar_legend_recommended')),
                _LegendItem(color: const Color(0xFF993C1D), label: t.t('calendar_legend_avoid')),
                _LegendItem(color: const Color(0xFF888780), label: t.t('calendar_legend_allowed')),
              ],
            ),
          ),
          // Detail panel for selected day
          if (_selected != null)
            _DayDetail(day: _selected!, bgColor: _bgColor(_selected!.status)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.days,
    required this.onSelect,
    required this.selected,
    required this.bgColor,
  });

  final List<HijamaDayInfo> days;
  final ValueChanged<HijamaDayInfo> onSelect;
  final HijamaDayInfo? selected;
  final Color Function(HijamaDayStatus) bgColor;

  @override
  Widget build(BuildContext context) {
    // Fill leading empty cells so first day lands on correct weekday
    final firstWeekday = days.first.gregorianDate.weekday; // 1=Mon
    final leadingEmpties = firstWeekday - 1;
    final totalCells = leadingEmpties + days.length;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: rows * 7,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, i) {
        final dayIndex = i - leadingEmpties;
        if (dayIndex < 0 || dayIndex >= days.length) {
          return const SizedBox();
        }
        final day = days[dayIndex];
        final color = bgColor(day.status);
        final isToday = day.gregorianDate.year == DateTime.now().year &&
            day.gregorianDate.month == DateTime.now().month &&
            day.gregorianDate.day == DateTime.now().day;
        final isSelected = selected?.gregorianDate == day.gregorianDate;

        return GestureDetector(
          onTap: () => onSelect(day),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(isSelected ? 1.0 : 0.18),
              borderRadius: BorderRadius.circular(5),
              border: isToday
                  ? Border.all(color: const Color(0xFF2D7A4A), width: 1.5)
                  : isSelected
                      ? Border.all(color: color, width: 1.5)
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.gregorianDate.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: day.isSunnahDate
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${day.hijriDay}',
                  style: TextStyle(
                    fontSize: 8,
                    color: isSelected
                        ? Colors.white70
                        : const Color(0xFF888780),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.day, required this.bgColor});
  final HijamaDayInfo day;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final statusKey = day.status.name;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bgColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.gregorianDate.day}.${day.gregorianDate.month}.${day.gregorianDate.year}'
                  '  •  ${day.hijriDay}/${day.hijriMonth}/${day.hijriYear} H',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  t.t('status_detail_$statusKey'),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
