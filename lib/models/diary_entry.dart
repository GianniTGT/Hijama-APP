import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String? id;
  final DateTime date;
  final List<String> bodyPoints;
  final String? notes;
  final int? cupsCount;
  final String? practitioner;
  final int painLevel; // 0-10
  final DateTime createdAt;

  const DiaryEntry({
    this.id,
    required this.date,
    required this.bodyPoints,
    this.notes,
    this.cupsCount,
    this.practitioner,
    this.painLevel = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
        'date': Timestamp.fromDate(date),
        'bodyPoints': bodyPoints,
        'notes': notes,
        'cupsCount': cupsCount,
        'practitioner': practitioner,
        'painLevel': painLevel,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      bodyPoints: List<String>.from(data['bodyPoints'] ?? []),
      notes: data['notes'],
      cupsCount: data['cupsCount'],
      practitioner: data['practitioner'],
      painLevel: data['painLevel'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
