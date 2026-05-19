import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import '../providers/note_provider.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        // Get the latest version of the note from provider
        final currentNote = provider.getNoteById(note.id!) ?? note;
        final category = currentNote.categoryId != null
            ? provider.getCategoryById(currentNote.categoryId!)
            : null;

        Color? categoryColor;
        if (category?.colorHex != null && category!.colorHex!.length == 7) {
          try {
            categoryColor = Color(
              int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000,
            );
          } catch (e) {
            // ignore
          }
        }

        final List<String> imagePaths = currentNote.images != null && currentNote.images!.isNotEmpty
            ? currentNote.images!.split(',')
            : [];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              category?.name ?? 'Note',
              style: TextStyle(color: categoryColor ?? Colors.deepPurple),
            ),
            actions: [
              if (currentNote.isPinned)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.push_pin, color: Colors.deepOrange, size: 20),
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Note',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditorScreen(existingNote: currentNote),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Note',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Note'),
                      content: const Text('Are you sure you want to delete this note?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteNote(currentNote.id!);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                if (category != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (categoryColor ?? Colors.deepPurple).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: categoryColor ?? Colors.deepPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Title
                Text(
                  currentNote.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Date & Reminder info
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(currentNote.createdAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                    if (currentNote.reminderDate != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.alarm, size: 14, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(currentNote.reminderDate!),
                        style: const TextStyle(color: Colors.deepOrange, fontSize: 13),
                      ),
                    ],
                  ],
                ),

                const Divider(height: 32),

                // Images
                if (imagePaths.isNotEmpty) ...[
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(imagePaths[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content
                if (currentNote.content != null && currentNote.content!.isNotEmpty)
                  Text(
                    currentNote.content!,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  )
                else
                  Text(
                    'No content.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoDate;
    }
  }
}
