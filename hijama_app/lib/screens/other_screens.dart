// guide_screen.dart
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = localization;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.t('tab_guide')),
          bottom: TabBar(
            labelColor: const Color(0xFFF0D080),
            unselectedLabelColor: const Color(0xFF9FE1CB),
            indicatorColor: const Color(0xFFC4922A),
            tabs: [
              Tab(text: t.t('guide_before_title').split(' ').first),
              Tab(text: t.t('guide_during_title').split(' ').first),
              Tab(text: t.t('guide_after_title').split(' ').first),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StepList(stepsKey: 'guide_before_steps'),
            _StepList(stepsKey: 'guide_during_steps'),
            _StepList(stepsKey: 'guide_after_steps'),
          ],
        ),
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.stepsKey});
  final String stepsKey;

  @override
  Widget build(BuildContext context) {
    final steps = localization.tList(stepsKey);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (ctx, i) {
        final step = steps[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4EC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text('${i+1}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A4A2E))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step['title'] as String? ?? '',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(step['detail'] as String? ?? '',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(height: 1.5)),
                    ],
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

// points_screen.dart
class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final points = t.getCuppingPoints();
    final sunnahPoints = points.where((p) => p.isSunnah).toList();
    final otherPoints = points.where((p) => !p.isSunnah).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.t('tab_points'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.t('points_sunnah_title'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600, letterSpacing: 0.05,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 8),
          ...sunnahPoints.map((p) => _PointCard(point: p)),
          const SizedBox(height: 16),
          Text(t.t('points_other_title'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600, letterSpacing: 0.05,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 8),
          ...otherPoints.map((p) => _PointCard(point: p)),
        ],
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({required this.point});
  final CuppingPoint point;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: point.isSunnah ? const Color(0xFF2D7A4A) : const Color(0xFFC4922A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(point.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(point.arabic,
                        style: const TextStyle(fontSize: 13, fontFamily: 'Scheherazade', color: Color(0xFFC4922A))),
                    ],
                  ),
                  Text(point.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// hadith_screen.dart
class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hadiths = localization.getHadiths();
    return Scaffold(
      appBar: AppBar(title: Text(localization.t('tab_hadiths'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hadiths.length,
        itemBuilder: (ctx, i) => _HadithCard(hadith: hadiths[i]),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.hadith});
  final HadithEntry hadith;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hadith.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17, fontFamily: 'Scheherazade',
                height: 1.9, color: Color(0xFF1A4A2E)),
            ),
            const SizedBox(height: 10),
            Text(hadith.translation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(hadith.source,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A6010), fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(hadith.topic,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF1A4A2E), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// diary_screen.dart — basic scaffold, full implementation in next phase
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = localization;
    return Scaffold(
      appBar: AppBar(title: Text(t.t('diary_title'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(t.t('diary_no_entries'), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: Text(t.t('diary_add')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2D7A4A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// onboarding_screen.dart
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌙', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              const Text('Hijama Guide',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFF0D080))),
              const SizedBox(height: 8),
              const Text('حجامة • Nach der Sunnah',
                style: TextStyle(fontSize: 14, color: Color(0xFF9FE1CB))),
              const SizedBox(height: 48),
              // Language selection
              ...LocalizationService.supportedLanguages.map((lang) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF0D080),
                        side: const BorderSide(color: Color(0xFF2D7A4A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('${lang.nativeLabel}  ${lang.label}',
                        style: const TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
