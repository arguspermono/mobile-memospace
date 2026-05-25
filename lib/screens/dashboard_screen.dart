import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';
import 'category_screen.dart';
import 'category_detail_screen.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/notification_dropdown.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSearchCategoryId;
  bool _showAllNotes = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _selectedIndex == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF252422)),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
        title: Padding(
          padding: EdgeInsets.only(left: _selectedIndex == 0 ? 16.0 : 0.0),
          child: Image.asset(
            'asset/img/logo/memospace_logohorizontal.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: const Color(0xFFFAF9F6),
        actions: [
          const NotificationDropdown(),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_selectedIndex == 0) {
            return _buildHomeTab(provider);
          } else if (_selectedIndex == 1) {
            return _buildFavoritesTab(provider);
          } else {
            return _buildSearchTab(provider);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        backgroundColor: const Color(0xFF252422),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEBF0F3), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, 0),
              activeIcon: _buildNavIcon(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.star_border, 1),
              activeIcon: _buildNavIcon(Icons.star, 1),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.search, 2),
              activeIcon: _buildNavIcon(Icons.search, 2),
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF252422) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF252422),
        size: 24,
      ),
    );
  }

  Widget _buildHomeTab(NoteProvider provider) {
    final pinnedNotes = provider.notes.where((n) => n.isPinned).toList();
    final allNotes = provider.notes.where((n) => !n.isPinned).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF252422),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL ACTIVITIES',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.notes.length} Notes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.description,
                        color: Colors.white.withOpacity(0.05),
                        size: 56,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'CATEGORIES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF707070),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount:
                  (provider.categories.length > 4
                      ? 4
                      : provider.categories.length) +
                  1,
              itemBuilder: (context, index) {
                final displayCount = provider.categories.length > 4
                    ? 4
                    : provider.categories.length;

                if (index == displayCount) {
                  return InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(),
                        ),
                      );
                      if (result != null && result is int) {
                        setState(() {
                          _selectedIndex = result;
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFEBF0F3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_view, color: Color(0xFF252422)),
                          SizedBox(height: 4),
                          Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF252422),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final category = provider.categories[index];
                final noteCount = provider.notes
                    .where((n) => n.categoryId == category.id)
                    .length;
                Color bgColor = Colors.grey.shade300;
                if (category.colorHex != null) {
                  try {
                    bgColor = Color(
                      int.parse(category.colorHex!.substring(1, 7), radix: 16) +
                          0xFF000000,
                    );
                  } catch (e) {}
                }

                final bool isLight = bgColor.computeLuminance() > 0.5;
                final Color textColor = isLight ? const Color(0xFF252422) : Colors.white;
                final Color subTextColor = isLight ? const Color(0xFF707070) : Colors.white70;

                IconData catIcon = Icons.folder_outlined;
                final nameLower = category.name.toLowerCase();
                if (nameLower.contains('kerja') || nameLower.contains('work')) {
                  catIcon = Icons.work_outline;
                } else if (nameLower.contains('kuliah') ||
                    nameLower.contains('school') ||
                    nameLower.contains('study')) {
                  catIcon = Icons.school_outlined;
                } else if (nameLower.contains('pribadi') ||
                    nameLower.contains('personal')) {
                  catIcon = Icons.person_outline;
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailScreen(category: category),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showDeleteCategoryDialog(context, provider, category);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(catIcon, color: textColor, size: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$noteCount notes',
                              style: TextStyle(
                                fontSize: 10,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (pinnedNotes.isNotEmpty)
          _buildSectionHeader(Icons.push_pin, 'PINNED'),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildNoteItem(context, provider, pinnedNotes[index]),
            childCount: pinnedNotes.length,
          ),
        ),
        if (allNotes.isNotEmpty)
          _buildSectionHeader(
            null,
            'ALL NOTES',
            trailing: GestureDetector(
              onTap: () {
                setState(() {
                  _showAllNotes = !_showAllNotes;
                });
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _showAllNotes ? Icons.keyboard_arrow_up : Icons.filter_list,
                  key: ValueKey<bool>(_showAllNotes),
                  size: 18,
                  color: const Color(0xFF707070),
                ),
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildNoteItem(context, provider, allNotes[index]),
            childCount: _showAllNotes 
                ? allNotes.length 
                : (allNotes.length > 6 ? 6 : allNotes.length),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildFavoritesTab(NoteProvider provider) {
    final favoriteNotes = provider.notes.where((n) => n.isFavorite).toList();
    if (favoriteNotes.isEmpty) {
      return const Center(
        child: Text(
          "No favorites yet.",
          style: TextStyle(color: Color(0xFF707070)),
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEBF0F3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Color(0xFF252422)),
                      SizedBox(width: 8),
                      Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF252422),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildNoteItem(
              context,
              provider,
              favoriteNotes[index],
              isFavoriteScreen: true,
            ),
            childCount: favoriteNotes.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildSearchTab(NoteProvider provider) {
    final searchResults = provider.notes.where((note) {
      bool categoryMatch = true;
      if (_selectedSearchCategoryId != null) {
        categoryMatch = note.categoryId == _selectedSearchCategoryId;
      }

      if (_searchQuery.isEmpty) return categoryMatch;
      final q = _searchQuery.toLowerCase();
      final titleMatch = note.title.toLowerCase().contains(q);
      final contentMatch = note.content?.toLowerCase().contains(q) ?? false;
      return categoryMatch && (titleMatch || contentMatch);
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBF0F3), width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF252422),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF707070),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                final isSelected = _selectedSearchCategoryId == category.id;
                Color bgColor = Colors.grey.shade300;
                if (category.colorHex != null) {
                  try {
                    bgColor = Color(
                      int.parse(category.colorHex!.substring(1, 7), radix: 16) +
                          0xFF000000,
                    );
                  } catch (e) {}
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      // Toggle off if it's already selected
                      if (_selectedSearchCategoryId == category.id) {
                        _selectedSearchCategoryId = null;
                      } else {
                        _selectedSearchCategoryId = category.id;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(right: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? bgColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFFEBF0F3)),
                    ),
                    child: Text(
                      category.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF707070),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty || _selectedSearchCategoryId != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '${searchResults.length} results${_searchQuery.isNotEmpty ? ' for "$_searchQuery"' : ''}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF707070)),
              ),
            ),
          ),
        if (searchResults.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(
                child: Text(
                  "No notes found.",
                  style: TextStyle(color: Color(0xFF707070)),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildNoteItem(
                context,
                provider,
                searchResults[index],
                isSearchScreen: true,
              ),
              childCount: searchResults.length,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildSectionHeader(IconData? icon, String title, {Widget? trailing}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: const Color(0xFF252422)),
              const SizedBox(width: 8),
            ],
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF252422),
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing],
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    NoteProvider provider,
    NoteModel note, {
    bool isFavoriteScreen = false,
    bool isSearchScreen = false,
  }) {
    return NoteCard(
      note: note,
      isFavoriteScreen: isFavoriteScreen,
      isSearchScreen: isSearchScreen,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditorScreen(existingNote: note),
          ),
        );
      },
      onLongPress: () {
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
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    NoteProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(provider: provider),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    NoteProvider provider,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text(
            'Are you sure you want to delete this category? Notes in this category will not be deleted, but they will be uncategorized.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteCategory(category.id!);
                Navigator.pop(context); // Close dialog
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
