import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mae_assignment/main.dart'
    as app; // adjust based on your app name

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app loads and shows login or dashboard', (
    WidgetTester tester,
  ) async {
    await app.startApp(); // Runs your full app entry point
    await tester.pumpAndSettle();

    // Check if either login screen or dashboard is visible
    expect(
      find.textContaining('Login').evaluate().isNotEmpty ||
          find.textContaining('Dashboard').evaluate().isNotEmpty,
      true,
    );
  });
}
