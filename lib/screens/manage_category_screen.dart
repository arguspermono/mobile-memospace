import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/category_model.dart';
import 'edit_category_screen.dart';
import 'note_editor_screen.dart';

class ManageCategoryScreen extends StatefulWidget {
  final bool isSelectionMode;
  const ManageCategoryScreen({super.key, this.isSelectionMode = false});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColorIndex = 0;

  final List<String> _colors = NoteProvider.categoryColors;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF252422),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAddCategoryCard(provider),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Existing Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF252422),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: ${provider.categories.length}',
                        style: const TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...provider.categories.map((category) {
                  final count = provider.notes.where((n) => n.categoryId == category.id).length;
                  Color bgColor = Colors.grey;
                  if (category.colorHex != null) {
                    try {
                      bgColor = Color(int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
                    } catch (e) {}
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEBF0F3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF252422),
                                ),
                              ),
                              Text(
                                '$count Notes',
                                style: const TextStyle(
                                  color: Color(0xFF707070),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF252422), size: 20),
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
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteCategoryDialog(context, provider, category),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 80), // Padding for FAB and BottomNavBar
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEBF0F3), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            Navigator.pop(context, index); // Go back to Dashboard with the selected tab index
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, false),
              activeIcon: _buildNavIcon(Icons.home, true),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.star_border, false),
              activeIcon: _buildNavIcon(Icons.star, false),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.search, false),
              activeIcon: _buildNavIcon(Icons.search, false),
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryCard(NoteProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBF0F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CATEGORY NAME',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF707070),
              letterSpacing: 1.2,
            ),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Work Projects',
              hintStyle: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEBF0F3))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF252422))),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'COLOR MARKER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF707070),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_colors.length, (index) {
              final color = Color(int.parse(_colors[index].substring(1, 7), radix: 16) + 0xFF000000);
              final isSelected = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: const Color(0xFF252422), width: 2) : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
                final newCat = CategoryModel(
                  name: _nameController.text.trim(),
                  colorHex: _colors[_selectedColorIndex],
                );
                final id = await provider.addCategory(newCat);
                if (widget.isSelectionMode && mounted) {
                  Navigator.pop(context, id);
                  return;
                }
                _nameController.clear();
                setState(() {
                  _selectedColorIndex = 0;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category created!')));
                }
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Create Category',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF252422),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
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

  void _showDeleteCategoryDialog(BuildContext context, NoteProvider provider, CategoryModel category) {
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
