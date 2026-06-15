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
              Tab(text: t.t('guide_before_title')),
              Tab(text: t.t('guide_during_title')),
              Tab(text: t.t('guide_after_title')),
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
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4EC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A4A2E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String? ?? '',
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['detail'] as String? ?? '',
                        style: Theme.of(ctx)
                            .textTheme
                            .bodySmall
                            ?.copyWith(height: 1.5),
                      ),
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
