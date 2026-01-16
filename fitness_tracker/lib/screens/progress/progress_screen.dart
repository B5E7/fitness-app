import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/volume_chart_widget.dart';

/// Progress screen showing workout statistics and trends
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkoutProvider, ExerciseProvider>(
      builder: (context, workoutProvider, exerciseProvider, child) {
        final completedWorkouts = workoutProvider.completedWorkouts;
        final totalWorkouts = completedWorkouts.length;
        
        // Calculate stats
        final thisWeekWorkouts = workoutProvider.thisWeeksWorkouts
            .where((w) => w.isCompleted)
            .length;
        
        // Calculate total workout time
        Duration totalWorkoutTime = Duration.zero;
        for (final workout in completedWorkouts) {
          if (workout.duration != null) {
            totalWorkoutTime += workout.duration!;
          }
        }

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
                  'Progress',
                  style: AppTheme.headingMedium.copyWith(fontSize: 20),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),

            // Stats overview
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main stats card
                    Container(
                      decoration: AppTheme.glassDecoration,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.analytics_outlined,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text('Your Stats', style: AppTheme.headingSmall),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  totalWorkouts.toString(),
                                  'Total\nWorkouts',
                                  Icons.fitness_center,
                                  AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  thisWeekWorkouts.toString(),
                                  'This\nWeek',
                                  Icons.calendar_today,
                                  AppTheme.accentGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  _formatTotalTime(totalWorkoutTime),
                                  'Total\nTime',
                                  Icons.timer_outlined,
                                  AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Volume chart
                    FutureBuilder<Map<DateTime, double>>(
                      future: workoutProvider.getWeeklyVolumeData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 240,
                            decoration: AppTheme.cardDecoration,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        return VolumeChartWidget(data: snapshot.data ?? {});
                      },
                    ),

                    const SizedBox(height: 24),

                    // Exercise breakdown
                    Text('Exercise Breakdown', style: AppTheme.headingSmall),
                    const SizedBox(height: 16),
                    
                    if (exerciseProvider.exercises.isEmpty)
                      _buildEmptyState('No exercises yet')
                    else
                      ...exerciseProvider.exercisesByMuscleGroup.entries.map(
                        (entry) => _buildMuscleGroupCard(
                          entry.key,
                          entry.value.length,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Recent activity
                    Text('Recent Activity', style: AppTheme.headingSmall),
                    const SizedBox(height: 16),

                    if (completedWorkouts.isEmpty)
                      _buildEmptyState('No workouts yet. Start training!')
                    else
                      _buildActivityTimeline(completedWorkouts.take(7).toList()),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTotalTime(Duration duration) {
    final hours = duration.inHours;
    if (hours >= 1) {
      return '${hours}h';
    }
    return '${duration.inMinutes}m';
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.numberMedium.copyWith(
              color: color,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupCard(String muscleGroup, int exerciseCount) {
    final color = AppTheme.muscleGroupColors[muscleGroup] ?? AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _getMuscleEmoji(muscleGroup),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(muscleGroup, style: AppTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  '$exerciseCount exercises',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$exerciseCount',
              style: AppTheme.labelLarge.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _getMuscleEmoji(String muscleGroup) {
    switch (muscleGroup) {
      case 'Chest':
        return '💪';
      case 'Back':
        return '🔙';
      case 'Legs':
        return '🦵';
      case 'Shoulders':
        return '🎯';
      case 'Arms':
        return '💪';
      case 'Core':
        return '🎯';
      default:
        return '🏋️';
    }
  }

  Widget _buildActivityTimeline(List workouts) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: workouts.asMap().entries.map((entry) {
          final index = entry.key;
          final workout = entry.value;
          final isLast = index == workouts.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppTheme.accentGreen
                          : AppTheme.cardDark,
                      border: Border.all(
                        color: index == 0
                            ? AppTheme.accentGreen
                            : AppTheme.textTertiary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: AppTheme.textTertiary.withOpacity(0.3),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Workout info
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(workout.startTime),
                        style: AppTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.durationString,
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.trending_up,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
