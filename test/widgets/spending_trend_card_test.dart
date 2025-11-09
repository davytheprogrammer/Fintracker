import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Finspense/screens/analytics/spending_trend_card.dart';

void main() {
  group('SpendingTrendCard Widget Tests', () {
    testWidgets('should render with monthly data', (WidgetTester tester) async {
      // Arrange
      final monthlyData = [
        {'month': 'Jan', 'income': 5000.0, 'expense': 3000.0},
        {'month': 'Feb', 'income': 5500.0, 'expense': 3200.0},
        {'month': 'Mar', 'income': 6000.0, 'expense': 3500.0},
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Monthly Spending Trend'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('should show empty state when no data available',
        (WidgetTester tester) async {
      // Arrange
      final monthlyData = <Map<String, dynamic>>[];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Monthly Spending Trend'), findsOneWidget);
      expect(find.text('No spending trend data available'), findsOneWidget);
    });

    testWidgets('should display legend items', (WidgetTester tester) async {
      // Arrange
      final monthlyData = [
        {'month': 'Jan', 'income': 5000.0, 'expense': 3000.0},
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('should have proper gradient styling',
        (WidgetTester tester) async {
      // Arrange
      final monthlyData = [
        {'month': 'Jan', 'income': 5000.0, 'expense': 3000.0},
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
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

    testWidgets('should handle single month data', (WidgetTester tester) async {
      // Arrange
      final monthlyData = [
        {'month': 'Jan', 'income': 5000.0, 'expense': 3000.0},
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Monthly Spending Trend'), findsOneWidget);
    });

    testWidgets('should handle multiple months of data',
        (WidgetTester tester) async {
      // Arrange
      final monthlyData = List.generate(
        12,
        (index) => {
          'month': [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ][index],
          'income': 5000.0 + (index * 100),
          'expense': 3000.0 + (index * 50),
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SpendingTrendCard(
                monthlyData: monthlyData,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Monthly Spending Trend'), findsOneWidget);
    });

    testWidgets('should handle zero values in data',
        (WidgetTester tester) async {
      // Arrange
      final monthlyData = [
        {'month': 'Jan', 'income': 0.0, 'expense': 0.0},
        {'month': 'Feb', 'income': 5000.0, 'expense': 3000.0},
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Monthly Spending Trend'), findsOneWidget);
    });

    testWidgets('should handle expenses exceeding income',
        (WidgetTester tester) async {
      // Arrange
      final monthlyData = [
        {'month': 'Jan', 'income': 3000.0, 'expense': 5000.0},
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendCard(
              monthlyData: monthlyData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Monthly Spending Trend'), findsOneWidget);
    });
  });
}
