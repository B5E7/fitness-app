import 'dart:async';
import 'package:flutter/material.dart';

/// Provider to manage the rest timer between sets
class RestTimerProvider with ChangeNotifier {
  int _secondsRemaining = 0;
  int _totalSeconds = 90; // Default 90 seconds
  Timer? _timer;
  bool _isActive = false;

  int get secondsRemaining => _secondsRemaining;
  int get totalSeconds => _totalSeconds;
  bool get isActive => _isActive;
  double get progress => _totalSeconds > 0 ? _secondsRemaining / _totalSeconds : 0;

  void startTimer({int? seconds}) {
    if (seconds != null) {
      _totalSeconds = seconds;
    }
    _secondsRemaining = _totalSeconds;
    _isActive = true;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        stopTimer();
      }
    });
    
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _secondsRemaining = 0;
    _isActive = false;
    notifyListeners();
  }

  void adjustTime(int seconds) {
    _secondsRemaining += seconds;
    if (_secondsRemaining < 0) _secondsRemaining = 0;
    if (_secondsRemaining > _totalSeconds) _totalSeconds = _secondsRemaining;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
