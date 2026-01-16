import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/exercise_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/rest_timer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/exercises/exercises_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/workout/active_workout_screen.dart';

/// Main app widget with navigation and provider setup
class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => RestTimerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Fitness Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExercisesScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load exercises and workouts on app start
    final exerciseProvider = context.read<ExerciseProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await exerciseProvider.loadExercises();
    await workoutProvider.loadWorkouts();
    await settingsProvider.init();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton(
          onPressed: () async {
            if (provider.hasActiveWorkout) {
              // Navigate to active workout
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ActiveWorkoutScreen(),
                ),
              );
            } else {
              // Start new workout
              await provider.startWorkout();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ActiveWorkoutScreen(),
                  ),
                );
              }
            }
          },
          elevation: 8,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: provider.hasActiveWorkout
                ? const Icon(Icons.play_arrow, key: ValueKey('play'))
                : const Icon(Icons.add, key: ValueKey('add')),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.fitness_center_outlined, Icons.fitness_center, 'Exercises'),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(2, Icons.show_chart_outlined, Icons.show_chart, 'Progress'),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
