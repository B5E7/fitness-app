import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/rest_timer_provider.dart';

/// Widget to display the rest timer countdown
class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestTimerProvider>(
      builder: (context, timerProvider, child) {
        if (!timerProvider.isActive) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppTheme.accentGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'RESTING',
                            style: AppTheme.labelLarge.copyWith(
                              color: AppTheme.accentGreen,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: timerProvider.progress,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                _buildTimeDisplay(timerProvider.secondsRemaining),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => timerProvider.stopTimer(),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplay(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return Text(
      '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
      style: AppTheme.numberMedium.copyWith(
        fontSize: 24,
        color: AppTheme.accentGreen,
      ),
    );
  }
}
