import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';

/// Database helper class for managing data storage
/// 
/// Uses SharedPreferences for simple persistence on web and mobile.
/// This allows data to persist across app restarts and browser reloads.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // In-memory storage
  final Map<String, Exercise> _exercises = {};
  final Map<String, Workout> _workouts = {};
  final Map<String, WorkoutSet> _workoutSets = {};
  bool _isInitialized = false;

  DatabaseHelper._init();

  /// Initialize the database and load saved data
  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load exercises
    final exercisesJson = prefs.getString('exercises');
    if (exercisesJson != null) {
      final Map<String, dynamic> data = json.decode(exercisesJson);
      data.forEach((key, value) {
        _exercises[key] = Exercise.fromMap(value);
      });
    } else {
      // Seed default exercises if none saved
      await _seedExercises();
    }
    
    // Load workouts
    final workoutsJson = prefs.getString('workouts');
    if (workoutsJson != null) {
      final Map<String, dynamic> data = json.decode(workoutsJson);
      data.forEach((key, value) {
        _workouts[key] = Workout.fromMap(value);
      });
    }
    
    // Load workout sets
    final setsJson = prefs.getString('workout_sets');
    if (setsJson != null) {
      final Map<String, dynamic> data = json.decode(setsJson);
      data.forEach((key, value) {
        _workoutSets[key] = WorkoutSet.fromMap(value);
      });
    }
    
    _isInitialized = true;
  }

  /// Save all data to SharedPreferences
  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save exercises
    final exercisesData = _exercises.map((key, value) => MapEntry(key, value.toMap()));
    await prefs.setString('exercises', json.encode(exercisesData));
    
    // Save workouts
    final workoutsData = _workouts.map((key, value) => MapEntry(key, value.toMap()));
    await prefs.setString('workouts', json.encode(workoutsData));
    
    // Save workout sets
    final setsData = _workoutSets.map((key, value) => MapEntry(key, value.toMap()));
    await prefs.setString('workout_sets', json.encode(setsData));
  }

  /// Seed the database with default exercises
  Future<void> _seedExercises() async {
    final defaultExercises = [
      // Chest exercises
      Exercise(id: 'chest_1', name: 'Bench Press', muscleGroup: 'Chest', description: 'Classic chest exercise using a barbell'),
      Exercise(id: 'chest_2', name: 'Incline Bench Press', muscleGroup: 'Chest', description: 'Upper chest focused press'),
      Exercise(id: 'chest_3', name: 'Dumbbell Fly', muscleGroup: 'Chest', description: 'Isolation exercise for chest'),
      Exercise(id: 'chest_4', name: 'Push Ups', muscleGroup: 'Chest', description: 'Bodyweight chest exercise'),
      Exercise(id: 'chest_5', name: 'Cable Crossover', muscleGroup: 'Chest', description: 'Cable machine chest isolation'),
      
      // Back exercises
      Exercise(id: 'back_1', name: 'Deadlift', muscleGroup: 'Back', description: 'Compound movement for back and legs'),
      Exercise(id: 'back_2', name: 'Lat Pulldown', muscleGroup: 'Back', description: 'Machine exercise for lats'),
      Exercise(id: 'back_3', name: 'Barbell Row', muscleGroup: 'Back', description: 'Bent over row for back thickness'),
      Exercise(id: 'back_4', name: 'Pull Ups', muscleGroup: 'Back', description: 'Bodyweight lat exercise'),
      Exercise(id: 'back_5', name: 'Seated Cable Row', muscleGroup: 'Back', description: 'Cable machine for mid-back'),
      
      // Legs exercises
      Exercise(id: 'legs_1', name: 'Squat', muscleGroup: 'Legs', description: 'King of leg exercises'),
      Exercise(id: 'legs_2', name: 'Leg Press', muscleGroup: 'Legs', description: 'Machine press for quads'),
      Exercise(id: 'legs_3', name: 'Romanian Deadlift', muscleGroup: 'Legs', description: 'Hamstring focused deadlift'),
      Exercise(id: 'legs_4', name: 'Leg Curl', muscleGroup: 'Legs', description: 'Isolation for hamstrings'),
      Exercise(id: 'legs_5', name: 'Leg Extension', muscleGroup: 'Legs', description: 'Isolation for quads'),
      Exercise(id: 'legs_6', name: 'Calf Raises', muscleGroup: 'Legs', description: 'Standing or seated calf exercise'),
      
      // Shoulders exercises
      Exercise(id: 'shoulders_1', name: 'Overhead Press', muscleGroup: 'Shoulders', description: 'Standing barbell shoulder press'),
      Exercise(id: 'shoulders_2', name: 'Lateral Raise', muscleGroup: 'Shoulders', description: 'Side delt isolation'),
      Exercise(id: 'shoulders_3', name: 'Front Raise', muscleGroup: 'Shoulders', description: 'Front delt isolation'),
      Exercise(id: 'shoulders_4', name: 'Face Pull', muscleGroup: 'Shoulders', description: 'Rear delt and rotator cuff'),
      Exercise(id: 'shoulders_5', name: 'Arnold Press', muscleGroup: 'Shoulders', description: 'Rotating dumbbell press'),
      
      // Arms exercises
      Exercise(id: 'arms_1', name: 'Bicep Curl', muscleGroup: 'Arms', description: 'Classic bicep exercise'),
      Exercise(id: 'arms_2', name: 'Hammer Curl', muscleGroup: 'Arms', description: 'Neutral grip bicep curl'),
      Exercise(id: 'arms_3', name: 'Tricep Pushdown', muscleGroup: 'Arms', description: 'Cable tricep isolation'),
      Exercise(id: 'arms_4', name: 'Skull Crusher', muscleGroup: 'Arms', description: 'Lying tricep extension'),
      Exercise(id: 'arms_5', name: 'Preacher Curl', muscleGroup: 'Arms', description: 'Isolated bicep curl on bench'),
      
      // Core exercises
      Exercise(id: 'core_1', name: 'Plank', muscleGroup: 'Core', description: 'Isometric core hold'),
      Exercise(id: 'core_2', name: 'Crunches', muscleGroup: 'Core', description: 'Basic ab exercise'),
      Exercise(id: 'core_3', name: 'Leg Raises', muscleGroup: 'Core', description: 'Lower ab focused'),
      Exercise(id: 'core_4', name: 'Russian Twist', muscleGroup: 'Core', description: 'Rotational core exercise'),
      Exercise(id: 'core_5', name: 'Cable Woodchop', muscleGroup: 'Core', description: 'Functional rotational movement'),
    ];

    for (final exercise in defaultExercises) {
      _exercises[exercise.id] = exercise;
    }
    
    await _saveAll();
  }

  // ============== Exercise Operations ==============

  /// Get all exercises, optionally filtered by muscle group
  Future<List<Exercise>> getExercises({String? muscleGroup}) async {
    await init();
    
    var exercises = _exercises.values.toList();
    
    if (muscleGroup != null) {
      exercises = exercises.where((e) => e.muscleGroup == muscleGroup).toList();
    }
    
    exercises.sort((a, b) {
      final groupCompare = a.muscleGroup.compareTo(b.muscleGroup);
      if (groupCompare != 0) return groupCompare;
      return a.name.compareTo(b.name);
    });

    return exercises;
  }

  /// Get a single exercise by ID
  Future<Exercise?> getExercise(String id) async {
    await init();
    return _exercises[id];
  }

  /// Insert a new exercise
  Future<void> insertExercise(Exercise exercise) async {
    await init();
    _exercises[exercise.id] = exercise;
    await _saveAll();
  }

  /// Update an existing exercise
  Future<void> updateExercise(Exercise exercise) async {
    await init();
    _exercises[exercise.id] = exercise;
    await _saveAll();
  }

  /// Delete an exercise
  Future<void> deleteExercise(String id) async {
    await init();
    _exercises.remove(id);
    await _saveAll();
  }

  // ============== Workout Operations ==============

  /// Get all workouts, ordered by date
  Future<List<Workout>> getWorkouts() async {
    await init();
    final workouts = _workouts.values.toList();
    workouts.sort((a, b) => b.startTime.compareTo(a.startTime));
    return workouts;
  }

  /// Get a single workout by ID
  Future<Workout?> getWorkout(String id) async {
    await init();
    return _workouts[id];
  }

  /// Insert a new workout
  Future<void> insertWorkout(Workout workout) async {
    await init();
    _workouts[workout.id] = workout;
    await _saveAll();
  }

  /// Update an existing workout
  Future<void> updateWorkout(Workout workout) async {
    await init();
    _workouts[workout.id] = workout;
    await _saveAll();
  }

  /// Delete a workout and all its sets
  Future<void> deleteWorkout(String id) async {
    await init();
    _workouts.remove(id);
    
    // Remove all sets for this workout
    _workoutSets.removeWhere((key, set) => set.workoutId == id);
    await _saveAll();
  }

  // ============== WorkoutSet Operations ==============

  /// Get all sets for a workout
  Future<List<WorkoutSet>> getWorkoutSets(String workoutId) async {
    await init();
    
    final sets = _workoutSets.values
        .where((s) => s.workoutId == workoutId)
        .toList();
    
    sets.sort((a, b) {
      final exerciseCompare = a.exerciseId.compareTo(b.exerciseId);
      if (exerciseCompare != 0) return exerciseCompare;
      return a.setNumber.compareTo(b.setNumber);
    });

    return sets;
  }

  /// Get sets grouped by exercise for a workout
  Future<List<ExerciseSets>> getWorkoutExerciseSets(String workoutId) async {
    await init();
    final sets = await getWorkoutSets(workoutId);
    
    // Group sets by exercise
    final Map<String, List<WorkoutSet>> grouped = {};
    for (final set in sets) {
      grouped.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    // Build ExerciseSets with exercise details
    final result = <ExerciseSets>[];
    for (final entry in grouped.entries) {
      final exercise = await getExercise(entry.key);
      if (exercise != null) {
        result.add(ExerciseSets(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          muscleGroup: exercise.muscleGroup,
          sets: entry.value,
        ));
      }
    }

    return result;
  }

  /// Insert a new workout set
  Future<void> insertWorkoutSet(WorkoutSet workoutSet) async {
    await init();
    _workoutSets[workoutSet.id] = workoutSet;
    await _saveAll();
  }

  /// Update an existing workout set
  Future<void> updateWorkoutSet(WorkoutSet workoutSet) async {
    await init();
    _workoutSets[workoutSet.id] = workoutSet;
    await _saveAll();
  }

  /// Delete a workout set
  Future<void> deleteWorkoutSet(String id) async {
    await init();
    _workoutSets.remove(id);
    await _saveAll();
  }

  /// Get the last performance for an exercise (most recent completed set)
  Future<WorkoutSet?> getLastPerformance(String exerciseId) async {
    await init();
    
    final completedSets = _workoutSets.values
        .where((s) => s.exerciseId == exerciseId && s.isCompleted)
        .toList();
    
    if (completedSets.isEmpty) return null;
    
    // Sort by completion time, newest first
    completedSets.sort((a, b) {
      if (a.completedAt == null && b.completedAt == null) return 0;
      if (a.completedAt == null) return 1;
      if (b.completedAt == null) return -1;
      return b.completedAt!.compareTo(a.completedAt!);
    });

    return completedSets.first;
  }

  /// Get exercise history (all completed sets for an exercise)
  Future<List<WorkoutSet>> getExerciseHistory(String exerciseId, {int limit = 50}) async {
    await init();
    
    final completedSets = _workoutSets.values
        .where((s) => s.exerciseId == exerciseId && s.isCompleted)
        .toList();
    
    // Sort by completion time, newest first
    completedSets.sort((a, b) {
      if (a.completedAt == null && b.completedAt == null) return 0;
      if (a.completedAt == null) return 1;
      if (b.completedAt == null) return -1;
      return b.completedAt!.compareTo(a.completedAt!);
    });

    return completedSets.take(limit).toList();
  }

  /// Close the database (no-op for SharedPreferences)
  Future<void> close() async {
    // No-op
  }
}
