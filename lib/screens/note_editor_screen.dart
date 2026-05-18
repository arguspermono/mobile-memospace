import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../widgets/category_chip.dart';
import '../widgets/image_thumbnail.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int? _selectedCategoryId;
  DateTime? _reminderDate;
  
  List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
    _selectedCategoryId = widget.existingNote?.categoryId;
    
    if (widget.existingNote?.images != null && widget.existingNote!.images!.isNotEmpty) {
      _imagePaths = widget.existingNote!.images!.split(',');
    }

    if (widget.existingNote?.reminderDate != null) {
      _reminderDate = DateTime.parse(widget.existingNote!.reminderDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _imagePaths.addAll(images.map((img) => img.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick images')),
        );
      }
    }
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    if (!mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _reminderDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_reminderDate == null ? Icons.add_alarm : Icons.alarm_on),
            tooltip: _reminderDate == null ? 'Set Reminder' : 'Edit Reminder',
            color: _reminderDate == null ? null : Colors.deepOrange,
            onPressed: _pickReminder,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Add Images',
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: () {
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();

              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title cannot be empty')),
                );
                return;
              }

              final provider = context.read<NoteProvider>();
              final now = DateTime.now().toIso8601String();
              final String? imagesString = _imagePaths.isNotEmpty ? _imagePaths.join(',') : null;
              final String? reminderString = _reminderDate?.toIso8601String();

              if (widget.existingNote == null) {
                final newNote = NoteModel(
                  title: title,
                  content: content,
                  categoryId: _selectedCategoryId,
                  images: imagesString,
                  reminderDate: reminderString,
                  createdAt: now,
                  updatedAt: now,
                );
                
                provider.addNote(newNote).then((_) {
                  if (_reminderDate != null) {
                    NotificationService.instance.scheduleNotification(
                      id: newNote.createdAt.hashCode,
                      title: 'Reminder: ${newNote.title}',
                      body: newNote.content ?? 'Tap to view note',
                      scheduledDate: _reminderDate!,
                    );
                  }
                });
              } else {
                final updatedNote = widget.existingNote!.copyWith(
                  title: title,
                  content: content,
                  categoryId: _selectedCategoryId,
                  images: imagesString,
                  reminderDate: reminderString,
                  updatedAt: now,
                );
                
                provider.updateNote(updatedNote).then((_) {
                  final notifId = updatedNote.id ?? updatedNote.createdAt.hashCode;
                  if (_reminderDate != null) {
                    NotificationService.instance.scheduleNotification(
                      id: notifId,
                      title: 'Reminder: ${updatedNote.title}',
                      body: updatedNote.content ?? 'Tap to view note',
                      scheduledDate: _reminderDate!,
                    );
                  } else if (widget.existingNote!.reminderDate != null && _reminderDate == null) {
                    NotificationService.instance.cancelNotification(notifId);
                  }
                });
              }

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(context),
            const SizedBox(height: 8),
            if (_reminderDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, size: 16, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Reminder set for ${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year} at ${_reminderDate!.hour}:${_reminderDate!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.deepOrange, fontSize: 12),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _reminderDate = null;
                        });
                      },
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textInputAction: TextInputAction.next,
            ),
            const Divider(),
            _buildImageGallery(),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          return ImageThumbnail(
            imagePath: _imagePaths[index],
            onRemove: () {
              setState(() {
                _imagePaths.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...provider.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CategoryChip(
                    category: category,
                    isSelected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                  ),
                );
              }).toList(),
              ActionChip(
                label: const Text('Add Category'),
                avatar: const Icon(Icons.add, size: 16),
                onPressed: () => _showAddCategoryDialog(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context, NoteProvider provider) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Category Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  provider.addCategory(CategoryModel(name: name, colorHex: '#673AB7'));
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
