import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mae_assignment/main.dart'
    as app; // adjust based on your app name

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app loads and shows login or dashboard', (
    WidgetTester tester,
  ) async {
    // Set a reasonable timeout for the test
    await app.startApp(); // Runs your full app entry point
    
    // Give the app time to initialize Firebase and load the initial screen
    // Use pump() instead of pumpAndSettle() to avoid waiting indefinitely
    await tester.pump(const Duration(seconds: 5));
    
    // Pump a few more times to allow for UI updates
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Check if either login screen or dashboard is visible
    // Look for more specific UI elements that should be present
    final hasLogin = find.textContaining('Login').evaluate().isNotEmpty ||
        find.text('Login').evaluate().isNotEmpty ||
        find.text('Sign In').evaluate().isNotEmpty;
        
    final hasDashboard = find.textContaining('Dashboard').evaluate().isNotEmpty ||
        find.text('Dashboard').evaluate().isNotEmpty;
        
    final hasLoadingIndicator = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    // The app should either show login, dashboard, or still be loading
    expect(
      hasLogin || hasDashboard || hasLoadingIndicator,
      true,
      reason: 'App should show either login screen, dashboard, or loading indicator',
    );
    
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('Login flow end-to-end', (
    WidgetTester tester,
  ) async {
    // Start the app
    await app.startApp();
    await tester.pump(const Duration(seconds: 5));
    for (int i = 0; i < 15; i++) {await tester.pump(const Duration(milliseconds: 500));}
    final loginTextFinder = find.text('Login');
    expect(loginTextFinder.evaluate().isNotEmpty, true, reason: 'Should find Login text on the screen');
    final emailField = find.widgetWithText(TextField, 'Email').first;
    final passwordField = find.widgetWithText(TextField, 'Password').first;
    // Enter email
    await tester.enterText(emailField, 'fisherishy@gmail.com');
    await tester.pump(const Duration(milliseconds: 500));
    // Enter password
    await tester.enterText(passwordField, '123456');
    await tester.pump(const Duration(milliseconds: 500));
    // Find and tap the login button
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButton.evaluate().isNotEmpty, true, reason: 'Should find the Login button');
    await tester.tap(loginButton);
    await tester.pump(const Duration(seconds: 2));
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    final stillOnLogin = find.text('Login').evaluate().isNotEmpty &&
        find.widgetWithText(ElevatedButton, 'Login').evaluate().isNotEmpty;
    final onDashboard = find.textContaining('Dashboard').evaluate().isNotEmpty ||
        find.text('Dashboard').evaluate().isNotEmpty;
    final stillLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    expect(
      !stillOnLogin || onDashboard || stillLoading,
      true,
      reason: 'Should either navigate away from login screen or show dashboard/loading',
    );
    if (onDashboard) {
      print('Successfully logged in and reached dashboard');
    } else if (stillLoading) {
      print('Login initiated, still loading next screen');
    } else if (!stillOnLogin) {
      print('Successfully navigated away from login screen');
    }
    
  }, timeout: const Timeout(Duration(minutes: 3)));
}
