/// Exercise model representing a single exercise in the library
/// 
/// Each exercise has a name, muscle group, and can be either
/// a built-in exercise or a custom one created by the user.
class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final bool isCustom;
  final String? iconName;
  final String? description;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.isCustom = false,
    this.iconName,
    this.description,
  });

  /// Create an Exercise from a database map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscle_group'] as String,
      isCustom: (map['is_custom'] as int) == 1,
      iconName: map['icon_name'] as String?,
      description: map['description'] as String?,
    );
  }

  /// Convert Exercise to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'is_custom': isCustom ? 1 : 0,
      'icon_name': iconName,
      'description': description,
    };
  }

  /// Create a copy of this exercise with some fields changed
  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    bool? isCustom,
    String? iconName,
    String? description,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      isCustom: isCustom ?? this.isCustom,
      iconName: iconName ?? this.iconName,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, muscleGroup: $muscleGroup, isCustom: $isCustom)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Available muscle groups for exercises
class MuscleGroups {
  static const String chest = 'Chest';
  static const String back = 'Back';
  static const String legs = 'Legs';
  static const String shoulders = 'Shoulders';
  static const String arms = 'Arms';
  static const String core = 'Core';

  static const List<String> all = [
    chest,
    back,
    legs,
    shoulders,
    arms,
    core,
  ];

  /// Get icon for muscle group
  static String getIcon(String muscleGroup) {
    switch (muscleGroup) {
      case chest:
        return '💪';
      case back:
        return '🔙';
      case legs:
        return '🦵';
      case shoulders:
        return '🎯';
      case arms:
        return '💪';
      case core:
        return '🎯';
      default:
        return '🏋️';
    }
  }
}
