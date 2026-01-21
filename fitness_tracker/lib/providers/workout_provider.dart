import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../models/exercise.dart';

/// Provider for managing workouts state
/// 
/// Handles creating, loading, and managing workout sessions
/// including the active workout and workout history.
class WorkoutProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<Workout> _workouts = [];
  Workout? _activeWorkout;
  List<ExerciseSets> _activeWorkoutSets = [];
  bool _isLoading = false;
  String? _error = null;
  double _totalVolume = 0;

  // Getters
  List<Workout> get workouts => _workouts;
  Workout? get activeWorkout => _activeWorkout;
  List<ExerciseSets> get activeWorkoutSets => _activeWorkoutSets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveWorkout => _activeWorkout != null;
  double get totalVolume => _totalVolume;

  /// Get completed workouts only
  List<Workout> get completedWorkouts {
    return _workouts.where((w) => w.isCompleted).toList();
  }

  /// Get workouts from today
  List<Workout> get todaysWorkouts {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _workouts.where((w) {
      final workoutDate = DateTime(
        w.startTime.year,
        w.startTime.month,
        w.startTime.day,
      );
      return workoutDate.isAtSameMomentAs(today);
    }).toList();
  }

  /// Get workouts from this week
  List<Workout> get thisWeeksWorkouts {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return _workouts.where((w) => w.startTime.isAfter(startOfWeek)).toList();
  }

  /// Load all workouts from the database
  Future<void> loadWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workouts = await _db.getWorkouts();
      
      // Calculate total volume
      double volume = 0;
      for (final w in _workouts) {
        if (w.isCompleted) {
          volume += await getWorkoutVolume(w.id);
        }
      }
      _totalVolume = volume;

      // Check if there's an incomplete workout (active workout)
      final incompleteWorkouts = _workouts.where((w) => !w.isCompleted).toList();
      if (incompleteWorkouts.isNotEmpty) {
        _activeWorkout = incompleteWorkouts.first;
        await _loadActiveWorkoutSets();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load workouts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load sets for the active workout
  Future<void> _loadActiveWorkoutSets() async {
    if (_activeWorkout == null) return;
    
    try {
      _activeWorkoutSets = await _db.getWorkoutExerciseSets(_activeWorkout!.id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load workout sets: $e';
      notifyListeners();
    }
  }

  /// Start a new workout session
  Future<bool> startWorkout({String? name, String? notes}) async {
    if (_activeWorkout != null) {
      _error = 'A workout is already in progress';
      notifyListeners();
      return false;
    }

    try {
      final workout = Workout(
        id: _uuid.v4(),
        name: name,
        startTime: DateTime.now(),
        notes: notes,
        isCompleted: false,
      );

      await _db.insertWorkout(workout);
      _activeWorkout = workout;
      _activeWorkoutSets = [];
      _workouts.insert(0, workout);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to start workout: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add an exercise to the active workout
  Future<bool> addExerciseToWorkout(Exercise exercise) async {
    if (_activeWorkout == null) {
      _error = 'No active workout';
      notifyListeners();
      return false;
    }

    // Check if exercise is already in workout
    if (_activeWorkoutSets.any((es) => es.exerciseId == exercise.id)) {
      _error = 'Exercise already added to workout';
      notifyListeners();
      return false;
    }

    try {
      // Check for last performance to pre-fill
      final lastPerformance = await _db.getLastPerformance(exercise.id);

      // Create first set for the exercise
      final set = WorkoutSet(
        id: _uuid.v4(),
        workoutId: _activeWorkout!.id,
        exerciseId: exercise.id,
        setNumber: 1,
        weight: lastPerformance?.weight ?? 0,
        reps: lastPerformance?.reps ?? 0,
        isCompleted: false,
        usePlates: lastPerformance?.usePlates ?? false,
      );

      await _db.insertWorkoutSet(set);

      // Add to active workout sets
      _activeWorkoutSets.add(ExerciseSets(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets: [set],
      ));

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add exercise: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add a new set to an exercise in the active workout
  Future<bool> addSet(String exerciseId) async {
    if (_activeWorkout == null) {
      _error = 'No active workout';
      notifyListeners();
      return false;
    }

    try {
      final exerciseSetIndex = _activeWorkoutSets.indexWhere(
        (es) => es.exerciseId == exerciseId,
      );

      if (exerciseSetIndex == -1) {
        _error = 'Exercise not found in workout';
        notifyListeners();
        return false;
      }

      final exerciseSets = _activeWorkoutSets[exerciseSetIndex];
      final lastSet = exerciseSets.sets.isNotEmpty ? exerciseSets.sets.last : null;

      final newSet = WorkoutSet(
        id: _uuid.v4(),
        workoutId: _activeWorkout!.id,
        exerciseId: exerciseId,
        setNumber: exerciseSets.sets.length + 1,
        weight: lastSet?.weight ?? 0,
        reps: lastSet?.reps ?? 0,
        isCompleted: false,
        usePlates: lastSet?.usePlates ?? false,
      );

      await _db.insertWorkoutSet(newSet);

      // Update the sets list
      final updatedSets = [...exerciseSets.sets, newSet];
      _activeWorkoutSets[exerciseSetIndex] = ExerciseSets(
        exerciseId: exerciseSets.exerciseId,
        exerciseName: exerciseSets.exerciseName,
        muscleGroup: exerciseSets.muscleGroup,
        sets: updatedSets,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add set: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update a set's weight, reps, or completion status
  Future<bool> updateSet(WorkoutSet updatedSet) async {
    try {
      await _db.updateWorkoutSet(updatedSet);

      // Find and update the set in active workout sets
      for (var i = 0; i < _activeWorkoutSets.length; i++) {
        final exerciseSets = _activeWorkoutSets[i];
        final setIndex = exerciseSets.sets.indexWhere((s) => s.id == updatedSet.id);
        
        if (setIndex != -1) {
          final updatedSets = [...exerciseSets.sets];
          updatedSets[setIndex] = updatedSet;
          
          _activeWorkoutSets[i] = ExerciseSets(
            exerciseId: exerciseSets.exerciseId,
            exerciseName: exerciseSets.exerciseName,
            muscleGroup: exerciseSets.muscleGroup,
            sets: updatedSets,
          );
          break;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update set: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a set from the active workout
  Future<bool> deleteSet(String setId) async {
    try {
      await _db.deleteWorkoutSet(setId);

      // Remove from active workout sets
      for (var i = 0; i < _activeWorkoutSets.length; i++) {
        final exerciseSets = _activeWorkoutSets[i];
        final setIndex = exerciseSets.sets.indexWhere((s) => s.id == setId);
        
        if (setIndex != -1) {
          final updatedSets = exerciseSets.sets.where((s) => s.id != setId).toList();
          
          if (updatedSets.isEmpty) {
            // Remove the exercise entirely if no sets left
            _activeWorkoutSets.removeAt(i);
          } else {
            // Update set numbers
            for (var j = 0; j < updatedSets.length; j++) {
              updatedSets[j] = updatedSets[j].copyWith(setNumber: j + 1);
            }
            
            _activeWorkoutSets[i] = ExerciseSets(
              exerciseId: exerciseSets.exerciseId,
              exerciseName: exerciseSets.exerciseName,
              muscleGroup: exerciseSets.muscleGroup,
              sets: updatedSets,
            );
          }
          break;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete set: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove an exercise from the active workout
  Future<bool> removeExerciseFromWorkout(String exerciseId) async {
    if (_activeWorkout == null) {
      _error = 'No active workout';
      notifyListeners();
      return false;
    }

    try {
      final exerciseSets = _activeWorkoutSets.firstWhere(
        (es) => es.exerciseId == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      // Delete all sets for this exercise
      for (final set in exerciseSets.sets) {
        await _db.deleteWorkoutSet(set.id);
      }

      _activeWorkoutSets.removeWhere((es) => es.exerciseId == exerciseId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove exercise: $e';
      notifyListeners();
      return false;
    }
  }

  /// Complete the active workout
  Future<bool> finishWorkout({String? notes}) async {
    if (_activeWorkout == null) {
      _error = 'No active workout';
      notifyListeners();
      return false;
    }

    try {
      final completedWorkout = _activeWorkout!.copyWith(
        endTime: _activeWorkout!.endTime ?? DateTime.now(),
        isCompleted: true,
        notes: notes ?? _activeWorkout!.notes,
      );

      await _db.updateWorkout(completedWorkout);

      // Mark all sets as completed
      for (final exerciseSets in _activeWorkoutSets) {
        for (final set in exerciseSets.sets) {
          if (!set.isCompleted) {
            final completedSet = set.copyWith(
              isCompleted: true,
              completedAt: DateTime.now(),
            );
            await _db.updateWorkoutSet(completedSet);
          }
        }
      }

      // Update in workouts list
      final index = _workouts.indexWhere((w) => w.id == _activeWorkout!.id);
      if (index != -1) {
        _workouts[index] = completedWorkout;
      }

      _activeWorkout = null;
      _activeWorkoutSets = [];
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to finish workout: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel/discard the active workout
  Future<bool> cancelWorkout() async {
    if (_activeWorkout == null) {
      _error = 'No active workout';
      notifyListeners();
      return false;
    }

    try {
      await _db.deleteWorkout(_activeWorkout!.id);
      _workouts.removeWhere((w) => w.id == _activeWorkout!.id);
      _activeWorkout = null;
      _activeWorkoutSets = [];
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to cancel workout: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a completed workout from history
  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await _db.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      if (_activeWorkout?.id == workoutId) {
        _activeWorkout = null;
        _activeWorkoutSets = [];
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete workout: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update workout details (name, notes, etc)
  Future<bool> updateWorkout(Workout workout) async {
    try {
      await _db.updateWorkout(workout);
      
      // Update in workouts list
      final index = _workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        _workouts[index] = workout;
      }
      
      // If it's the active workout, update it too
      if (_activeWorkout?.id == workout.id) {
        _activeWorkout = workout;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update workout: $e';
      notifyListeners();
      return false;
    }
  }

  /// Set a workout as active for editing (even if completed)
  Future<void> editWorkout(Workout workout) async {
    _activeWorkout = workout;
    await _loadActiveWorkoutSets();
    notifyListeners();
  }

  /// Clear the active workout without finishing it (useful for completed workout editing)
  void clearActiveWorkout() {
    _activeWorkout = null;
    _activeWorkoutSets = [];
    notifyListeners();
  }

  /// Get the last performance for an exercise
  Future<WorkoutSet?> getLastPerformance(String exerciseId) async {
    return await _db.getLastPerformance(exerciseId);
  }

  /// Get exercise history
  Future<List<WorkoutSet>> getExerciseHistory(String exerciseId) async {
    return await _db.getExerciseHistory(exerciseId);
  }

  /// Get sets for a specific workout
  Future<List<ExerciseSets>> getWorkoutSets(String workoutId) async {
    return await _db.getWorkoutExerciseSets(workoutId);
  }

  /// Get total volume for a specific workout
  Future<double> getWorkoutVolume(String workoutId) async {
    final sets = await _db.getWorkoutSets(workoutId);
    double total = 0;
    for (final set in sets) {
      total += (set.weight * set.reps);
    }
    return total;
  }

  /// Get total volume for the active workout
  double get activeWorkoutVolume {
    double total = 0;
    for (final es in _activeWorkoutSets) {
      for (final set in es.sets) {
        if (set.isCompleted) {
          total += (set.weight * set.reps);
        }
      }
    }
    return total;
  }

  /// Get volume data for the last 7 days
  Future<Map<DateTime, double>> getWeeklyVolumeData() async {
    final now = DateTime.now();
    final Map<DateTime, double> data = {};
    
    // Initialize last 7 days with 0
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      data[date] = 0;
    }
    
    // Fill with actual data
    for (final workout in completedWorkouts) {
      final workoutDate = DateTime(
        workout.startTime.year,
        workout.startTime.month,
        workout.startTime.day,
      );
      
      if (data.containsKey(workoutDate)) {
        final volume = await getWorkoutVolume(workout.id);
        data[workoutDate] = (data[workoutDate] ?? 0) + volume;
      }
    }
    
    return data;
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
