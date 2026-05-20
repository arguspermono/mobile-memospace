import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final CategoryModel? category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isInSelectionMode;

  const NoteCard({
    super.key,
    required this.note,
    this.category,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isInSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Parse category color
    Color categoryColor = Colors.deepPurple;
    if (category?.colorHex != null && category!.colorHex!.length == 7) {
      try {
        categoryColor = Color(
          int.parse(category!.colorHex!.substring(1, 7), radix: 16) + 0xFF000000,
        );
      } catch (e) {
        // ignore
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 2,
      shadowColor: isSelected ? Colors.deepPurple.withOpacity(0.4) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.deepPurple, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Color stripe on the left
              if (category != null)
                Container(
                  width: 5,
                  height: 90,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (note.isPinned)
                            const Icon(Icons.push_pin, size: 16, color: Colors.deepOrange),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Category name badge
                      if (category != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category!.name,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (note.content != null && note.content!.isNotEmpty) ...[
                        Text(
                          _extractPlainText(note.content!),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(note.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          if (note.reminderDate != null)
                            Icon(Icons.alarm, size: 14, color: Colors.grey.shade600),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isInSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.deepPurple : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoDate;
    }
  }

  /// Extracts plain text from a Quill delta JSON string.
  /// Falls back to the raw string for legacy plain-text notes.
  String _extractPlainText(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((op) {
              final insert = op['insert'];
              return insert is String ? insert : '';
            })
            .join()
            .trim();
      }
    } catch (_) {}
    return raw;
  }
}
