import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/category_model.dart';
import '../services/database_helper.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<NoteModel> get notes {
    if (_searchQuery.isEmpty) return _notes;
    final lowerQuery = _searchQuery.toLowerCase();
    return _notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(lowerQuery);
      final contentMatch = note.content?.toLowerCase().contains(lowerQuery) ?? false;
      return titleMatch || contentMatch;
    }).toList();
  }

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  NoteProvider() {
    loadData();
  }

  static const List<String> categoryColors = [
    '#FF6B6B', '#E2F16D', '#7CD4FD', '#9D7CFD', '#6DF1A8',
    '#FFA07A', '#FFB6C1', '#4ECDC4', '#F7D070', '#B0BEC5'
  ];

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _categories = await DatabaseHelper.instance.getCategories();
    _notes = await DatabaseHelper.instance.getNotes();

    // Migrate old default purple colors to varied palette
    bool migrated = false;
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].colorHex == '#673AB7') {
        final updated = _categories[i].copyWith(
          colorHex: categoryColors[i % categoryColors.length]
        );
        await DatabaseHelper.instance.updateCategory(updated);
        migrated = true;
      }
    }
    
    if (migrated) {
      _categories = await DatabaseHelper.instance.getCategories();
    }

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
    await DatabaseHelper.instance.deleteNote(id);
    await loadData();
  }

  Future<void> togglePin(NoteModel note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updatedNote);
  }

  Future<void> toggleFavorite(NoteModel note) async {
    final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
    await updateNote(updatedNote);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // --- Categories ---
  
  Future<int> addCategory(CategoryModel category) async {
    final id = await DatabaseHelper.instance.insertCategory(category);
    await loadData();
    return id;
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
