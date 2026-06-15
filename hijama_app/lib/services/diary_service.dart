import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hijri/hijri_calendar.dart';
import 'hijri_calendar_service.dart';

class DiaryEntry {
  final String? id;
  final DateTime date;
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final List<String> pointsUsed;
  final String notes;
  final DateTime createdAt;

  const DiaryEntry({
    this.id,
    required this.date,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.pointsUsed,
    this.notes = '',
    required this.createdAt,
  });

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      hijriDay: data['hijriDay'] as int,
      hijriMonth: data['hijriMonth'] as int,
      hijriYear: data['hijriYear'] as int,
      pointsUsed: List<String>.from(data['pointsUsed'] as List? ?? []),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'date': Timestamp.fromDate(date),
        'hijriDay': hijriDay,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'pointsUsed': pointsUsed,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  int get daysSince => DateTime.now().difference(date).inDays;

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  String get hijriDateString => '$hijriDay/$hijriMonth/$hijriYear';
}

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('diary');
  }

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<List<DiaryEntry>> entriesStream() {
    final col = _collection;
    if (col == null) return const Stream.empty();
    return col
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DiaryEntry.fromFirestore).toList());
  }

  Future<DiaryEntry> addEntry(DiaryEntry entry) async {
    final col = _collection;
    if (col == null) throw Exception('User not logged in');
    final ref = await col.add(entry.toFirestore());
    return DiaryEntry(
      id: ref.id,
      date: entry.date,
      hijriDay: entry.hijriDay,
      hijriMonth: entry.hijriMonth,
      hijriYear: entry.hijriYear,
      pointsUsed: entry.pointsUsed,
      notes: entry.notes,
      createdAt: entry.createdAt,
    );
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    if (entry.id == null) throw Exception('Entry has no ID');
    await _collection?.doc(entry.id).update(entry.toFirestore());
  }

  Future<void> deleteEntry(String id) async {
    await _collection?.doc(id).delete();
  }

  Future<DiaryEntry?> getLastEntry() async {
    final col = _collection;
    if (col == null) return null;
    final snap =
        await col.orderBy('date', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return DiaryEntry.fromFirestore(snap.docs.first);
  }

  /// Next recommended date = min 4 weeks after last session → next Sunnah day.
  Future<DateTime?> getNextRecommendedDate() async {
    final last = await getLastEntry();
    if (last == null) return null;

    final earliest = last.date.add(const Duration(days: 28));
    DateTime cursor =
        earliest.isBefore(DateTime.now()) ? DateTime.now() : earliest;

    for (int i = 0; i < 90; i++) {
      final hijri = HijriCalendar.fromDate(cursor);
      if (HijriCalendarService.sunnahHijriDays.contains(hijri.hDay)) {
        return cursor;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return null;
  }
}
