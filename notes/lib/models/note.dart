import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  String title;
  String description;
  String? imageBase64;
  DateTime createdAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.imageBase64,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a Note from Firestore document data
  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageBase64: data['imageBase64'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert Note to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageBase64': imageBase64,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
