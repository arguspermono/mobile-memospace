import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../providers/note_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  final NoteProvider provider;
  const AddCategoryDialog({super.key, required this.provider});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _controller = TextEditingController();
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = NoteProvider.categoryColors[widget.provider.categories.length % NoteProvider.categoryColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Category Name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: NoteProvider.categoryColors.map((colorHex) {
                Color color = Colors.grey;
                try {
                  color = Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
                } catch (e) {}
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorHex;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: const Color(0xFF252422), width: 2) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 16, color: Color(0xFF252422)) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              widget.provider.addCategory(CategoryModel(name: name, colorHex: _selectedColor));
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
