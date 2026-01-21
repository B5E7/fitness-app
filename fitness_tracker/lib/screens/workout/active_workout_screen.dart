import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/workout_set.dart';
import '../../providers/rest_timer_provider.dart';
import '../../widgets/rest_timer_widget.dart';
import 'exercise_picker_screen.dart';

/// Active workout screen for logging sets during a workout session
/// 
/// This screen displays the current workout with all exercises
/// and allows the user to add sets, update weight/reps, and complete the workout.
class ActiveWorkoutScreen extends StatefulWidget {
  final bool isEditing;
  const ActiveWorkoutScreen({super.key, this.isEditing = false});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  bool _showTimer = true;

  @override
  void dispose() {
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    for (final controller in _repsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        if (!provider.hasActiveWorkout) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text('Workout', style: AppTheme.headingSmall),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 24),
                  Text('No active workout', style: AppTheme.headingSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new workout to begin logging',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await provider.startWorkout();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Workout'),
                  ),
                ],
              ),
            ),
          );
        }

        final workout = provider.activeWorkout!;
        final duration = DateTime.now().difference(workout.startTime);

        return Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(widget.isEditing ? Icons.arrow_back : Icons.close),
              onPressed: () {
                if (widget.isEditing) {
                  provider.clearActiveWorkout();
                  Navigator.of(context).pop();
                } else {
                  _confirmCancel(context, provider);
                }
              },
            ),
            title: InkWell(
              onTap: () => _editWorkoutName(context, provider),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          workout.name ?? 'Workout',
                          style: AppTheme.headingSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 14, color: AppTheme.textTertiary),
                    ],
                  ),
                  if (_showTimer && !widget.isEditing)
                    Text(
                      _formatDuration(duration),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.accentGreen,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: provider.activeWorkoutSets.isEmpty
                    ? null
                    : () => _finishWorkout(context, provider),
                icon: Icon(widget.isEditing ? Icons.save : Icons.check),
                label: Text(widget.isEditing ? 'Save' : 'Finish'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Exercises list
              Expanded(
                child: provider.activeWorkoutSets.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: provider.activeWorkoutSets.length,
                        itemBuilder: (context, index) {
                          return _buildExerciseCard(
                            context,
                            provider.activeWorkoutSets[index],
                            provider,
                          );
                        },
                      ),
              ),

              // Rest timer (visible only when active)
              const RestTimerWidget(),

              // Add exercise button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _addExercise(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No exercises yet',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises to start logging your workout',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addExercise(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ExerciseSets exerciseSets,
    WorkoutProvider provider,
  ) {
    final muscleColor =
        AppTheme.muscleGroupColors[exerciseSets.muscleGroup] ??
            AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: muscleColor, width: 4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseSets.exerciseName,
                        style: AppTheme.labelLarge,
                      ),
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
                          exerciseSets.muscleGroup,
                          style: AppTheme.bodySmall.copyWith(color: muscleColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<WorkoutSet?>(
                        future: provider.getLastPerformance(exerciseSets.exerciseId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final lastSet = snapshot.data!;
                            return Text(
                              'Previous: ${lastSet.weightDisplay} × ${lastSet.reps}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.accentGreen.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                  onPressed: () => _confirmRemoveExercise(
                    context,
                    exerciseSets.exerciseId,
                    exerciseSets.exerciseName,
                    provider,
                  ),
                ),
              ],
            ),
          ),

          // Sets header
          Container(
            color: AppTheme.elevatedDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text('Set', style: AppTheme.bodySmall),
                ),
                Expanded(
                  child: Center(
                    child: Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        final usePlates = exerciseSets.sets.isNotEmpty && exerciseSets.sets.first.usePlates;
                        return InkWell(
                          onTap: () {
                            // Toggle all sets for this exercise
                            for (final set in exerciseSets.sets) {
                              provider.updateSet(set.copyWith(usePlates: !usePlates));
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                usePlates ? 'Plates' : 'Weight (${settings.weightUnitString})',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.sync, size: 12, color: AppTheme.primaryColor),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Reps', style: AppTheme.bodySmall),
                  ),
                ),
                const SizedBox(width: 48), // Space for checkbox
              ],
            ),
          ),

          // Sets list
          ...exerciseSets.sets.map((set) => _buildSetRow(set, provider)),

          // Add set button
          InkWell(
            onTap: () => provider.addSet(exerciseSets.exerciseId),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Set',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(WorkoutSet set, WorkoutProvider provider) {
    // Get or create controllers for this set
    _weightControllers.putIfAbsent(
      set.id,
      () => TextEditingController(
        text: set.weight > 0 ? set.weight.toString() : '',
      ),
    );
    _repsControllers.putIfAbsent(
      set.id,
      () => TextEditingController(
        text: set.reps > 0 ? set.reps.toString() : '',
      ),
    );

    final weightController = _weightControllers[set.id]!;
    final repsController = _repsControllers[set.id]!;

    return Dismissible(
      key: Key(set.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteSet(set.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: set.isCompleted
              ? AppTheme.accentGreen.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // Set number
            SizedBox(
              width: 40,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: set.isCompleted
                      ? AppTheme.accentGreen
                      : AppTheme.elevatedDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${set.setNumber}',
                    style: AppTheme.labelLarge.copyWith(
                      color: set.isCompleted ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Weight input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.elevatedDark,
                    hintText: set.usePlates ? 'Plates' : '0',
                    hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value) ?? 0;
                    provider.updateSet(set.copyWith(weight: weight));
                  },
                ),
              ),
            ),

            // Reps input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.elevatedDark,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    final reps = int.tryParse(value) ?? 0;
                    provider.updateSet(set.copyWith(reps: reps));
                  },
                ),
              ),
            ),

            // Complete checkbox
            SizedBox(
              width: 48,
              child: Checkbox(
                value: set.isCompleted,
                onChanged: (value) {
                  final isCompleted = value ?? false;
                  provider.updateSet(set.copyWith(
                    isCompleted: isCompleted,
                    completedAt: isCompleted ? DateTime.now() : null,
                  ));

                  // Start rest timer if set is completed
                  if (isCompleted) {
                    context.read<RestTimerProvider>().startTimer();
                  } else {
                    context.read<RestTimerProvider>().stopTimer();
                  }
                },
                activeColor: AppTheme.accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addExercise(BuildContext context) async {
    final exerciseProvider = context.read<ExerciseProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    final selectedExercise = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => ExercisePickerScreen(
          excludedExerciseIds:
              workoutProvider.activeWorkoutSets.map((e) => e.exerciseId).toList(),
        ),
      ),
    );

    if (selectedExercise != null) {
      final exercise = exerciseProvider.getExerciseById(selectedExercise);
      if (exercise != null) {
        await workoutProvider.addExerciseToWorkout(exercise);
      }
    }
  }

  void _confirmRemoveExercise(
    BuildContext context,
    String exerciseId,
    String exerciseName,
    WorkoutProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Remove Exercise', style: AppTheme.headingSmall),
        content: Text(
          'Remove "$exerciseName" from this workout?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await provider.removeExerciseFromWorkout(exerciseId);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _editWorkoutName(BuildContext context, WorkoutProvider provider) {
    if (provider.activeWorkout == null) return;
    final controller = TextEditingController(text: provider.activeWorkout!.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Edit Workout Name', style: AppTheme.headingSmall),
        content: TextField(
          controller: controller,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Workout Name',
            hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.textTertiary),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              provider.updateWorkout(provider.activeWorkout!.copyWith(name: newName.isEmpty ? null : newName));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _finishWorkout(BuildContext context, WorkoutProvider provider) {
    final bool isCompleted = provider.activeWorkout?.isCompleted ?? false;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text(widget.isEditing ? 'Save Changes' : 'Finish Workout', style: AppTheme.headingSmall),
        content: Text(
          widget.isEditing 
            ? 'Save changes to this workout?'
            : 'Complete this workout session?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            onPressed: () async {
              if (widget.isEditing) {
                // If it was already completed, just update it.
                // If it wasn't, finish it.
                if (isCompleted) {
                  // Already completed, just clear active state
                  provider.clearActiveWorkout();
                } else {
                  await provider.finishWorkout();
                }
              } else {
                await provider.finishWorkout();
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(widget.isEditing ? 'Save' : 'Finish'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Discard Workout?', style: AppTheme.headingSmall),
        content: Text(
          'Are you sure you want to discard this workout? All progress will be lost.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Working'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await provider.cancelWorkout();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
