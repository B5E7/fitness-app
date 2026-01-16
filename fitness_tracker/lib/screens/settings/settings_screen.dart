import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';
import '../../database/database_helper.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Settings',
              style: AppTheme.headingMedium.copyWith(fontSize: 20),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          ),
        ),

        // Settings content
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // App Info Section
              Text('App', style: AppTheme.headingSmall),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Feedback',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help section coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Data Section
              Text('Data', style: AppTheme.headingSmall),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Export Data',
                  subtitle: 'Save your workout data',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming in v2!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.delete_outline,
                  title: 'Clear All Data',
                  subtitle: 'Delete all workouts and custom exercises',
                  titleColor: AppTheme.error,
                  onTap: () => _confirmClearData(context),
                ),
              ]),
              const SizedBox(height: 24),

              // Preferences Section
              Text('Preferences', style: AppTheme.headingSmall),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'Dark (default)',
                  trailing: const Icon(
                    Icons.brightness_2,
                    color: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('More themes coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDivider(),
                Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return _buildSettingsTile(
                      icon: Icons.straighten,
                      title: 'Weight Unit',
                      subtitle: settings.weightUnit == WeightUnit.kg
                          ? 'Kilograms (kg)'
                          : 'Pounds (lbs)',
                      onTap: () => settings.toggleWeightUnit(),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 40),

              // Footer
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fitness Tracker',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Built with Flutter 💙',
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Made for gym-goers who want simple logging',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.elevatedDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: titleColor ?? AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.labelLarge.copyWith(
                        color: titleColor ?? AppTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textTertiary,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text('Fitness Tracker', style: AppTheme.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'A simple, offline-first fitness tracking app for logging your gym workouts.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: AppTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Track workout sessions'),
            _buildFeatureItem('Log sets, reps, and weights'),
            _buildFeatureItem('30+ built-in exercises'),
            _buildFeatureItem('Create custom exercises'),
            _buildFeatureItem('View workout history'),
            _buildFeatureItem('Offline-first, no account needed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.accentGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Clear All Data?', style: AppTheme.headingSmall),
        content: Text(
          'This will delete all your workouts and custom exercises. This action cannot be undone.',
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
              Navigator.of(ctx).pop();
              
              // Clear SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (context.mounted) {
                // Reload providers to initial state
                await context.read<ExerciseProvider>().loadExercises();
                await context.read<WorkoutProvider>().loadWorkouts();
                await context.read<SettingsProvider>().init();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              }
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
