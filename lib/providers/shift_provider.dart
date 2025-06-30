import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/shift.dart';
import '../services/storage_service.dart';

class ShiftProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final Uuid _uuid = const Uuid();
  
  List<Shift> _shifts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Shift> get shifts => List.unmodifiable(_shifts);
  List<Shift> get activeShifts => _shifts.where((shift) => shift.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasShifts => _shifts.isNotEmpty;
  bool get hasActiveShifts => activeShifts.isNotEmpty;

  ShiftProvider() {
    _loadShifts();
  }

  // Load shifts from storage
  Future<void> _loadShifts() async {
    try {
      _setLoading(true);
      _shifts = _storage.getShifts();
      developer.log('Loaded ${_shifts.length} shifts');
    } catch (e) {
      _setError('Failed to load shifts: $e');
      developer.log('Failed to load shifts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save shifts to storage
  Future<bool> _saveShifts() async {
    try {
      final success = await _storage.saveShifts(_shifts);
      if (success) {
        developer.log('Shifts saved successfully');
      } else {
        _setError('Failed to save shifts');
      }
      return success;
    } catch (e) {
      _setError('Failed to save shifts: $e');
      developer.log('Failed to save shifts: $e');
      return false;
    }
  }

  // Get shift by ID
  Shift? getShiftById(String id) {
    try {
      return _shifts.firstWhere((shift) => shift.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get shifts by type
  List<Shift> getShiftsByType(ShiftType type) {
    return _shifts.where((shift) => shift.type == type).toList();
  }

  // Get shifts active on a specific day
  List<Shift> getShiftsForDay(DateTime date) {
    return _shifts.where((shift) => shift.isActiveOnDay(date)).toList();
  }

  // Create new shift
  Future<bool> createShift({
    required String name,
    required ShiftType type,
    required DateTime startTime,
    required DateTime endTime,
    bool isActive = true,
    bool requiresSignIn = true,
    bool requiresSignOut = true,
    double overtimeRate = 1.5,
    double nightShiftRate = 1.3,
    double sundayRate = 2.0,
    double holidayRate = 2.5,
    List<int> workDays = const [1, 2, 3, 4, 5],
  }) async {
    try {
      final shift = Shift(
        id: _uuid.v4(),
        name: name,
        type: type,
        startTime: startTime,
        endTime: endTime,
        isActive: isActive,
        requiresSignIn: requiresSignIn,
        requiresSignOut: requiresSignOut,
        overtimeRate: overtimeRate,
        nightShiftRate: nightShiftRate,
        sundayRate: sundayRate,
        holidayRate: holidayRate,
        workDays: workDays,
        createdAt: DateTime.now(),
      );

      _shifts.add(shift);
      notifyListeners();
      
      final success = await _saveShifts();
      if (success) {
        developer.log('Shift created: ${shift.name}');
      }
      return success;
    } catch (e) {
      _setError('Failed to create shift: $e');
      developer.log('Failed to create shift: $e');
      return false;
    }
  }

  // Update existing shift
  Future<bool> updateShift(Shift updatedShift) async {
    try {
      final index = _shifts.indexWhere((shift) => shift.id == updatedShift.id);
      if (index == -1) {
        _setError('Shift not found');
        return false;
      }

      _shifts[index] = updatedShift.copyWith(updatedAt: DateTime.now());
      notifyListeners();
      
      final success = await _saveShifts();
      if (success) {
        developer.log('Shift updated: ${updatedShift.name}');
      }
      return success;
    } catch (e) {
      _setError('Failed to update shift: $e');
      developer.log('Failed to update shift: $e');
      return false;
    }
  }

  // Delete shift
  Future<bool> deleteShift(String shiftId) async {
    try {
      final index = _shifts.indexWhere((shift) => shift.id == shiftId);
      if (index == -1) {
        _setError('Shift not found');
        return false;
      }

      final shift = _shifts[index];
      _shifts.removeAt(index);
      notifyListeners();
      
      final success = await _saveShifts();
      if (success) {
        developer.log('Shift deleted: ${shift.name}');
      }
      return success;
    } catch (e) {
      _setError('Failed to delete shift: $e');
      developer.log('Failed to delete shift: $e');
      return false;
    }
  }

  // Toggle shift active status
  Future<bool> toggleShiftActive(String shiftId) async {
    try {
      final shift = getShiftById(shiftId);
      if (shift == null) {
        _setError('Shift not found');
        return false;
      }

      return await updateShift(shift.copyWith(isActive: !shift.isActive));
    } catch (e) {
      _setError('Failed to toggle shift status: $e');
      developer.log('Failed to toggle shift status: $e');
      return false;
    }
  }

  // Duplicate shift
  Future<bool> duplicateShift(String shiftId, {String? newName}) async {
    try {
      final originalShift = getShiftById(shiftId);
      if (originalShift == null) {
        _setError('Shift not found');
        return false;
      }

      final duplicatedShift = originalShift.copyWith(
        id: _uuid.v4(),
        name: newName ?? '${originalShift.name} (Copy)',
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      _shifts.add(duplicatedShift);
      notifyListeners();
      
      final success = await _saveShifts();
      if (success) {
        developer.log('Shift duplicated: ${duplicatedShift.name}');
      }
      return success;
    } catch (e) {
      _setError('Failed to duplicate shift: $e');
      developer.log('Failed to duplicate shift: $e');
      return false;
    }
  }

  // Get shift statistics
  Map<String, dynamic> getShiftStatistics() {
    final stats = <String, dynamic>{
      'totalShifts': _shifts.length,
      'activeShifts': activeShifts.length,
      'inactiveShifts': _shifts.length - activeShifts.length,
      'shiftTypes': <String, int>{},
      'averageDuration': 0.0,
      'totalWorkDays': 0,
    };

    if (_shifts.isEmpty) return stats;

    // Count shift types
    for (final shift in _shifts) {
      final typeName = shift.type.displayName;
      stats['shiftTypes'][typeName] = (stats['shiftTypes'][typeName] ?? 0) + 1;
    }

    // Calculate average duration
    final totalMinutes = _shifts.fold<int>(
      0,
      (sum, shift) => sum + shift.duration.inMinutes,
    );
    stats['averageDuration'] = totalMinutes / _shifts.length / 60.0; // in hours

    // Count total work days
    final allWorkDays = <int>{};
    for (final shift in activeShifts) {
      allWorkDays.addAll(shift.workDays);
    }
    stats['totalWorkDays'] = allWorkDays.length;

    return stats;
  }

  // Search shifts
  List<Shift> searchShifts(String query) {
    if (query.isEmpty) return _shifts;
    
    final lowerQuery = query.toLowerCase();
    return _shifts.where((shift) {
      return shift.name.toLowerCase().contains(lowerQuery) ||
             shift.type.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Sort shifts
  void sortShifts(ShiftSortOption sortOption, {bool ascending = true}) {
    switch (sortOption) {
      case ShiftSortOption.name:
        _shifts.sort((a, b) => ascending 
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case ShiftSortOption.type:
        _shifts.sort((a, b) => ascending 
            ? a.type.displayName.compareTo(b.type.displayName)
            : b.type.displayName.compareTo(a.type.displayName));
        break;
      case ShiftSortOption.startTime:
        _shifts.sort((a, b) => ascending 
            ? a.startTime.compareTo(b.startTime)
            : b.startTime.compareTo(a.startTime));
        break;
      case ShiftSortOption.duration:
        _shifts.sort((a, b) => ascending 
            ? a.duration.compareTo(b.duration)
            : b.duration.compareTo(a.duration));
        break;
      case ShiftSortOption.createdAt:
        _shifts.sort((a, b) => ascending 
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  // Refresh shifts from storage
  Future<void> refreshShifts() async {
    await _loadShifts();
  }

  // Clear all shifts
  Future<bool> clearAllShifts() async {
    try {
      _shifts.clear();
      notifyListeners();
      
      final success = await _saveShifts();
      if (success) {
        developer.log('All shifts cleared');
      }
      return success;
    } catch (e) {
      _setError('Failed to clear shifts: $e');
      developer.log('Failed to clear shifts: $e');
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

enum ShiftSortOption {
  name,
  type,
  startTime,
  duration,
  createdAt,
}
