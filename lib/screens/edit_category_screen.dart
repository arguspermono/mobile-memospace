import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/category_model.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  int _selectedColorIndex = 0;

  final List<String> _colors = NoteProvider.categoryColors;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColorIndex = _colors.indexOf(widget.category.colorHex ?? '');
    if (_selectedColorIndex == -1) {
      _selectedColorIndex = 0;
    }
  }

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
        title: const Text(
          'Edit Category',
          style: TextStyle(
            color: Color(0xFF252422),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditCategoryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEditCategoryCard(BuildContext context) {
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
                
                final updatedCat = widget.category.copyWith(
                  name: _nameController.text.trim(),
                  colorHex: _colors[_selectedColorIndex],
                );
                
                final provider = context.read<NoteProvider>();
                await provider.updateCategory(updatedCat);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category updated!')));
                  Navigator.pop(context); // Go back after updating
                }
              },
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text(
                'Save Changes',
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
}
