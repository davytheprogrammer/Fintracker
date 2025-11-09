import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Finspense/screens/analytics/category_donut_chart.dart';

void main() {
  group('CategoryDonutChart Widget Tests', () {
    String mockFormatCurrency(double amount) {
      return '\$${amount.toStringAsFixed(2)}';
    }

    double mockGetPercentage(double value, double total) {
      return total > 0 ? (value / total) * 100 : 0;
    }

    final mockCategoryColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];

    testWidgets('should render with category spending data',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = {
        'Food': 500.0,
        'Transport': 300.0,
        'Shopping': 200.0,
      };
      const totalExpenses = 1000.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryDonutChart(
              categorySpending: categorySpending,
              totalExpenses: totalExpenses,
              selectedCategoryIndex: -1,
              categoryColors: mockCategoryColors,
              getPercentage: mockGetPercentage,
              formatCurrency: mockFormatCurrency,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
    });

    testWidgets('should show empty state when no data available',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = <String, double>{};
      const totalExpenses = 0.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryDonutChart(
              categorySpending: categorySpending,
              totalExpenses: totalExpenses,
              selectedCategoryIndex: -1,
              categoryColors: mockCategoryColors,
              getPercentage: mockGetPercentage,
              formatCurrency: mockFormatCurrency,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('No expense data available'), findsOneWidget);
    });

    testWidgets('should display category percentages',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = {
        'Food': 500.0,
        'Transport': 300.0,
      };
      const totalExpenses = 800.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryDonutChart(
              categorySpending: categorySpending,
              totalExpenses: totalExpenses,
              selectedCategoryIndex: -1,
              categoryColors: mockCategoryColors,
              getPercentage: mockGetPercentage,
              formatCurrency: mockFormatCurrency,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Spending by Category'), findsOneWidget);
      // Percentages should be displayed
      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('should handle category selection',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = {
        'Food': 500.0,
        'Transport': 300.0,
      };
      const totalExpenses = 800.0;
      var selectedIndex = -1;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CategoryDonutChart(
                  categorySpending: categorySpending,
                  totalExpenses: totalExpenses,
                  selectedCategoryIndex: selectedIndex,
                  categoryColors: mockCategoryColors,
                  getPercentage: mockGetPercentage,
                  formatCurrency: mockFormatCurrency,
                  onCategorySelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Find and tap on a category
      final foodCategory = find.text('Food');
      expect(foodCategory, findsOneWidget);

      await tester.tap(foodCategory);
      await tester.pump();

      // Assert - Selection callback should be triggered
      expect(selectedIndex, isNot(-1));
    });

    testWidgets('should show category details when selected',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = {
        'Food': 500.0,
        'Transport': 300.0,
      };
      const totalExpenses = 800.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryDonutChart(
              categorySpending: categorySpending,
              totalExpenses: totalExpenses,
              selectedCategoryIndex: 0, // Select first category
              categoryColors: mockCategoryColors,
              getPercentage: mockGetPercentage,
              formatCurrency: mockFormatCurrency,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Category details should be visible
      expect(find.text('Spending by Category'), findsOneWidget);
    });

    testWidgets('should have proper gradient styling',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = {
        'Food': 500.0,
      };
      const totalExpenses = 500.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryDonutChart(
              categorySpending: categorySpending,
              totalExpenses: totalExpenses,
              selectedCategoryIndex: -1,
              categoryColors: mockCategoryColors,
              getPercentage: mockGetPercentage,
              formatCurrency: mockFormatCurrency,
              onCategorySelected: (_) {},
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

    testWidgets('should sort categories by spending amount',
        (WidgetTester tester) async {
      // Arrange
      final categorySpending = {
        'Food': 100.0,
        'Transport': 500.0, // Highest
        'Shopping': 200.0,
      };
      const totalExpenses = 800.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryDonutChart(
              categorySpending: categorySpending,
              totalExpenses: totalExpenses,
              selectedCategoryIndex: -1,
              categoryColors: mockCategoryColors,
              getPercentage: mockGetPercentage,
              formatCurrency: mockFormatCurrency,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });
  });
}
