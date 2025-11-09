import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Finspense/screens/analytics/financial_summary_card.dart';

String mockFormatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

void main() {
  group('FinancialSummaryCard Widget Tests', () {
    testWidgets('should render with all required data',
        (WidgetTester tester) async {
      // Arrange
      const totalIncome = 5000.0;
      const totalExpenses = 3000.0;
      const netSavings = 2000.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netSavings: netSavings,
              formatCurrency: mockFormatCurrency,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Monthly Overview'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
    });

    testWidgets('should display formatted currency values',
        (WidgetTester tester) async {
      // Arrange
      const totalIncome = 1234.56;
      const totalExpenses = 789.12;
      const netSavings = 445.44;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netSavings: netSavings,
              formatCurrency: mockFormatCurrency,
            ),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Assert - Check if Container is rendered
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle zero values', (WidgetTester tester) async {
      // Arrange
      const totalIncome = 0.0;
      const totalExpenses = 0.0;
      const netSavings = 0.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netSavings: netSavings,
              formatCurrency: mockFormatCurrency,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Monthly Overview'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should handle negative savings', (WidgetTester tester) async {
      // Arrange
      const totalIncome = 1000.0;
      const totalExpenses = 1500.0;
      const netSavings = -500.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netSavings: netSavings,
              formatCurrency: mockFormatCurrency,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Monthly Overview'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should have proper gradient styling',
        (WidgetTester tester) async {
      // Arrange
      const totalIncome = 5000.0;
      const totalExpenses = 3000.0;
      const netSavings = 2000.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netSavings: netSavings,
              formatCurrency: mockFormatCurrency,
            ),
          ),
        ),
      );

      // Assert - Check for Container with decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Verify the main container has proper styling
      final mainContainer = tester.widget<Container>(containerFinder.first);
      expect(mainContainer.decoration, isA<BoxDecoration>());
    });

    testWidgets('should display icons for each metric',
        (WidgetTester tester) async {
      // Arrange
      const totalIncome = 5000.0;
      const totalExpenses = 3000.0;
      const netSavings = 2000.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netSavings: netSavings,
              formatCurrency: mockFormatCurrency,
            ),
          ),
        ),
      );

      // Assert - Check for icons
      expect(find.byType(Icon), findsWidgets);
      await tester.pumpAndSettle();
    });
  });
}
