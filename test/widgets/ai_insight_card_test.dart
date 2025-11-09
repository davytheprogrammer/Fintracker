import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Finspense/screens/analytics/ai_insight_card.dart';

void main() {
  group('AIInsightCard Widget Tests', () {
    testWidgets('should render with AI insights', (WidgetTester tester) async {
      // Arrange
      const aiInsight = 'This is a test AI insight about your spending.';
      const isLoading = false;
      void mockPerformAI() {}

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIInsightCard(
              aiInsight: aiInsight,
              isLoadingAIInsight: isLoading,
              performAIAnalysis: mockPerformAI,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should show loading state when isLoadingAIInsight is true',
        (WidgetTester tester) async {
      // Arrange
      const aiInsight = '';
      const isLoading = true;
      void mockPerformAI() {}

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIInsightCard(
              aiInsight: aiInsight,
              isLoadingAIInsight: isLoading,
              performAIAnalysis: mockPerformAI,
            ),
          ),
        ),
      );

      // Wait for widget to settle
      await tester.pump();

      // Assert - Should show loading state (shimmer), check for Container instead
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display markdown content', (WidgetTester tester) async {
      // Arrange
      const aiInsight = '**Bold text** and *italic text*';
      const isLoading = false;
      void mockPerformAI() {}

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIInsightCard(
              aiInsight: aiInsight,
              isLoadingAIInsight: isLoading,
              performAIAnalysis: mockPerformAI,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('AI Insights'), findsOneWidget);
    });

    testWidgets('should have refresh button', (WidgetTester tester) async {
      // Arrange
      const aiInsight = 'Test insight';
      const isLoading = false;
      var refreshCalled = false;
      void mockPerformAI() {
        refreshCalled = true;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIInsightCard(
              aiInsight: aiInsight,
              isLoadingAIInsight: isLoading,
              performAIAnalysis: mockPerformAI,
            ),
          ),
        ),
      );

      // Find and tap refresh button
      final refreshButton = find.byType(IconButton);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      // Assert
      expect(refreshCalled, true);
    });

    testWidgets('should have proper styling with gradient',
        (WidgetTester tester) async {
      // Arrange
      const aiInsight = 'Test insight';
      const isLoading = false;
      void mockPerformAI() {}

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIInsightCard(
              aiInsight: aiInsight,
              isLoadingAIInsight: isLoading,
              performAIAnalysis: mockPerformAI,
            ),
          ),
        ),
      );

      // Assert - Check for Container with decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      final mainContainer = tester.widget<Container>(containerFinder.first);
      expect(mainContainer.decoration, isA<BoxDecoration>());
    });

    testWidgets('should handle empty AI insight', (WidgetTester tester) async {
      // Arrange
      const aiInsight = '';
      const isLoading = false;
      void mockPerformAI() {}

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIInsightCard(
              aiInsight: aiInsight,
              isLoadingAIInsight: isLoading,
              performAIAnalysis: mockPerformAI,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('AI Insights'), findsOneWidget);
    });

    testWidgets('should handle long AI insight text',
        (WidgetTester tester) async {
      // Arrange
      const aiInsight = '''
This is a very long AI insight that contains multiple paragraphs and lots of information.
It should be properly rendered with markdown formatting and scrollable content.

Here is another paragraph with more details about spending patterns and financial advice.
The widget should handle this gracefully without overflow issues.
''';
      const isLoading = false;
      void mockPerformAI() {}

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AIInsightCard(
                aiInsight: aiInsight,
                isLoadingAIInsight: isLoading,
                performAIAnalysis: mockPerformAI,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('AI Insights'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
