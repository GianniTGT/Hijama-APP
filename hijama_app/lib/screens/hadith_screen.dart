import 'package:flutter/material.dart';
import '../services/localization_service.dart';

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
                fontSize: 17,
                fontFamily: 'Scheherazade',
                height: 1.9,
                color: Color(0xFF1A4A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hadith.translation,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Badge(text: hadith.source, bg: const Color(0xFFF5F0E8), fg: const Color(0xFF8A6010)),
                const SizedBox(width: 8),
                _Badge(text: hadith.topic, bg: const Color(0xFFE8F4EC), fg: const Color(0xFF1A4A2E)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500),
        ),
      );
}
