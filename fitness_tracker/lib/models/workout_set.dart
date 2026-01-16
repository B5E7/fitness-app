/// WorkoutSet model representing a single set within a workout
/// 
/// Each set belongs to a workout and an exercise, and tracks
/// the weight, reps, and whether the set was completed.
class WorkoutSet {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int setNumber;
  final double weight;
  final int reps;
  final bool isCompleted;
  final DateTime? completedAt;

  WorkoutSet({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Create a WorkoutSet from a database map
  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as String,
      workoutId: map['workout_id'] as String,
      exerciseId: map['exercise_id'] as String,
      setNumber: map['set_number'] as int,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at'] as String) 
          : null,
    );
  }

  /// Convert WorkoutSet to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Create a copy of this set with some fields changed
  WorkoutSet copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    int? setNumber,
    double? weight,
    int? reps,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Format weight for display (e.g., "50 kg" or "50.5 kg")
  String get weightDisplay {
    if (weight == weight.roundToDouble()) {
      return '${weight.toInt()} kg';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  @override
  String toString() {
    return 'WorkoutSet(id: $id, setNumber: $setNumber, weight: $weight, reps: $reps)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Helper class to group sets by exercise within a workout
class ExerciseSets {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final List<WorkoutSet> sets;

  ExerciseSets({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
  });

  /// Total volume for this exercise (weight × reps for all sets)
  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  /// Number of completed sets
  int get completedSets {
    return sets.where((s) => s.isCompleted).length;
  }

  /// Best set (highest weight)
  WorkoutSet? get bestSet {
    if (sets.isEmpty) return null;
    return sets.reduce((a, b) => a.weight > b.weight ? a : b);
  }
}
