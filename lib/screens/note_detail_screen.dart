import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  QuillController _buildController(String? rawContent) {
    if (rawContent == null || rawContent.isEmpty) {
      return QuillController.basic();
    }
    try {
      final decoded = jsonDecode(rawContent);
      if (decoded is List) {
        return QuillController(
          document: Document.fromJson(decoded),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (_) {
      // Legacy plain text
    }
    final doc = Document()..insert(0, rawContent);
    return QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
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

        final quillController = _buildController(currentNote.content);

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
          body: Padding(
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
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

                // Rich Text Content (read-only QuillEditor)
                Expanded(
                  child: QuillEditor.basic(
                    controller: quillController,
                    config: const QuillEditorConfig(
                      scrollable: true,
                      autoFocus: false,
                      expands: true,
                      padding: EdgeInsets.zero,
                      placeholder: 'No content.',
                    ),
                    focusNode: FocusNode(canRequestFocus: false),
                  ),
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
