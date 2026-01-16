/// Workout model representing a single workout session
/// 
/// A workout contains multiple exercises with their sets,
/// and tracks the start and end time of the session.
class Workout {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final bool isCompleted;

  Workout({
    required this.id,
    required this.startTime,
    this.endTime,
    this.notes,
    this.isCompleted = false,
  });

  /// Calculate the duration of the workout
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Get formatted duration string (e.g., "45 min")
  String get durationString {
    final dur = duration;
    if (dur == null) return 'In progress';
    
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes} min';
  }

  /// Create a Workout from a database map
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time'] as String) 
          : null,
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  /// Convert Workout to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  /// Create a copy of this workout with some fields changed
  Workout copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    bool? isCompleted,
  }) {
    return Workout(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Workout(id: $id, startTime: $startTime, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
