import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get completedNotes => _notes.where((note) => note.isCompleted).toList();
  List<Note> get pendingNotes => _notes.where((note) => !note.isCompleted).toList();
  List<Note> get notesWithReminders => _notes.where((note) => note.hasReminder).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNotes => _notes.isNotEmpty;

  NotesProvider() {
    _loadNotes();
  }

  // Load notes from storage
  Future<void> _loadNotes() async {
    try {
      _setLoading(true);
      _notes = _storage.getNotes();
      _sortNotes();
      developer.log('Loaded ${_notes.length} notes');
    } catch (e) {
      _setError('Failed to load notes: $e');
      developer.log('Failed to load notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save notes to storage
  Future<bool> _saveNotes() async {
    try {
      final success = await _storage.saveNotes(_notes);
      if (success) {
        developer.log('Notes saved successfully');
      } else {
        _setError('Failed to save notes');
      }
      return success;
    } catch (e) {
      _setError('Failed to save notes: $e');
      developer.log('Failed to save notes: $e');
      return false;
    }
  }

  // Sort notes (pinned first, then by priority, then by date)
  void _sortNotes() {
    _notes.sort((a, b) {
      // Pinned notes first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      // Then by priority
      final priorityComparison = b.priority.level.compareTo(a.priority.level);
      if (priorityComparison != 0) return priorityComparison;
      
      // Then by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // Get note by ID
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get notes by type
  List<Note> getNotesByType(NoteType type) {
    return _notes.where((note) => note.type == type).toList();
  }

  // Get notes by priority
  List<Note> getNotesByPriority(NotePriority priority) {
    return _notes.where((note) => note.priority == priority).toList();
  }

  // Search notes
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    return _notes.where((note) => note.matchesSearch(query)).toList();
  }

  // Filter notes
  List<Note> filterNotes({
    NoteType? type,
    NotePriority? priority,
    bool? completed,
    bool? hasReminder,
    String? shiftId,
  }) {
    return _notes.where((note) => note.matchesFilters(
      typeFilter: type,
      priorityFilter: priority,
      completedFilter: completed,
      hasReminderFilter: hasReminder,
      shiftIdFilter: shiftId,
    )).toList();
  }

  // Add new note
  Future<bool> addNote(Note note) async {
    try {
      _notes.add(note);
      _sortNotes();
      notifyListeners();
      
      final success = await _saveNotes();
      if (success) {
        developer.log('Note added: ${note.title}');
      }
      return success;
    } catch (e) {
      _setError('Failed to add note: $e');
      developer.log('Failed to add note: $e');
      return false;
    }
  }

  // Update existing note
  Future<bool> updateNote(Note updatedNote) async {
    try {
      final index = _notes.indexWhere((note) => note.id == updatedNote.id);
      if (index == -1) {
        _setError('Note not found');
        return false;
      }

      _notes[index] = updatedNote;
      _sortNotes();
      notifyListeners();
      
      final success = await _saveNotes();
      if (success) {
        developer.log('Note updated: ${updatedNote.title}');
      }
      return success;
    } catch (e) {
      _setError('Failed to update note: $e');
      developer.log('Failed to update note: $e');
      return false;
    }
  }

  // Delete note
  Future<bool> deleteNote(String noteId) async {
    try {
      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index == -1) {
        _setError('Note not found');
        return false;
      }

      final note = _notes[index];
      _notes.removeAt(index);
      notifyListeners();
      
      final success = await _saveNotes();
      if (success) {
        developer.log('Note deleted: ${note.title}');
      }
      return success;
    } catch (e) {
      _setError('Failed to delete note: $e');
      developer.log('Failed to delete note: $e');
      return false;
    }
  }

  // Toggle note completion
  Future<bool> toggleNoteCompletion(String noteId) async {
    try {
      final note = getNoteById(noteId);
      if (note == null) {
        _setError('Note not found');
        return false;
      }

      return await updateNote(note.copyWith(isCompleted: !note.isCompleted));
    } catch (e) {
      _setError('Failed to toggle note completion: $e');
      developer.log('Failed to toggle note completion: $e');
      return false;
    }
  }

  // Toggle note pin
  Future<bool> toggleNotePin(String noteId) async {
    try {
      final note = getNoteById(noteId);
      if (note == null) {
        _setError('Note not found');
        return false;
      }

      return await updateNote(note.copyWith(isPinned: !note.isPinned));
    } catch (e) {
      _setError('Failed to toggle note pin: $e');
      developer.log('Failed to toggle note pin: $e');
      return false;
    }
  }

  // Get notes statistics
  Map<String, dynamic> getNotesStatistics() {
    final stats = <String, dynamic>{
      'totalNotes': _notes.length,
      'completedNotes': completedNotes.length,
      'pendingNotes': pendingNotes.length,
      'pinnedNotes': pinnedNotes.length,
      'notesWithReminders': notesWithReminders.length,
      'notesByType': <String, int>{},
      'notesByPriority': <String, int>{},
    };

    // Count by type
    for (final type in NoteType.values) {
      final count = _notes.where((note) => note.type == type).length;
      stats['notesByType'][type.displayName] = count;
    }

    // Count by priority
    for (final priority in NotePriority.values) {
      final count = _notes.where((note) => note.priority == priority).length;
      stats['notesByPriority'][priority.displayName] = count;
    }

    return stats;
  }

  // Get overdue notes
  List<Note> getOverdueNotes() {
    return _notes.where((note) => note.isOverdue).toList();
  }

  // Get notes for today
  List<Note> getTodayNotes() {
    final today = DateTime.now();
    return _notes.where((note) {
      if (note.reminder?.nextReminderTime == null) return false;
      final reminderDate = note.reminder!.nextReminderTime!;
      return reminderDate.year == today.year &&
             reminderDate.month == today.month &&
             reminderDate.day == today.day;
    }).toList();
  }

  // Refresh notes from storage
  Future<void> refreshNotes() async {
    await _loadNotes();
  }

  // Clear all notes
  Future<bool> clearAllNotes() async {
    try {
      _notes.clear();
      notifyListeners();
      
      final success = await _saveNotes();
      if (success) {
        developer.log('All notes cleared');
      }
      return success;
    } catch (e) {
      _setError('Failed to clear notes: $e');
      developer.log('Failed to clear notes: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void clearError() {
    _setError(null);
  }
}
