import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/category_model.dart';
import 'category_detail_screen.dart';
import 'manage_category_screen.dart';
import 'edit_category_screen.dart';
import 'note_editor_screen.dart';
import '../widgets/notification_dropdown.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isEditMode = false;

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
        actions: [
          const NotificationDropdown(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF252422)),
            onSelected: (value) {
              if (value == 'edit') {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isEditMode ? 'Tap a category to edit' : 'Edit mode disabled'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(_isEditMode ? Icons.check : Icons.edit, color: const Color(0xFF252422), size: 20),
                    const SizedBox(width: 8),
                    Text(_isEditMode ? 'Done Editing' : 'Edit Category'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF252422))),
                      Text('${provider.categories.length} Collections', style: const TextStyle(color: Color(0xFF707070), fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: provider.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ManageCategoryScreen()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEBF0F3), width: 1.5),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Color(0xFF707070)),
                                SizedBox(height: 8),
                                Text('New Category', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF252422))),
                                Text('Create', style: TextStyle(color: Color(0xFF707070), fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                      final category = provider.categories[index - 1];
                      Color bgColor = Colors.grey.shade300;
                      if (category.colorHex != null) {
                        try {
                          bgColor = Color(int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
                        } catch (e) {}
                      }
                      // Count notes
                      final count = provider.notes.where((n) => n.categoryId == category.id).length;
                      final bool isLight = bgColor.computeLuminance() > 0.5;
                      final Color textColor = isLight ? const Color(0xFF252422) : Colors.white;
                      final Color subTextColor = isLight ? const Color(0xFF252422).withValues(alpha: 0.6) : Colors.white70;

                      return InkWell(
                        onTap: () {
                          if (_isEditMode) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCategoryScreen(category: category),
                              ),
                            ).then((_) {
                              setState(() {
                                _isEditMode = false;
                              });
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailScreen(category: category),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          _showDeleteCategoryDialog(context, provider, category);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.folder, color: textColor.withValues(alpha: 0.8)),
                                  Icon(Icons.arrow_outward, color: textColor.withValues(alpha: 0.8), size: 16),
                                ],
                              ),
                              const Spacer(),
                              Text(category.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                              Text('$count Notes', style: TextStyle(color: subTextColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
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
