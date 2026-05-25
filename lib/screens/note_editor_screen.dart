import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../widgets/image_thumbnail.dart';
import 'manage_category_screen.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? existingNote;
  final int? preselectedCategoryId;

  const NoteEditorScreen({
    super.key,
    this.existingNote,
    this.preselectedCategoryId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  int? _selectedCategoryId;
  DateTime? _reminderDate;
  late bool _isEditing;

  List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingNote == null;
    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    
    quill.Document doc;
    try {
      if (widget.existingNote?.content != null && widget.existingNote!.content!.trim().startsWith('[')) {
        doc = quill.Document.fromJson(jsonDecode(widget.existingNote!.content!));
      } else {
        doc = quill.Document()..insert(0, widget.existingNote?.content ?? '');
      }
    } catch (e) {
      doc = quill.Document()..insert(0, widget.existingNote?.content ?? '');
    }
    
    _quillController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: !_isEditing,
    );
    _selectedCategoryId =
        widget.existingNote?.categoryId ?? widget.preselectedCategoryId;

    if (widget.existingNote?.images != null &&
        widget.existingNote!.images!.isNotEmpty) {
      _imagePaths = widget.existingNote!.images!.split(',');
    }

    if (widget.existingNote?.reminderDate != null) {
      _reminderDate = DateTime.parse(widget.existingNote!.reminderDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _processImageToText(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        final text = recognizedText.text;
        if (text.isNotEmpty) {
          final index = _quillController.selection.baseOffset;
          final insertIndex = index >= 0 ? index : _quillController.document.length;
          _quillController.document.insert(insertIndex, '\n$text\n');
          _quillController.moveCursorToPosition(insertIndex + text.length + 2);
        } else {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No text recognized from the image')));
          }
        }
        textRecognizer.close();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to recognize text: $e')));
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF252422)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _processImageToText(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF252422)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _processImageToText(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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

  void _confirmDelete(NoteProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteNote(widget.existingNote!.id!);
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to dashboard
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Note deleted')));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = jsonEncode(_quillController.document.toDelta().toJson());

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    final provider = context.read<NoteProvider>();
    final now = DateTime.now().toIso8601String();
    final String? imagesString = _imagePaths.isNotEmpty
        ? _imagePaths.join(',')
        : null;
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
          NotificationService.instance.scheduleClassroomReminders(
            baseId: newNote.createdAt.hashCode.abs(),
            title: newNote.title,
            body: newNote.plainText.isEmpty ? 'Tap to view note' : newNote.plainText,
            deadline: _reminderDate!,
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
        clearReminder: _reminderDate == null,
        updatedAt: now,
      );

      provider.updateNote(updatedNote).then((_) {
        final notifId = updatedNote.id ?? updatedNote.createdAt.hashCode.abs();
        if (_reminderDate != null) {
          NotificationService.instance.scheduleClassroomReminders(
            baseId: notifId.abs(),
            title: updatedNote.title,
            body: updatedNote.plainText.isEmpty ? 'Tap to view note' : updatedNote.plainText,
            deadline: _reminderDate!,
          );
        } else if (widget.existingNote!.reminderDate != null &&
            _reminderDate == null) {
          NotificationService.instance.cancelClassroomReminders(notifId.abs());
        }
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF252422)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _isEditing ? _buildEditActions() : _buildViewActions(),
      ),
      body: _isEditing ? _buildEditBody() : _buildViewBody(),
      bottomNavigationBar: _isEditing ? _buildEditBottomBar() : _buildViewBottomBar(),
    );
  }

  List<Widget> _buildEditActions() {
    return [
      IconButton(
        icon: Icon(_reminderDate == null ? Icons.add_alarm : Icons.alarm_on),
        tooltip: _reminderDate == null ? 'Set Reminder' : 'Edit Reminder',
        color: _reminderDate == null
            ? const Color(0xFF707070)
            : Colors.deepOrange,
        onPressed: _pickReminder,
      ),
      IconButton(
        icon: const Icon(Icons.document_scanner, color: Color(0xFF707070)),
        tooltip: 'Scan Text from Image',
        onPressed: _showImageSourceActionSheet,
      ),
      TextButton(
        onPressed: _saveNote,
        child: const Text(
          'Save',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF252422),
            fontSize: 16,
          ),
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> _buildViewActions() {
    final provider = context.read<NoteProvider>();
    return [
      if (widget.existingNote != null)
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFF252422)),
          onPressed: () => _confirmDelete(provider),
        ),
      IconButton(
        icon: const Icon(Icons.edit, color: Color(0xFF252422)),
        onPressed: () {
          setState(() {
            _isEditing = true;
            _quillController.readOnly = false;
          });
        },
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildEditBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildCategoryBadge(context, isEditing: true),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF707070),
              ),
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252422),
            ),
            textInputAction: TextInputAction.next,
          ),
          if (_reminderDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.alarm, size: 16, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Reminder set for ${_formatDateTime(_reminderDate!)}',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _reminderDate = null;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _buildImageGallery(),
          const SizedBox(height: 8),
          Expanded(
            child: quill.QuillEditor.basic(
              controller: _quillController,
              config: quill.QuillEditorConfig(
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252422),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF707070),
              ),
              const SizedBox(width: 6),
              Text(
                widget.existingNote?.createdAt != null
                    ? _formatDateTime(
                        DateTime.parse(widget.existingNote!.createdAt),
                      )
                    : _formatDateTime(DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Color(0xFF707070)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCategoryBadge(context, isEditing: false),
              if (_reminderDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF0F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.alarm,
                        size: 12,
                        color: Color(0xFF707070),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatShortDateTime(_reminderDate!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          quill.QuillEditor.basic(
            controller: _quillController,
            config: quill.QuillEditorConfig(
              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
            ),
          ),
          const SizedBox(height: 24),
          if (_imagePaths.isNotEmpty)
            Column(
              children: _imagePaths
                  .map(
                    (path) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageThumbnail(imagePath: path, onRemove: null),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEditBottomBar() {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEBF0F3), width: 1)),
        ),
        child: quill.QuillSimpleToolbar(
          controller: _quillController,
          config: quill.QuillSimpleToolbarConfig(
            multiRowsDisplay: false,
            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
            buttonOptions: quill.QuillSimpleToolbarButtonOptions(
              linkStyle: quill.QuillToolbarLinkStyleButtonOptions(
                linkRegExp: RegExp(r'.*'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewBottomBar() {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final currentNote = widget.existingNote != null
            ? provider.notes.firstWhere(
                (n) => n.id == widget.existingNote!.id,
                orElse: () => widget.existingNote!,
              )
            : widget.existingNote;

        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEBF0F3), width: 1)),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  currentNote?.isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentNote?.isFavorite == true
                      ? Color(0xFFFF6B6B)
                      : const Color(0xFF707070),
                ),
                onPressed: () {
                  if (currentNote != null) {
                    provider.toggleFavorite(currentNote);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentNote.isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  currentNote?.isPinned == true
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  color: currentNote?.isPinned == true
                      ? const Color(0xFF252422)
                      : const Color(0xFF707070),
                ),
                onPressed: () {
                  if (currentNote != null) {
                    provider.togglePin(currentNote);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentNote.isPinned
                              ? 'Note unpinned'
                              : 'Note pinned',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMMM d, yyyy • h:mm a').format(date);
  }

  String _formatShortDateTime(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date).toUpperCase();
  }

  Widget _buildImageGallery() {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
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

  Widget _buildCategoryBadge(BuildContext context, {required bool isEditing}) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final category = _selectedCategoryId != null
            ? provider.categories
                  .where((c) => c.id == _selectedCategoryId)
                  .firstOrNull
            : null;

        Color badgeColor = const Color(0xFFEBF0F3);
        if (category != null && category.colorHex != null) {
          try {
            badgeColor = Color(
              int.parse(category.colorHex!.substring(1, 7), radix: 16) +
                  0xFF000000,
            );
          } catch (e) {}
        }

        if (category == null) {
          if (!isEditing) return const SizedBox.shrink();
          return InkWell(
            onTap: () => _showCategoryBottomSheet(context, provider),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEBF0F3), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Color(0xFF707070)),
                  SizedBox(width: 4),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF707070),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return InkWell(
          onTap: isEditing
              ? () => _showCategoryBottomSheet(context, provider)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              category.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryBottomSheet(BuildContext context, NoteProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF252422),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: provider.categories.map((category) {
                            final isSelected = _selectedCategoryId == category.id;
                            Color badgeColor = Colors.grey;
                            if (category.colorHex != null) {
                              try {
                                badgeColor = Color(
                                  int.parse(
                                        category.colorHex!.substring(1, 7),
                                        radix: 16,
                                      ) +
                                      0xFF000000,
                                );
                              } catch (e) {}
                            }
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = isSelected
                                      ? null
                                      : category.id;
                                });
                                setSheetState(() {});
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFAF9F6)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF252422),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xFF707070),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddCategoryDialog(context, provider);
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF707070)),
                      label: const Text(
                        'NEW CATEGORY',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
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
    final newCategoryId = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (context) => const ManageCategoryScreen(isSelectionMode: true)),
    );

    if (newCategoryId != null) {
      setState(() {
        _selectedCategoryId = newCategoryId;
      });
    }
  }
}
