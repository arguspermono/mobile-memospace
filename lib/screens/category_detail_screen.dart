import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';
import 'edit_category_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    Color appBarColor = Colors.grey.shade300;
    if (category.colorHex != null) {
      try {
        appBarColor = Color(int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
      } catch (e) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF252422)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'asset/img/logo/memospace_logohorizontal.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Consumer<NoteProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF252422)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCategoryScreen(category: category),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFF252422)),
                    onPressed: () {
                      _showDeleteCategoryDialog(context, provider);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final updatedCategory = provider.categories.firstWhere(
            (c) => c.id == category.id,
            orElse: () => category,
          );
          
          Color updatedAppBarColor = Colors.grey.shade300;
          if (updatedCategory.colorHex != null) {
            try {
              updatedAppBarColor = Color(int.parse(updatedCategory.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
            } catch (e) {}
          }

          final categoryNotes = provider.notes.where((n) => n.categoryId == updatedCategory.id).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: updatedAppBarColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: updatedAppBarColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: updatedAppBarColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        updatedCategory.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: updatedAppBarColor.computeLuminance() > 0.5 ? const Color(0xFF252422) : updatedAppBarColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: categoryNotes.isEmpty
                    ? const Center(
                        child: Text(
                          "No notes in this category.",
                          style: TextStyle(color: Color(0xFF707070)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: categoryNotes.length,
                        itemBuilder: (context, index) {
                          final note = categoryNotes[index];
                          return NoteCard(
                            note: note,
                            isFavoriteScreen: false,
                            isCategoryScreen: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditorScreen(existingNote: note),
                                ),
                              );
                            },
                            onLongPress: () {
                              _showDeleteDialog(context, provider, note);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(preselectedCategoryId: category.id),
            ),
          );
        },
        backgroundColor: const Color(0xFF252422),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, NoteProvider provider, NoteModel note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteNote(note.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category? Notes in this category will not be deleted, but they will be uncategorized.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteCategory(category.id!);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

