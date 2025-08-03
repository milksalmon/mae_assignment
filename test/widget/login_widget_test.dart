import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/auth/login.dart';

void main() {
  group('Login Widget Tests', () {
    
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Login screen displays all required elements', (WidgetTester tester) async {
      // Build the LoginScreen widget
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
);
      // Wait for the widget to settle
      await tester.pumpAndSettle();
      // Verify that key UI elements are present
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsWidgets); // Login button
      expect(find.text('Sign in with Google'), findsOneWidget); // Google sign in button
    });

    testWidgets('Email and password fields accept input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find email and password text fields
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');

      // Enter text in email field
      await tester.enterText(emailField, 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);

      // Enter text ni password field
      await tester.enterText(passwordField, 'password123');
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find password field and visibility toggle
      final passwordField = find.widgetWithText(TextField, 'Password');
      final visibilityToggle = find.byIcon(Icons.visibility_off);

      // Verify password is initially obscured
      final passwordFieldWidget = tester.widget<TextField>(passwordField);
      expect(passwordFieldWidget.obscureText, true);

      // Tap the visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // verify passwodr is now visible
      final updatedPasswordField = tester.widget<TextField>(passwordField);
      expect(updatedPasswordField.obscureText, false);

      // Verify icon changed to visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Login button shows validation error for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap login button without entering credentials
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation message appears
      expect(find.text('Please enter credentials'), findsOneWidget);
    });

    testWidgets('Form fields have correct configuration and icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find text fields
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');

      // Verify email field configuration
      final emailWidget = tester.widget<TextField>(emailField);
      expect(emailWidget.keyboardType, TextInputType.emailAddress);

      // Verify password field configuration
      final passwordWidget = tester.widget<TextField>(passwordField);
      expect(passwordWidget.obscureText, true);

      // Verify field icons
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
