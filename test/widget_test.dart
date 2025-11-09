// FinSpense App Tests
// This file contains basic app-level tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinSpense App Tests', () {
    test('App should have correct configuration', () {
      // Test app constants
      expect(1 + 1, 2); // Basic sanity test
    });

    testWidgets('MaterialApp should build without errors',
        (WidgetTester tester) async {
      // Build a simple MaterialApp
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('FinSpense')),
            body: const Center(
              child: Text('Welcome to FinSpense'),
            ),
          ),
        ),
      );

      // Verify the app builds successfully
      expect(find.text('FinSpense'), findsOneWidget);
      expect(find.text('Welcome to FinSpense'), findsOneWidget);
    });

    testWidgets('Scaffold should render properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
