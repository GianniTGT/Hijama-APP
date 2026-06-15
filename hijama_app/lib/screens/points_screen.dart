import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../widgets/body_points_painter.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});
  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _selectedPointId;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final points = t.getCuppingPoints();
    final sunnahPoints = points.where((p) => p.isSunnah).toList();
    final otherPoints = points.where((p) => !p.isSunnah).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('tab_points')),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFFF0D080),
          unselectedLabelColor: const Color(0xFF9FE1CB),
          indicatorColor: const Color(0xFFC4922A),
          tabs: [
            Tab(text: t.t('points_tab_diagram')),
            Tab(text: t.t('points_tab_list')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Tab 1: Interactive body diagram
          _BodyDiagramTab(
            points: points,
            selectedId: _selectedPointId,
            onSelect: (id) => setState(() => _selectedPointId = id),
          ),
          // Tab 2: List view
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(label: t.t('points_sunnah_title')),
              const SizedBox(height: 8),
              ...sunnahPoints.map((p) => _PointCard(point: p)),
              const SizedBox(height: 16),
              _SectionHeader(label: t.t('points_other_title')),
              const SizedBox(height: 8),
              ...otherPoints.map((p) => _PointCard(point: p)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyDiagramTab extends StatelessWidget {
  const _BodyDiagramTab({
    required this.points,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CuppingPoint> points;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final selected = selectedId != null
        ? points.where((p) => p.id == selectedId).firstOrNull
        : null;

    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            child: Center(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight * 0.9,
                  );
                  return GestureDetector(
                    onTapUp: (details) {
                      final tappedId = BodyPointsPainter.hitTest(
                        details.localPosition,
                        size,
                        points,
                      );
                      onSelect(tappedId == selectedId ? null : tappedId);
                    },
                    child: CustomPaint(
                      size: size,
                      painter: BodyPointsPainter(
                        points: points,
                        selectedId: selectedId,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Detail panel
        if (selected != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: selected.isSunnah
                        ? const Color(0xFF1A4A2E)
                        : const Color(0xFFC4922A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(selected.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(selected.arabic,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Scheherazade',
                                  color: Color(0xFFC4922A))),
                          if (selected.isSunnah) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4EC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.t('points_sunnah_badge'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF1A4A2E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(selected.description,
                          style: const TextStyle(fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              t.t('points_tap_hint'),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
      );
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: point.isSunnah
                    ? const Color(0xFF2D7A4A)
                    : const Color(0xFFC4922A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        point.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        point.arabic,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Scheherazade',
                          color: Color(0xFFC4922A),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    point.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
