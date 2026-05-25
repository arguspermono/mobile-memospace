import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Parse color hex if valid, else default to deepPurple
    Color badgeColor = Colors.deepPurple;
    if (category.colorHex != null && category.colorHex!.length == 7) {
      try {
        badgeColor = Color(int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return FilterChip(
      label: Text(category.name),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: badgeColor.withValues(alpha: 0.3),
      checkmarkColor: badgeColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFEBF0F3), width: 1.5),
      ),
      labelStyle: TextStyle(
        color: isSelected ? badgeColor.withValues(alpha: 0.9) : const Color(0xFF252422),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
