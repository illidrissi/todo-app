import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/main.dart';

void main() {
  group('MyApp Tests', () {
    late SharedPreferences mockPrefs;

    setUpAll(() async {
      // Initialize mock SharedPreferences for testing
      mockPrefs = await SharedPreferences.getInstance();
    });

    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Build our app and pass the mock SharedPreferences instance.
      await tester.pumpWidget(MyApp(prefs: mockPrefs));

      // Verify that the initial screen contains the "Welcome Back!" text.
      expect(find.text('Welcome Back!'), findsOneWidget);

      // Since your app doesn't have a counter, you can add other tests here.
      // For example, verify the presence of the search box or input field.
      expect(find.byType(TextField), findsNWidgets(2)); // Check for two TextField widgets (search box and input field).

      // If you want to simulate adding a task, you can tap the "+" button.
      final addButton = find.widgetWithIcon(IconButton, Icons.add_rounded);
      expect(addButton, findsOneWidget);

      // Tap the "+" button to open the dialog for adding a new task.
      await tester.tap(addButton);
      await tester.pumpAndSettle(); // Wait for the dialog to appear.

      // Verify that the dialog is displayed.
      expect(find.text('Add Task'), findsOneWidget);

      // Enter a task description in the dialog's text field.
      final taskInputField = find.byType(TextField).first;
      await tester.enterText(taskInputField, 'Test Task');

      // Tap the "Add" button in the dialog to save the task.
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle(); // Wait for the dialog to close.

      // Verify that the new task is added to the list.
      expect(find.text('Test Task'), findsOneWidget);
    });
  });
}