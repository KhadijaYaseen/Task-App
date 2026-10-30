import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/main.dart';

void main() {
  testWidgets('Cobalt Task Manager Login and Dashboard flow test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // 1. Verify Login Screen renders with company identity
    expect(find.text('Company Tasks'), findsOneWidget);
    expect(find.text('👑 Admin / Lead'), findsOneWidget);
    expect(find.text('🚀 Team Member'), findsOneWidget);

    // 2. Perform Admin Login
    await tester.tap(find.text('Login as Tech Lead (Saleem)'));
    await tester.pumpAndSettle();

    // 3. Verify Dashboard Screen rendered with Cobalt features
    expect(find.text('No Active Tasks'), findsOneWidget);
    expect(find.text('+ New Task'), findsOneWidget);
    expect(find.text('Jump to a task or project...'), findsOneWidget);

    // 4. Verify Active Role Banner indicates Saleem
    expect(find.textContaining('Saleem'), findsWidgets);
  });

  testWidgets('Admin Login validates incorrect credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Enter wrong password
    await tester.enterText(find.bySemanticsLabel('Admin Password'), 'wrongpass');
    await tester.tap(find.text('Login as Tech Lead (Saleem)'));
    await tester.pumpAndSettle();

    // Expect error message
    expect(find.text('Invalid Admin ID or Password. Please try again.'), findsOneWidget);
  });

  testWidgets('Team Member Login flow works seamlessly', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Switch to Team Member tab
    await tester.tap(find.text('🚀 Team Member'));
    await tester.pumpAndSettle();

    // Verify team members appear
    expect(find.text('Khadija Yaseen'), findsOneWidget);
    expect(find.text('Continue as Khadija Yaseen'), findsOneWidget);

    // Login as Khadija Yaseen
    await tester.tap(find.text('Continue as Khadija Yaseen'));
    await tester.pumpAndSettle();

    // Verify logged in dashboard reflects Khadija
    expect(find.textContaining('Khadija Yaseen'), findsWidgets);
    expect(find.text('Deliverables & Milestones (0)'), findsOneWidget);
  });
}
