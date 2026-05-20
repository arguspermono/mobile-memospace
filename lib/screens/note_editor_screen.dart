import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();

  int? _selectedCategoryId;
  DateTime? _reminderDate;
  List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _selectedCategoryId = widget.existingNote?.categoryId;

    if (widget.existingNote?.images != null && widget.existingNote!.images!.isNotEmpty) {
      _imagePaths = widget.existingNote!.images!.split(',');
    }

    if (widget.existingNote?.reminderDate != null) {
      _reminderDate = DateTime.parse(widget.existingNote!.reminderDate!);
    }

    _quillController = _buildQuillController(widget.existingNote?.content);
    // Listen to controller changes to rebuild our custom toolbar state
    _quillController.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    // Trigger a rebuild so our custom toolbar buttons reflect the current style
    if (mounted) setState(() {});
  }

  QuillController _buildQuillController(String? rawContent) {
    if (rawContent == null || rawContent.isEmpty) {
      return QuillController.basic();
    }
    try {
      final decoded = jsonDecode(rawContent);
      if (decoded is List) {
        final doc = Document.fromJson(decoded);
        return QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (_) {}
    final doc = Document()..insert(0, rawContent);
    return QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _quillController.removeListener(_onControllerUpdate);
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // Custom formatting logic – bypasses QuillSimpleToolbar entirely
  // ──────────────────────────────────────────────────────────────

  bool _isInlineActive(Attribute attr) {
    final attrs = _quillController.getSelectionStyle().attributes;
    if (attr.key == Attribute.list.key ||
        attr.key == Attribute.header.key ||
        attr.key == Attribute.script.key ||
        attr.key == Attribute.align.key) {
      final attribute = attrs[attr.key];
      if (attribute == null) return false;
      return attribute.value == attr.value;
    }
    return attrs.containsKey(attr.key);
  }

  /// Check if a block attribute (list, header) is currently active
  bool _isBlockActive(Attribute attr) {
    final style = _quillController.getSelectionStyle();
    final val = style.attributes[attr.key];
    if (val == null) return false;
    return val.value == attr.value;
  }

  /// Toggle an inline format (bold, italic, underline, strikethrough)
  void _toggleInline(Attribute attr) {
    final isActive = _isInlineActive(attr);
    _quillController.skipRequestKeyboard = !attr.isInline;
    if (isActive) {
      _quillController.formatSelection(Attribute.clone(attr, null));
    } else {
      _quillController.formatSelection(attr);
    }
  }

  /// Toggle a block format (bullet list, numbered list, checklist)
  void _toggleBlock(Attribute attr) {
    final isActive = _isBlockActive(attr);
    if (isActive) {
      _quillController.formatSelection(Attribute.clone(attr, null));
    } else {
      _quillController.formatSelection(attr);
    }
    _editorFocusNode.requestFocus();
  }

  /// Cycle through header levels: none → H1 → H2 → H3 → none
  void _cycleHeader() {
    final style = _quillController.getSelectionStyle();
    final headerAttr = style.attributes[Attribute.header.key];
    final currentLevel = headerAttr?.value as int?;

    Attribute nextAttr;
    if (currentLevel == null) {
      nextAttr = Attribute.h1;
    } else if (currentLevel == 1) {
      nextAttr = Attribute.h2;
    } else if (currentLevel == 2) {
      nextAttr = Attribute.h3;
    } else {
      nextAttr = Attribute.clone(Attribute.header, null);
    }
    _quillController.formatSelection(nextAttr);
    _editorFocusNode.requestFocus();
  }

  /// Get current header level label for the toolbar
  String _getHeaderLabel() {
    final style = _quillController.getSelectionStyle();
    final headerAttr = style.attributes[Attribute.header.key];
    final level = headerAttr?.value as int?;
    if (level == 1) return 'H1';
    if (level == 2) return 'H2';
    if (level == 3) return 'H3';
    return 'H';
  }

  /// Clear all formatting from current selection
  void _clearFormat() {
    final length = _quillController.selection.end - _quillController.selection.start;
    if (length > 0) {
      // Clear inline styles
      for (final attr in [Attribute.bold, Attribute.italic, Attribute.underline, Attribute.strikeThrough]) {
        _quillController.formatSelection(Attribute.clone(attr, null));
      }
      // Clear block styles
      _quillController.formatSelection(Attribute.clone(Attribute.header, null));
      _quillController.formatSelection(Attribute.clone(Attribute.list, null));
    }
    _editorFocusNode.requestFocus();
  }

  // ──────────────────────────────────────────────────────────────
  // Image / Reminder pickers
  // ──────────────────────────────────────────────────────────────

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
      _reminderDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText().trim();

    final provider = context.read<NoteProvider>();
    final now = DateTime.now().toIso8601String();
    final String? imagesString = _imagePaths.isNotEmpty ? _imagePaths.join(',') : null;
    final String? reminderString = _reminderDate?.toIso8601String();

    if (widget.existingNote == null) {
      final newNote = NoteModel(
        title: title,
        content: deltaJson,
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
            body: plainText.isEmpty ? 'Tap to view note' : plainText,
            scheduledDate: _reminderDate!,
          );
        }
      });
    } else {
      final updatedNote = widget.existingNote!.copyWith(
        title: title,
        content: deltaJson,
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
            body: plainText.isEmpty ? 'Tap to view note' : plainText,
            scheduledDate: _reminderDate!,
          );
        } else if (widget.existingNote!.reminderDate != null && _reminderDate == null) {
          NotificationService.instance.cancelNotification(notifId);
        }
      });
    }

    Navigator.pop(context);
  }

  // ──────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.existingNote == null ? 'New Note' : 'Edit Note',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_reminderDate == null ? Icons.add_alarm_outlined : Icons.alarm_on, size: 22),
            tooltip: _reminderDate == null ? 'Set Reminder' : 'Edit Reminder',
            color: _reminderDate == null ? Colors.black87 : Colors.deepOrange,
            onPressed: _pickReminder,
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined, size: 22),
            tooltip: 'Add Images',
            color: Colors.black87,
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, size: 24, color: Colors.deepPurple),
            tooltip: 'Save Note',
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editor Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildCategorySelector(context),
                  const SizedBox(height: 12),
                  if (_reminderDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepOrange.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm, size: 16, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reminder set for ${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year} at ${_reminderDate!.hour}:${_reminderDate!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _reminderDate = null),
                            child: const Icon(Icons.close, size: 16, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black38),
                    ),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                    textInputAction: TextInputAction.next,
                  ),
                  const Divider(height: 8, color: Colors.black12),
                  _buildImageGallery(),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _quillController,
                      focusNode: _editorFocusNode,
                      config: const QuillEditorConfig(
                        placeholder: 'Start writing your story...',
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Custom Toolbar (replaces QuillSimpleToolbar) ──
          _buildCustomToolbar(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // CUSTOM TOOLBAR – full control, no QuillSimpleToolbar dependency
  // ──────────────────────────────────────────────────────────────

  Widget _buildCustomToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Bold
                _toolbarBtn(
                  icon: Icons.format_bold,
                  isActive: _isInlineActive(Attribute.bold),
                  onTap: () => _toggleInline(Attribute.bold),
                ),
                // Italic
                _toolbarBtn(
                  icon: Icons.format_italic,
                  isActive: _isInlineActive(Attribute.italic),
                  onTap: () => _toggleInline(Attribute.italic),
                ),
                // Underline
                _toolbarBtn(
                  icon: Icons.format_underlined,
                  isActive: _isInlineActive(Attribute.underline),
                  onTap: () => _toggleInline(Attribute.underline),
                ),
                // Strikethrough
                _toolbarBtn(
                  icon: Icons.format_strikethrough,
                  isActive: _isInlineActive(Attribute.strikeThrough),
                  onTap: () => _toggleInline(Attribute.strikeThrough),
                ),
                _toolbarDivider(),
                // Header cycle (H → H1 → H2 → H3 → H)
                _toolbarHeaderBtn(),
                _toolbarDivider(),
                // Bullet list
                _toolbarBtn(
                  icon: Icons.format_list_bulleted,
                  isActive: _isBlockActive(Attribute.ul),
                  onTap: () => _toggleBlock(Attribute.ul),
                ),
                // Numbered list
                _toolbarBtn(
                  icon: Icons.format_list_numbered,
                  isActive: _isBlockActive(Attribute.ol),
                  onTap: () => _toggleBlock(Attribute.ol),
                ),
                // Checklist
                _toolbarBtn(
                  icon: Icons.checklist,
                  isActive: _isBlockActive(Attribute.unchecked),
                  onTap: () => _toggleBlock(Attribute.unchecked),
                ),
                _toolbarDivider(),
                // Clear formatting
                _toolbarBtn(
                  icon: Icons.format_clear,
                  isActive: false,
                  onTap: _clearFormat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: isActive ? Colors.deepPurple.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: isActive ? Colors.deepPurple : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarHeaderBtn() {
    final label = _getHeaderLabel();
    final isActive = label != 'H';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: isActive ? Colors.deepPurple.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _cycleHeader,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.deepPurple : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.grey.shade300,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Shared UI builders
  // ──────────────────────────────────────────────────────────────

  Widget _buildImageGallery() {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
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
              }),
              ActionChip(
                label: const Text('Add Category'),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                backgroundColor: Colors.deepPurple.withOpacity(0.06),
                side: BorderSide(color: Colors.deepPurple.withOpacity(0.12)),
                avatar: const Icon(Icons.add, size: 16, color: Colors.deepPurple),
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
    String selectedColorHex = '#673AB7';

    final List<Map<String, dynamic>> colorOptions = [
      {'name': 'Purple', 'hex': '#673AB7'},
      {'name': 'Blue', 'hex': '#2196F3'},
      {'name': 'Teal', 'hex': '#009688'},
      {'name': 'Green', 'hex': '#4CAF50'},
      {'name': 'Orange', 'hex': '#FF9800'},
      {'name': 'Red', 'hex': '#F44336'},
      {'name': 'Pink', 'hex': '#E91E63'},
      {'name': 'Indigo', 'hex': '#3F51B5'},
      {'name': 'Cyan', 'hex': '#00BCD4'},
      {'name': 'Brown', 'hex': '#795548'},
      {'name': 'Grey', 'hex': '#607D8B'},
      {'name': 'Lime', 'hex': '#CDDC39'},
    ];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('New Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Category Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Pick a color:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: colorOptions.map((option) {
                      final hex = option['hex'] as String;
                      final color = Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000);
                      final isSelected = selectedColorHex == hex;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColorHex = hex;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black87, width: 3)
                                : Border.all(color: Colors.transparent, width: 3),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      provider.addCategory(CategoryModel(name: name, colorHex: selectedColorHex));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
