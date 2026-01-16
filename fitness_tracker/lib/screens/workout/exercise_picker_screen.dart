import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/exercise.dart';
import '../../models/workout_set.dart';

/// Exercise picker screen for selecting exercises to add to a workout
/// 
/// Shows all exercises grouped by muscle group with search functionality.
class ExercisePickerScreen extends StatefulWidget {
  final List<String> excludedExerciseIds;

  const ExercisePickerScreen({
    super.key,
    this.excludedExerciseIds = const [],
  });

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  String? _selectedMuscleGroup;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Select Exercise', style: AppTheme.headingSmall),
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, child) {
          final exercises = _getFilteredExercises(provider);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Muscle group filter
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(null, 'All'),
                      ...MuscleGroups.all.map(
                        (muscle) => _buildFilterChip(muscle, muscle),
                      ),
                    ],
                  ),
                ),
              ),

              // Exercise list
              Expanded(
                child: exercises.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          return _buildExerciseItem(exercises[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Exercise> _getFilteredExercises(ExerciseProvider provider) {
    var exercises = provider.exercises;

    // Exclude already added exercises
    exercises = exercises
        .where((e) => !widget.excludedExerciseIds.contains(e.id))
        .toList();

    // Filter by muscle group
    if (_selectedMuscleGroup != null) {
      exercises = exercises
          .where((e) => e.muscleGroup == _selectedMuscleGroup)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where((e) => e.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return exercises;
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _selectedMuscleGroup == value;
    final muscleColor = value != null
        ? AppTheme.muscleGroupColors[value] ?? AppTheme.primaryColor
        : AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMuscleGroup = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? muscleColor : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? muscleColor : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or filter',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    final muscleColor = AppTheme.muscleGroupColors[exercise.muscleGroup] ??
        AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pop(exercise.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Muscle group indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: muscleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      MuscleGroups.getIcon(exercise.muscleGroup),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: AppTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: muscleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          exercise.muscleGroup,
                          style: AppTheme.bodySmall.copyWith(color: muscleColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<WorkoutSet?>(
                        future: context.read<WorkoutProvider>().getLastPerformance(exercise.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final lastSet = snapshot.data!;
                            return Text(
                              'Last: ${lastSet.weightDisplay} × ${lastSet.reps}',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.accentGreen),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),

                // Add icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
