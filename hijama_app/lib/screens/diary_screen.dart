import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/diary_service.dart';
import '../services/hijri_calendar_service.dart';
import '../services/localization_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _service = DiaryService();
  DateTime? _nextRecommended;

  @override
  void initState() {
    super.initState();
    _loadNextDate();
  }

  Future<void> _loadNextDate() async {
    final d = await _service.getNextRecommendedDate();
    if (mounted) setState(() => _nextRecommended = d);
  }

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('diary_title'))),
      body: user == null
          ? _NotLoggedIn(t: t)
          : Column(
              children: [
                if (_nextRecommended != null)
                  _NextDateBanner(date: _nextRecommended!),
                Expanded(
                  child: StreamBuilder<List<DiaryEntry>>(
                    stream: _service.entriesStream(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final entries = snap.data ?? [];
                      if (entries.isEmpty) {
                        return _EmptyState(t: t);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        itemBuilder: (ctx, i) => _EntryCard(
                          entry: entries[i],
                          onDelete: () => _service.deleteEntry(entries[i].id!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              backgroundColor: const Color(0xFF2D7A4A),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final t = localization;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();
    final practitionerController = TextEditingController();
    int cupsCount = 3;
    final selectedPoints = <String>{};
    final points = localization.getCuppingPoints();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) => Form(
            key: formKey,
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('diary_add'),
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today,
                      color: Color(0xFF2D7A4A)),
                  title: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                  ),
                  subtitle: Text(t.t('diary_session_date')),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setModalState(() => selectedDate = d);
                  },
                ),
                const Divider(),
                // Cups count
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined,
                        color: Color(0xFF2D7A4A)),
                    const SizedBox(width: 8),
                    Text(t.t('diary_cups_count')),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (cupsCount > 1) {
                          setModalState(() => cupsCount--);
                        }
                      },
                    ),
                    Text('$cupsCount',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setModalState(() => cupsCount++),
                    ),
                  ],
                ),
                const Divider(),
                // Body points
                Text(t.t('diary_body_points'),
                    style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: points
                      .map((p) => FilterChip(
                            label: Text(p.name,
                                style: const TextStyle(fontSize: 12)),
                            selected: selectedPoints.contains(p.id),
                            selectedColor:
                                const Color(0xFF2D7A4A).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF2D7A4A),
                            onSelected: (v) => setModalState(() {
                              if (v) {
                                selectedPoints.add(p.id);
                              } else {
                                selectedPoints.remove(p.id);
                              }
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Practitioner
                TextFormField(
                  controller: practitionerController,
                  decoration: InputDecoration(
                    labelText: t.t('diary_practitioner'),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Notes
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: t.t('diary_notes'),
                    prefixIcon: const Icon(Icons.notes),
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    final hijri = HijriCalendarService.fromGregorian(selectedDate);
                    final entry = DiaryEntry(
                      date: selectedDate,
                      hijriDay: hijri.hDay,
                      hijriMonth: hijri.hMonth,
                      hijriYear: hijri.hYear,
                      pointsUsed: selectedPoints.toList(),
                      notes: notesController.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    await _service.addEntry(entry);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadNextDate();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D7A4A),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(t.t('diary_save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NextDateBanner extends StatelessWidget {
  const _NextDateBanner({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = localization;
    final hijri = HijriCalendarService.fromGregorian(date);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4A2E), Color(0xFF2D7A4A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: Color(0xFFF0D080), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('diary_next_recommended'),
                  style: const TextStyle(
                      color: Color(0xFF9FE1CB), fontSize: 11),
                ),
                Text(
                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                  style: const TextStyle(
                    color: Color(0xFFF0D080),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${hijri.hDay}/${hijri.hMonth}/${hijri.hYear} H',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onDelete});
  final DiaryEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = localization;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Color(0xFF2D7A4A)),
                const SizedBox(width: 6),
                Text(
                  entry.formattedDate,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.hijriDateString + ' H',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  '${entry.daysSince}d ${t.t('diary_days_ago')}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(t.t('diary_delete_confirm_title')),
                        content: Text(t.t('diary_delete_confirm_body')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(t.t('cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(t.t('delete'),
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) onDelete();
                  },
                ),
              ],
            ),
            if (entry.pointsUsed.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: entry.pointsUsed
                    .map((id) => Chip(
                          label: Text(id,
                              style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: const Color(0xFFE8F4EC),
                        ))
                    .toList(),
              ),
            ],
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                entry.notes,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.t});
  final LocalizationService t;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined,
                size: 56,
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(t.t('diary_no_entries'),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn({required this.t});
  final LocalizationService t;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                size: 56,
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(t.t('diary_login_required'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      );
}
