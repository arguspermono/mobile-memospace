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
      selectedColor: badgeColor.withOpacity(0.3),
      checkmarkColor: badgeColor,
      labelStyle: TextStyle(
        color: isSelected ? badgeColor.withOpacity(0.9) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
