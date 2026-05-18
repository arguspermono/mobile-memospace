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
