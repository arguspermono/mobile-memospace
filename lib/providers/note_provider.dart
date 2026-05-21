import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import 'dart:io';
import '../services/database_helper.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int? _selectedCategoryFilterId;

  List<NoteModel> get notes {
    List<NoteModel> filtered = _notes;

    // Filter by category
    if (_selectedCategoryFilterId != null) {
      filtered = filtered.where((note) => note.categoryId == _selectedCategoryFilterId).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        final titleMatch = note.title.toLowerCase().contains(lowerQuery);
        final contentMatch = note.content?.toLowerCase().contains(lowerQuery) ?? false;
        return titleMatch || contentMatch;
      }).toList();
    }

    return filtered;
  }

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryFilterId => _selectedCategoryFilterId;

  int get totalNotesCount => _notes.length;
  int get pinnedNotesCount => _notes.where((note) => note.isPinned).length;

  int getNoteCountForCategory(int? categoryId) {
    if (categoryId == null) return _notes.length;
    return _notes.where((note) => note.categoryId == categoryId).length;
  }

  NoteProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _categories = await DatabaseHelper.instance.getCategories();
    _notes = await DatabaseHelper.instance.getNotes();

    _isLoading = false;
    notifyListeners();
  }

  // --- Notes ---
  
  Future<void> addNote(NoteModel note) async {
    await DatabaseHelper.instance.insertNote(note);
    await loadData();
  }

  Future<void> updateNote(NoteModel note) async {
    await DatabaseHelper.instance.updateNote(note);
    await loadData();
  }

  Future<void> deleteNote(int id) async {
    final note = getNoteById(id);
    if (note != null && note.images != null && note.images!.isNotEmpty) {
      final imagePaths = note.images!.split(',');
      for (final path in imagePaths) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Ignore deletion errors
        }
      }
    }
    await DatabaseHelper.instance.deleteNote(id);
    await loadData();
  }

  Future<void> togglePin(NoteModel note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updatedNote);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryFilterId = categoryId;
    notifyListeners();
  }

  NoteModel? getNoteById(int id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // --- Categories ---
  
  Future<void> addCategory(CategoryModel category) async {
    await DatabaseHelper.instance.insertCategory(category);
    await loadData();
  }
  
  Future<void> updateCategory(CategoryModel category) async {
    await DatabaseHelper.instance.updateCategory(category);
    await loadData();
  }
  
  Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    await loadData();
  }
}
