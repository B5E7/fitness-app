import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';
import '../../providers/settings_provider.dart';
import '../workout/active_workout_screen.dart';
import 'workout_detail_screen.dart';

/// Home screen displaying workout history and quick stats
/// 
/// This is the main landing screen showing recent workouts,
/// weekly statistics, and a button to start a new workout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
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
                  'Fitness Tracker',
                  style: AppTheme.headingMedium.copyWith(fontSize: 20),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
              actions: [
                // Show active workout indicator
                if (workoutProvider.hasActiveWorkout)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ActiveWorkoutScreen(),
                          ),
                        );
                      },
                      icon: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      label: const Text('In Progress'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGreen,
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Weekly Stats Card
                  _buildStatsCard(context, workoutProvider),
                  const SizedBox(height: 24),

                  // Recent Workouts Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Workouts', style: AppTheme.headingSmall),
                      if (workoutProvider.workouts.length > 5)
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to full history
                          },
                          child: const Text('See All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Workout List or Empty State
                  if (workoutProvider.completedWorkouts.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...workoutProvider.completedWorkouts
                        .take(10)
                        .map((workout) => _buildWorkoutCard(context, workout)),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(BuildContext context, WorkoutProvider provider) {
    final thisWeekCount = provider.thisWeeksWorkouts
        .where((w) => w.isCompleted)
        .length;
    final todayCount = provider.todaysWorkouts
        .where((w) => w.isCompleted)
        .length;
    final totalWorkouts = provider.completedWorkouts.length;

    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text('This Week', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  thisWeekCount.toString(),
                  'Workouts',
                  AppTheme.primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  todayCount.toString(),
                  'Today',
                  AppTheme.accentGreen,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return _buildStatItem(
                      provider.totalVolume.round().toString(),
                      'Volume (${settings.weightUnitString})',
                      AppTheme.secondaryColor,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.numberMedium.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
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
              Icons.fitness_center,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No workouts yet',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first workout to begin tracking\nyour fitness journey!',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => _showStartWorkoutDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Start Workout'),
      ),
    ],
  ),
);
}

void _showStartWorkoutDialog(BuildContext context) {
final controller = TextEditingController();
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppTheme.cardDark,
    title: Text('New Workout', style: AppTheme.headingSmall),
    content: TextField(
      controller: controller,
      style: AppTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Workout Name (optional)',
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
        onPressed: () async {
          final name = controller.text.trim();
          final provider = context.read<WorkoutProvider>();
          final success = await provider.startWorkout(name: name.isEmpty ? null : name);
          if (success && context.mounted) {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ActiveWorkoutScreen(),
              ),
            );
          }
        },
        child: const Text('Start'),
      ),
    ],
  ),
);
}

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final dateFormat = DateFormat('EEEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: workout),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(workout: workout),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Date icon
                  Hero(
                    tag: 'workout_date_${workout.id}',
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
                            DateFormat('d').format(workout.startTime),
                            style: AppTheme.labelLarge.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(workout.startTime),
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

                  // Workout info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name ?? dateFormat.format(workout.startTime),
                          style: AppTheme.labelLarge.copyWith(
                            fontWeight: workout.name != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (workout.name != null)
                          Text(
                            dateFormat.format(workout.startTime),
                            style: AppTheme.bodySmall.copyWith(fontSize: 10),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(workout.startTime),
                              style: AppTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                              Text(
                                workout.durationString,
                                style: AppTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.fitness_center,
                                size: 14,
                                color: AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              FutureBuilder<double>(
                                future: context.read<WorkoutProvider>().getWorkoutVolume(workout.id),
                                builder: (context, snapshot) {
                                  final volume = snapshot.data ?? 0;
                                  final unit = context.read<SettingsProvider>().weightUnitString;
                                  return Text(
                                    '${volume.round()} $unit',
                                    style: AppTheme.bodySmall,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Arrow
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
