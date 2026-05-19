import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';
import 'note_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<int> _selectedNoteIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  void _toggleSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _pinSelectedNotes(NoteProvider provider) {
    // Gather all selected notes
    final selectedNotes = provider.notes.where((n) => _selectedNoteIds.contains(n.id)).toList();
    if (selectedNotes.isEmpty) return;

    // If at least one selected note is unpinned, pin them all. Else, unpin them all.
    final hasUnpinned = selectedNotes.any((note) => !note.isPinned);

    for (final note in selectedNotes) {
      if (hasUnpinned) {
        if (!note.isPinned) {
          provider.togglePin(note);
        }
      } else {
        if (note.isPinned) {
          provider.togglePin(note);
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hasUnpinned ? 'Selected notes pinned' : 'Selected notes unpinned'),
        duration: const Duration(seconds: 1),
      ),
    );

    _exitSelectionMode();
  }

  void _deleteSelectedNotes(NoteProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notes'),
        content: Text('Are you sure you want to delete ${_selectedNoteIds.length} notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (final id in _selectedNoteIds) {
                provider.deleteNote(id);
              }
              Navigator.pop(ctx);
              _exitSelectionMode();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected notes deleted'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text('${_selectedNoteIds.length} selected'),
              elevation: 2,
              backgroundColor: Colors.deepPurple.shade50,
              foregroundColor: Colors.deepPurple,
              actions: [
                IconButton(
                  icon: const Icon(Icons.push_pin),
                  tooltip: 'Pin/Unpin',
                  onPressed: () => _pinSelectedNotes(provider),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: () => _deleteSelectedNotes(provider),
                ),
              ],
            )
          : AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search notes...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        provider.setSearchQuery(value);
                      },
                    )
                  : const Text('MemoSpace', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: !_isSearching,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      }
                    });
                  },
                ),
              ],
            ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beautiful Quick Stats Header Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepPurple.withOpacity(0.12)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              radius: 18,
                              child: Icon(Icons.description, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Notes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${provider.totalNotesCount}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepOrange.withOpacity(0.12)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.deepOrange,
                              radius: 18,
                              child: Icon(Icons.push_pin, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pinned',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${provider.pinnedNotesCount}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Category Filter Selector
              if (provider.categories.isNotEmpty)
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "All" filter chip with note count
                        final isSelected = provider.selectedCategoryFilterId == null;
                        final count = provider.getNoteCountForCategory(null);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text('All ($count)'),
                            selected: isSelected,
                            selectedColor: Colors.deepPurple.withOpacity(0.2),
                            checkmarkColor: Colors.deepPurple,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.deepPurple : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              provider.setCategoryFilter(null);
                            },
                          ),
                        );
                      }

                      // Normal category filter chips with note count
                      final category = provider.categories[index - 1];
                      final isSelected = provider.selectedCategoryFilterId == category.id;
                      final count = provider.getNoteCountForCategory(category.id);

                      Color categoryColor = Colors.deepPurple;
                      if (category.colorHex != null && category.colorHex!.length == 7) {
                        try {
                          categoryColor = Color(
                            int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000,
                          );
                        } catch (e) {
                          // ignore
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text('${category.name} ($count)'),
                          selected: isSelected,
                          selectedColor: categoryColor.withOpacity(0.2),
                          checkmarkColor: categoryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? categoryColor : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            provider.setCategoryFilter(selected ? category.id : null);
                          },
                        ),
                      );
                    },
                  ),
                ),

              // Note list or Empty state
              Expanded(
                child: provider.notes.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching
                              ? 'No matching notes found.'
                              : (provider.selectedCategoryFilterId != null
                                  ? 'No notes in this category.'
                                  : 'No notes yet.\nTap + to create one!'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: provider.notes.length,
                        itemBuilder: (context, index) {
                          final note = provider.notes[index];
                          final category = note.categoryId != null
                              ? provider.getCategoryById(note.categoryId!)
                              : null;
                          final isSelected = _selectedNoteIds.contains(note.id);

                          return NoteCard(
                            note: note,
                            category: category,
                            isSelected: isSelected,
                            isInSelectionMode: _isSelectionMode,
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(note.id!);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteDetailScreen(note: note),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                setState(() {
                                  _isSelectionMode = true;
                                  _selectedNoteIds.add(note.id!);
                                });
                              }
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
              builder: (context) => const NoteEditorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
