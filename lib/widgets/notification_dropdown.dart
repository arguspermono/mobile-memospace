import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';
import '../screens/note_editor_screen.dart';

class NotificationDropdown extends StatelessWidget {
  const NotificationDropdown({Key? key}) : super(key: key);

  String _formatRelativeTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final noteDate = DateTime(date.year, date.month, date.day);
      
      if (noteDate == today) {
        final diff = now.difference(date);
        if (diff.inHours > 0) {
          return "${diff.inHours}h ago";
        } else if (diff.inMinutes > 0) {
          return "${diff.inMinutes}m ago";
        } else {
          return "Just now";
        }
      } else if (noteDate == yesterday) {
        return "Yesterday";
      }
      
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final notesWithReminder = provider.notes
            .where((n) => n.reminderDate != null)
            .toList();
        
        return PopupMenuButton<NoteModel>(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_none, color: Color(0xFF252422)),
              if (notesWithReminder.isNotEmpty)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          offset: const Offset(0, 48),
          color: const Color(0xFFFAF9F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) {
            List<PopupMenuEntry<NoteModel>> items = [
              const PopupMenuItem<NoteModel>(
                enabled: false,
                height: 32,
                child: Text(
                  'NOTIFIKASI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252422),
                  ),
                ),
              ),
              const PopupMenuDivider(),
            ];

            for (int i = 0; i < notesWithReminder.length; i++) {
              var note = notesWithReminder[i];
              items.add(
                PopupMenuItem<NoteModel>(
                  value: note,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF252422),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatRelativeTime(note.reminderDate!),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              if (i < notesWithReminder.length - 1) {
                items.add(const PopupMenuDivider());
              }
            }

            if (notesWithReminder.isEmpty) {
              items.add(
                const PopupMenuItem<NoteModel>(
                  enabled: false,
                  child: Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              );
            }

            return items;
          },
          onSelected: (note) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorScreen(existingNote: note),
              ),
            );
          },
        );
      },
    );
  }
}
