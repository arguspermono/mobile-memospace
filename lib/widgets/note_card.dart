import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import '../providers/note_provider.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isFavoriteScreen;
  final bool isCategoryScreen;
  final bool isSearchScreen;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.isFavoriteScreen = false,
    this.isCategoryScreen = false,
    this.isSearchScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final category = note.categoryId != null
            ? provider.categories.where((c) => c.id == note.categoryId).firstOrNull
            : null;

        Color borderColor = const Color(0xFFEBF0F3);
        if (category != null && category.colorHex != null && category.colorHex!.length == 7) {
          try {
            final parsedColor = Color(int.parse(category.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
            borderColor = parsedColor;
          } catch (e) {}
        }

        if (isFavoriteScreen) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFFFFFF),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEBF0F3), width: 1.5),
            ),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: borderColor, width: 4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: _buildFavoriteScreenLayout(context, category, borderColor),
              ),
            ),
          );
        }
        
        if (isSearchScreen) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFFFFFF),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEBF0F3), width: 1.5),
            ),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: borderColor, width: 4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchScreenLayout(context, category, borderColor),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEBF0F3), width: 1),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHomeLayout(context, category, borderColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteScreenLayout(BuildContext context, CategoryModel? category, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252422),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            if (note.isFavorite || note.isPinned)
              Icon(
                note.isFavorite ? Icons.star : Icons.push_pin, 
                size: 20, 
                color: const Color(0xFF252422)
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF252422),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (note.plainText.isNotEmpty) ...[
          Text(
            note.plainText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF707070),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        if (note.hasInlineImage) ...[
          Row(
            children: const [
              Icon(Icons.image, size: 16, color: Color(0xFF707070)),
              SizedBox(width: 4),
              Text(
                'Image',
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 12, color: Color(0xFF707070)),
            const SizedBox(width: 4),
            Text(
              _formatDate(note.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF707070),
                    fontSize: 12,
                  ),
            ),
            const Spacer(),
            if (note.reminderDate != null)
              Container(
                width: 20,
                alignment: Alignment.center,
                child: const Icon(Icons.alarm, size: 14, color: Color(0xFF707070)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHomeLayout(BuildContext context, CategoryModel? category, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF252422),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<NoteProvider>().toggleFavorite(note);
                  },
                  child: Icon(
                    note.isFavorite ? Icons.star : Icons.star_border, 
                    size: 22, 
                    color: note.isFavorite ? const Color(0xFF252422) : const Color(0xFF707070),
                  ),
                ),
                if (!note.isPinned && category != null && !isCategoryScreen) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: borderColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (note.plainText.isNotEmpty) ...[
          Text(
            note.plainText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF707070),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        if (note.hasInlineImage) ...[
          Row(
            children: const [
              Icon(Icons.image, size: 16, color: Color(0xFF707070)),
              SizedBox(width: 4),
              Text(
                'Image',
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            if (note.isPinned && category != null && !isCategoryScreen) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252422),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _formatDate(note.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF707070),
                    fontSize: 12,
                  ),
            ),
            const Spacer(),
            if (note.reminderDate != null)
              Container(
                width: 22,
                alignment: Alignment.center,
                child: const Icon(Icons.alarm, size: 14, color: Color(0xFF707070)),
              ),
            if (!note.isPinned && category != null && !isCategoryScreen)
              const SizedBox(width: 14),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchScreenLayout(BuildContext context, CategoryModel? category, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF252422),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (note.reminderDate != null) ...[
              const Icon(Icons.alarm, size: 12, color: Color(0xFF707070)),
              const SizedBox(width: 4),
            ],
            Text(
              _formatDate(note.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF707070),
                    fontSize: 10,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (note.plainText.isNotEmpty) ...[
          Text(
            note.plainText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF707070),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
        ],
        if (note.hasInlineImage) ...[
          Row(
            children: const [
              Icon(Icons.image, size: 16, color: Color(0xFF707070)),
              SizedBox(width: 4),
              Text(
                'Image',
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252422),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final noteDate = DateTime(date.year, date.month, date.day);
      
      if (noteDate == today) {
        final diff = now.difference(date);
        if (diff.inHours > 0) {
          return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
        } else if (diff.inMinutes > 0) {
          return "${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago";
        } else {
          return "Just now";
        }
      } else if (noteDate == yesterday) {
        return "Yesterday";
      }
      
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (e) {
      return isoDate;
    }
  }
}
