import 'package:flutter/material.dart';

class InvestmentIdeaInput extends StatelessWidget {
  final TextEditingController ideaController;
  final bool isLoading;
  final int dailyUsageCount;
  final int maxDailyRoadmaps;
  final VoidCallback onGenerateRoadmap;
  final bool isDarkMode;
  final ThemeData theme;

  const InvestmentIdeaInput({
    required this.ideaController,
    required this.isLoading,
    required this.dailyUsageCount,
    required this.maxDailyRoadmaps,
    required this.onGenerateRoadmap,
    required this.isDarkMode,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe Your Investment Idea',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: ideaController,
              decoration: InputDecoration(
                hintText:
                    'E.g., "A subscription service for premium coffee beans delivered monthly with personalized recommendations"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.length < 15) {
                  return 'Investment idea must be at least 15 characters long';
                }
                if (value.split(' ').length < 10) {
                  return 'Investment idea must contain at least 10 words';
                }
                return null;
              },
              maxLines: 4,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : onGenerateRoadmap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dailyUsageCount >= maxDailyRoadmaps
                      ? Colors.grey
                      : theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Generating Roadmap...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Generate Roadmap',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
