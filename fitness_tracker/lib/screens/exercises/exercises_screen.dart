import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/exercise_provider.dart';
import '../../models/exercise.dart';
import 'add_exercise_screen.dart';

/// Exercise library screen showing all exercises grouped by muscle
/// 
/// Users can browse exercises, filter by muscle group,
/// and add custom exercises.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
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
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        final exercises = _getFilteredExercises(provider);

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.backgroundDark,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Exercises',
                  style: AppTheme.headingMedium.copyWith(fontSize: 20),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _navigateToAddExercise(context),
                ),
              ],
            ),

            // Search bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverToBoxAdapter(
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
            ),

            // Muscle group filter chips
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
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
            ),

            // Exercise list
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (exercises.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildExerciseCard(
                      context,
                      exercises[index],
                      provider,
                    ),
                    childCount: exercises.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Exercise> _getFilteredExercises(ExerciseProvider provider) {
    var exercises = provider.exercises;

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

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    ExerciseProvider provider,
  ) {
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
            // Show exercise details bottom sheet
            _showExerciseDetails(context, exercise, provider);
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: AppTheme.labelLarge,
                            ),
                          ),
                          if (exercise.isCustom)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Custom',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.accentPurple,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
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
                          style: AppTheme.bodySmall.copyWith(
                            color: muscleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(
    BuildContext context,
    Exercise exercise,
    ExerciseProvider provider,
  ) {
    final muscleColor = AppTheme.muscleGroupColors[exercise.muscleGroup] ??
        AppTheme.primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Exercise header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: muscleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      MuscleGroups.getIcon(exercise.muscleGroup),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: AppTheme.headingSmall),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: muscleColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          exercise.muscleGroup,
                          style: AppTheme.bodySmall.copyWith(color: muscleColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            if (exercise.description != null) ...[
              Text('Description', style: AppTheme.labelLarge),
              const SizedBox(height: 8),
              Text(exercise.description!, style: AppTheme.bodyMedium),
              const SizedBox(height: 20),
            ],

            // Actions for custom exercises
            if (exercise.isCustom) ...[
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _navigateToEditExercise(context, exercise);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                      ),
                      onPressed: () => _confirmDeleteExercise(
                        ctx,
                        exercise,
                        provider,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _navigateToAddExercise(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddExerciseScreen(),
      ),
    );
  }

  void _navigateToEditExercise(BuildContext context, Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExerciseScreen(exercise: exercise),
      ),
    );
  }

  void _confirmDeleteExercise(
    BuildContext ctx,
    Exercise exercise,
    ExerciseProvider provider,
  ) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Delete Exercise', style: AppTheme.headingSmall),
        content: Text(
          'Are you sure you want to delete "${exercise.name}"?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await provider.deleteExercise(exercise.id);
              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
