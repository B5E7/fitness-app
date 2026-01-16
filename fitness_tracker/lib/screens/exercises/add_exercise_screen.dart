import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/exercise_provider.dart';
import '../../models/exercise.dart';

/// Screen for adding or editing a custom exercise
class AddExerciseScreen extends StatefulWidget {
  final Exercise? exercise; // null for new exercise, non-null for editing

  const AddExerciseScreen({super.key, this.exercise});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedMuscleGroup = MuscleGroups.chest;
  bool _isLoading = false;

  bool get isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _descriptionController.text = widget.exercise!.description ?? '';
      _selectedMuscleGroup = widget.exercise!.muscleGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          isEditing ? 'Edit Exercise' : 'Add Exercise',
          style: AppTheme.headingSmall,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Exercise name
            Text('Exercise Name', style: AppTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g., Incline Dumbbell Press',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Muscle group
            Text('Muscle Group', style: AppTheme.labelLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroups.all.map((muscle) {
                final isSelected = _selectedMuscleGroup == muscle;
                final muscleColor =
                    AppTheme.muscleGroupColors[muscle] ?? AppTheme.primaryColor;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMuscleGroup = muscle;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? muscleColor : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? muscleColor
                            : Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: muscleColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          MuscleGroups.getIcon(muscle),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          muscle,
                          style: AppTheme.bodyMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description (optional)
            Text('Description (Optional)', style: AppTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Add notes about this exercise...',
              ),
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveExercise,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Add Exercise',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<ExerciseProvider>();

    bool success;
    if (isEditing) {
      final updatedExercise = widget.exercise!.copyWith(
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscleGroup,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      success = await provider.updateExercise(updatedExercise);
    } else {
      success = await provider.addExercise(
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscleGroup,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Exercise updated!' : 'Exercise added!',
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      provider.clearError();
    }
  }
}
