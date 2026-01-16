import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Chart widget to display training volume over the last 7 days
class VolumeChartWidget extends StatelessWidget {
  final Map<DateTime, double> data;

  const VolumeChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDates = data.keys.toList()..sort();
    final maxValue = data.values.isEmpty 
        ? 100.0 
        : data.values.reduce((a, b) => a > b ? a : b);
    
    // Ensure we have a minimum for the chart display
    final chartMax = maxValue == 0 ? 1000.0 : maxValue * 1.2;

    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Volume (kg)',
                style: AppTheme.labelLarge,
              ),
              Text(
                'Last 7 Days',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMax,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surfaceDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} kg',
                        AppTheme.labelLarge.copyWith(color: AppTheme.primaryColor),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedDates.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('E').format(sortedDates[index]),
                            style: AppTheme.bodySmall.copyWith(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: sortedDates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final date = entry.value;
                  final volume = data[date] ?? 0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: volume,
                        color: volume > 0 
                            ? AppTheme.primaryColor 
                            : AppTheme.textTertiary.withOpacity(0.1),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMax,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
