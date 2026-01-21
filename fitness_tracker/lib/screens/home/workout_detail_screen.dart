import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/workout.dart';
import '../../models/workout_set.dart';
import '../workout/active_workout_screen.dart';

/// Workout detail screen showing exercises and sets for a completed workout
class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  List<ExerciseSets>? _exerciseSets;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutSets();
  }

  Future<void> _loadWorkoutSets() async {
    final provider = context.read<WorkoutProvider>();
    final sets = await provider.getWorkoutSets(widget.workout.id);
    setState(() {
      _exerciseSets = sets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Workout Details', style: AppTheme.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
            onPressed: () => _editWorkout(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout header card
                  Container(
                    decoration: AppTheme.glassDecoration,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'workout_date_${widget.workout.id}',
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('d').format(widget.workout.startTime),
                                      style: AppTheme.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM').format(widget.workout.startTime),
                                      style: AppTheme.bodySmall.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.workout.name ?? dateFormat.format(widget.workout.startTime),
                                    style: AppTheme.labelLarge.copyWith(
                                      fontWeight: widget.workout.name != null ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.workout.name != null 
                                      ? 'Started at ${timeFormat.format(widget.workout.startTime)} on ${DateFormat('MMM d').format(widget.workout.startTime)}'
                                      : 'Started at ${timeFormat.format(widget.workout.startTime)}',
                                    style: AppTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              Icons.timer_outlined,
                              widget.workout.durationString,
                              'Duration',
                            ),
                            _buildStatColumn(
                              Icons.fitness_center,
                              '${_exerciseSets?.length ?? 0}',
                              'Exercises',
                            ),
                            _buildStatColumn(
                              Icons.repeat,
                              '${_totalSets}',
                              'Sets',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exercises section
                  Text('Exercises', style: AppTheme.headingSmall),
                  const SizedBox(height: 16),

                  if (_exerciseSets == null || _exerciseSets!.isEmpty)
                    _buildEmptyExercises()
                  else
                    ..._exerciseSets!.map(_buildExerciseCard),
                ],
              ),
            ),
    );
  }

  int get _totalSets {
    if (_exerciseSets == null) return 0;
    return _exerciseSets!.fold(0, (sum, es) => sum + es.sets.length);
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.labelLarge),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  Widget _buildEmptyExercises() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises recorded',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseSets exerciseSets) {
    final muscleColor = AppTheme.muscleGroupColors[exerciseSets.muscleGroup] ??
        AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                          style: AppTheme.bodySmall.copyWith(
                            color: muscleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (exerciseSets.bestSet != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Best Set', style: AppTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        '${exerciseSets.bestSet!.weightDisplay} × ${exerciseSets.bestSet!.reps}',
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Sets table
          Container(
            color: AppTheme.surfaceDark,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: AppTheme.elevatedDark,
                  ),
                  children: [
                    _buildTableCell('Set', isHeader: true),
                    _buildTableCell('Weight', isHeader: true),
                    _buildTableCell('Reps', isHeader: true),
                  ],
                ),
                // Data rows
                ...exerciseSets.sets.map((set) => TableRow(
                  children: [
                    _buildTableCell('${set.setNumber}'),
                    _buildTableCell(set.weightDisplay),
                    _buildTableCell('${set.reps}'),
                  ],
                )),
              ],
            ),
          ),

          // Total volume
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.elevatedDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Volume', style: AppTheme.bodySmall),
                Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return Text(
                      '${exerciseSets.totalVolume.toStringAsFixed(0)} ${settings.weightUnitString}',
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: isHeader
            ? AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold)
            : AppTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  void _editWorkout(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    provider.editWorkout(widget.workout);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ActiveWorkoutScreen(isEditing: true),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Delete Workout', style: AppTheme.headingSmall),
        content: Text(
          'Are you sure you want to delete this workout? This action cannot be undone.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            onPressed: () async {
              final provider = context.read<WorkoutProvider>();
              await provider.deleteWorkout(widget.workout.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
