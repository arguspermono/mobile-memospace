import 'dart:convert';

class NoteModel {
  final int? id;
  final String title;
  final String? content;
  final int? categoryId;
  final bool isPinned;
  final bool isFavorite;
  final String? reminderDate;
  final String? images;
  final String createdAt;
  final String updatedAt;

  NoteModel({
    this.id,
    required this.title,
    this.content,
    this.categoryId,
    this.isPinned = false,
    this.isFavorite = false,
    this.reminderDate,
    this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  String get plainText {
    if (content == null || content!.isEmpty) return '';
    try {
      if (content!.trim().startsWith('[')) {
        final decoded = jsonDecode(content!);
        if (decoded is List) {
          String text = '';
          for (var item in decoded) {
            if (item is Map && item['insert'] is String) {
              text += item['insert'];
            }
          }
          return text.trim();
        }
      }
    } catch (e) {
      // Fallback
    }
    return content!.trim();
  }

  bool get hasInlineImage {
    if (content == null || content!.isEmpty) return false;
    try {
      if (content!.trim().startsWith('[')) {
        final decoded = jsonDecode(content!);
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map && item['insert'] is Map && item['insert']['image'] != null) {
              return true;
            }
          }
        }
      }
    } catch (e) {
      // Fallback
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'is_pinned': isPinned ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'reminder_date': reminderDate,
      'images': images,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      categoryId: map['category_id'] as int?,
      isPinned: (map['is_pinned'] as int?) == 1,
      isFavorite: (map['is_favorite'] as int?) == 1,
      reminderDate: map['reminder_date'] as String?,
      images: map['images'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    int? categoryId,
    bool? isPinned,
    bool? isFavorite,
    String? reminderDate,
    bool clearReminder = false,
    String? images,
    String? createdAt,
    String? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      reminderDate: clearReminder ? null : (reminderDate ?? this.reminderDate),
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
