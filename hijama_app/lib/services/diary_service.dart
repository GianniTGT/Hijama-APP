import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A single Hijama session diary entry.
class DiaryEntry {
  final String? id;          // Firestore document ID (null if not yet saved)
  final DateTime date;       // Gregorian date of the session
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final List<String> pointsUsed; // point IDs e.g. ['kahil', 'akhday_left']
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

  /// Days since this session.
  int get daysSince => DateTime.now().difference(date).inDays;

  /// Human-readable date (Gregorian).
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Hijri date string.
  String get hijriDateString => '$hijriDay/$hijriMonth/$hijriYear';
}

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current user's diary collection path.
  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('diary');
  }

  /// Returns true if user is logged in.
  bool get isLoggedIn => _auth.currentUser != null;

  /// Stream of all diary entries, ordered newest first.
  Stream<List<DiaryEntry>> entriesStream() {
    final col = _collection;
    if (col == null) return const Stream.empty();

    return col
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DiaryEntry.fromFirestore).toList());
  }

  /// Save a new diary entry. Returns the saved entry with Firestore ID.
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

  /// Update an existing diary entry.
  Future<void> updateEntry(DiaryEntry entry) async {
    if (entry.id == null) throw Exception('Entry has no ID');
    await _collection?.doc(entry.id).update(entry.toFirestore());
  }

  /// Delete a diary entry.
  Future<void> deleteEntry(String id) async {
    await _collection?.doc(id).delete();
  }

  /// Get the most recent diary entry (null if none).
  Future<DiaryEntry?> getLastEntry() async {
    final col = _collection;
    if (col == null) return null;

    final snap = await col.orderBy('date', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return DiaryEntry.fromFirestore(snap.docs.first);
  }

  /// Calculate next recommended date based on last entry.
  /// Minimum 4 weeks after the last session, then next Sunnah day.
  Future<DateTime?> getNextRecommendedDate() async {
    final last = await getLastEntry();
    if (last == null) return null;

    // Minimum 4 weeks after last session
    final earliest = last.date.add(const Duration(days: 28));
    DateTime cursor = earliest.isBefore(DateTime.now()) ? DateTime.now() : earliest;

    // Find next Sunnah day (17, 19, or 21 hijri) from cursor
    for (int i = 0; i < 90; i++) {
      final h = _toHijri(cursor);
      if (h['day'] == 17 || h['day'] == 19 || h['day'] == 21) {
        return cursor;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return null;
  }

  /// Simple Hijri day extractor (delegates to hijri package in real code).
  Map<String, int> _toHijri(DateTime date) {
    // In production: use HijriCalendar.fromDate(date)
    // Placeholder returning sensible structure
    return {'day': 0, 'month': 0, 'year': 0};
  }
}
