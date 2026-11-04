import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/main.dart';

void main() {
  testWidgets('Cobalt Task Manager Login and Dashboard flow test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // 1. Verify Login Screen renders with company identity
    expect(find.text('Company Tasks'), findsOneWidget);
    expect(find.text('👑 Admin / Lead'), findsOneWidget);
    expect(find.text('🚀 Team Member'), findsOneWidget);

    // 2. Perform Admin Login with credentials
    await tester.enterText(find.bySemanticsLabel('Admin Username / ID'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Admin Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead (Saleem)'));
    await tester.pumpAndSettle();

    // 3. Verify Dashboard Screen rendered with Cobalt features & bottom navigation
    expect(find.text('No Active Tasks'), findsOneWidget);
    expect(find.text('+ New Task'), findsOneWidget);
    expect(find.text('Jump to a task or project...'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);

    // 4. Verify Active Role Banner indicates Saleem
    expect(find.textContaining('Saleem'), findsWidgets);
  });

  testWidgets('Admin Login validates incorrect credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Enter wrong credentials
    await tester.enterText(find.bySemanticsLabel('Admin Username / ID'), 'admin');
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

  testWidgets('Task Creation with Due Date, Edit, and Delete flow', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Login as Admin
    await tester.enterText(find.bySemanticsLabel('Admin Username / ID'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Admin Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead (Saleem)'));
    await tester.pumpAndSettle();

    // Open + New Task modal
    await tester.tap(find.text('+ New Task'));
    await tester.pumpAndSettle();

    expect(find.text('Create New Task'), findsOneWidget);
    expect(find.text('Deadline & Due Date'), findsOneWidget);

    // Enter Title & Project
    await tester.enterText(find.widgetWithText(TextField, 'Task Title'), 'Build Supabase DB Schema');
    await tester.enterText(find.widgetWithText(TextField, 'Project Name'), 'Task-App Engine');

    // Tap Assign Task
    await tester.tap(find.text('Assign Task'));
    await tester.pumpAndSettle();

    // Verify task card appears with Due Date chip
    expect(find.text('Build Supabase DB Schema'), findsOneWidget);
    expect(find.textContaining('Due:'), findsOneWidget);

    // Test Edit Task
    await tester.tap(find.byTooltip('Edit Task'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Task Title'), 'Build Supabase DB Schema v2');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Build Supabase DB Schema v2'), findsOneWidget);

    // Test Delete Task confirmation dialog
    await tester.tap(find.byTooltip('Delete Task'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Task'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete'), findsOneWidget);

    // Confirm Delete
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No Active Tasks'), findsOneWidget);
  });

  testWidgets('Analytics Tab renders Task Summary and metrics correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Login as Admin
    await tester.enterText(find.bySemanticsLabel('Admin Username / ID'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Admin Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead (Saleem)'));
    await tester.pumpAndSettle();

    // Switch to Analytics Tab
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    // Verify Task Summary header and metrics
    expect(find.text('TASK SUMMARY'), findsOneWidget);
    expect(find.text('Your tasks, at a glance 🚀'), findsOneWidget);
    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Completion Status'), findsOneWidget);
    expect(find.text('Overdue vs Upcoming Tasks'), findsOneWidget);
  });
}
