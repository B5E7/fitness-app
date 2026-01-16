import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Weight units supported by the app
enum WeightUnit { kg, lbs }

/// Provider for managing app settings and preferences
class SettingsProvider with ChangeNotifier {
  WeightUnit _weightUnit = WeightUnit.kg;
  bool _isInitialized = false;

  WeightUnit get weightUnit => _weightUnit;
  String get weightUnitString => _weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final unitIndex = prefs.getInt('weight_unit') ?? 0;
    _weightUnit = WeightUnit.values[unitIndex];
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    _weightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weight_unit', unit.index);
    notifyListeners();
  }

  Future<void> toggleWeightUnit() async {
    final nextUnit = _weightUnit == WeightUnit.kg ? WeightUnit.lbs : WeightUnit.kg;
    await setWeightUnit(nextUnit);
  }
}
