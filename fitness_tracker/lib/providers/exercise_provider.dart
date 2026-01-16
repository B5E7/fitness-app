import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/exercise.dart';

/// Provider for managing exercises state
/// 
/// Handles loading, creating, updating, and deleting exercises.
class ExerciseProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();
  
  List<Exercise> _exercises = [];
  String? _selectedMuscleGroup;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Exercise> get exercises => _exercises;
  String? get selectedMuscleGroup => _selectedMuscleGroup;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get exercises filtered by the selected muscle group
  List<Exercise> get filteredExercises {
    if (_selectedMuscleGroup == null) return _exercises;
    return _exercises.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
  }

  /// Get exercises grouped by muscle group
  Map<String, List<Exercise>> get exercisesByMuscleGroup {
    final Map<String, List<Exercise>> grouped = {};
    for (final exercise in _exercises) {
      grouped.putIfAbsent(exercise.muscleGroup, () => []).add(exercise);
    }
    return grouped;
  }

  /// Get only custom exercises
  List<Exercise> get customExercises {
    return _exercises.where((e) => e.isCustom).toList();
  }

  /// Load all exercises from the database
  Future<void> loadExercises() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exercises = await _db.getExercises();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load exercises: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set the selected muscle group filter
  void setMuscleGroupFilter(String? muscleGroup) {
    _selectedMuscleGroup = muscleGroup;
    notifyListeners();
  }

  /// Add a new custom exercise
  Future<bool> addExercise({
    required String name,
    required String muscleGroup,
    String? description,
  }) async {
    try {
      final exercise = Exercise(
        id: 'custom_${_uuid.v4()}',
        name: name,
        muscleGroup: muscleGroup,
        isCustom: true,
        description: description,
      );

      await _db.insertExercise(exercise);
      _exercises.add(exercise);
      
      // Sort exercises
      _exercises.sort((a, b) {
        final groupCompare = a.muscleGroup.compareTo(b.muscleGroup);
        if (groupCompare != 0) return groupCompare;
        return a.name.compareTo(b.name);
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add exercise: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing custom exercise
  Future<bool> updateExercise(Exercise exercise) async {
    if (!exercise.isCustom) {
      _error = 'Cannot edit built-in exercises';
      notifyListeners();
      return false;
    }

    try {
      await _db.updateExercise(exercise);
      
      final index = _exercises.indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        _exercises[index] = exercise;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update exercise: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a custom exercise
  Future<bool> deleteExercise(String id) async {
    final exercise = _exercises.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Exercise not found'),
    );

    if (!exercise.isCustom) {
      _error = 'Cannot delete built-in exercises';
      notifyListeners();
      return false;
    }

    try {
      await _db.deleteExercise(id);
      _exercises.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete exercise: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get an exercise by ID
  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
