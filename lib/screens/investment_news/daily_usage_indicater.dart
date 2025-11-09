import 'package:flutter/material.dart';

class DailyUsageIndicator extends StatelessWidget {
  final int dailyUsageCount;
  final int maxDailyRoadmaps;
  final bool isDarkMode;
  final ThemeData theme;

  const DailyUsageIndicator({super.key, 
    required this.dailyUsageCount,
    required this.maxDailyRoadmaps,
    required this.isDarkMode,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Daily Roadmaps Generated:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: List.generate(
              maxDailyRoadmaps,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < dailyUsageCount
                      ? theme.colorScheme.primary
                      : isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
