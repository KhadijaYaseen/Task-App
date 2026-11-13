import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/main.dart';
import 'package:task_app/models/employee.dart';
import 'package:task_app/models/task_item.dart';
import 'package:task_app/services/supabase_service.dart';

void main() {
  setUp(() {
    SupabaseService.isTestMode = true;
  });
  testWidgets('Cobalt Task Manager Login and Dashboard flow test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // 1. Verify Login Screen renders with company identity
    expect(find.text('Company Tasks'), findsOneWidget);
    expect(find.text('👑 Admin / Lead'), findsOneWidget);
    expect(find.text('🚀 Team Member'), findsOneWidget);

    // 2. Perform Admin Login with credentials
    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead'));
    await tester.pumpAndSettle();

    // 3. Verify Dashboard Screen rendered with Cobalt features & navigation tabs
    expect(find.text('No Active Tasks'), findsOneWidget);
    expect(find.text('+ New Task'), findsOneWidget);
    expect(find.text('Jump to a task or project...'), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);

    // 4. Verify Active Role Banner indicates Saleem
    expect(find.textContaining('Saleem'), findsWidgets);
  });

  testWidgets('Admin Login validates incorrect credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Enter wrong credentials
    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'wrongpass');
    await tester.tap(find.text('Login as Tech Lead'));
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
    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead'));
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
    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead'));
    await tester.pumpAndSettle();

    // Switch to Analytics Tab
    await tester.tap(find.text('Analytics').first);
    await tester.pumpAndSettle();

    // Verify Task Summary header and metrics
    expect(find.text('TASK SUMMARY'), findsOneWidget);
    expect(find.text('Your tasks, at a glance 🚀'), findsOneWidget);
    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Completion Status'), findsOneWidget);
    expect(find.text('Overdue vs Upcoming Tasks'), findsOneWidget);
  });

  testWidgets('Non-admin team member cannot edit or delete tasks and can only toggle own tasks', (WidgetTester tester) async {
    const member = Employee.khadija;
    const peer = Employee.hamza;

    final myTask = TaskItem(
      id: 'task-1',
      title: 'Design UI Layout',
      description: 'Create modern responsive layout',
      projectId: 'proj-1',
      projectName: 'Task-App Engine',
      assignee: member,
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    );

    final otherTask = TaskItem(
      id: 'task-2',
      title: 'Export Vector Icons',
      description: 'Export brand SVG assets',
      projectId: 'proj-1',
      projectName: 'Task-App Engine',
      assignee: peer,
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DashboardScreen(
          currentUser: member,
          employees: const [member, peer],
          tasks: [myTask, otherTask],
          onLogout: () {},
          onAddEmployee: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Verify both tasks render
    expect(find.text('Design UI Layout'), findsOneWidget);
    expect(find.text('Export Vector Icons'), findsOneWidget);

    // Verify non-admin has no edit or delete access
    expect(find.byTooltip('Edit Task'), findsNothing);
    expect(find.byTooltip('Delete Task'), findsNothing);

    // Tasks assigned to peers show a lock icon
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    // Tapping locked task shows permission restriction
    await tester.ensureVisible(find.byIcon(Icons.lock_outline));
    await tester.tap(find.byIcon(Icons.lock_outline));
    await tester.pumpAndSettle();
    expect(find.text('Only Hamza Khan or Tech Lead can update this deliverable.'), findsOneWidget);

    // Tapping own task toggles status
    await tester.ensureVisible(find.byTooltip('Mark as Done'));
    await tester.tap(find.byTooltip('Mark as Done'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mark as In Progress'), findsOneWidget);
  });

  testWidgets('Duplicate task validation is project-scoped', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Admin login
    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead'));
    await tester.pumpAndSettle();

    // Add first task in Project A
    await tester.tap(find.text('+ New Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Task Title'), 'API Integration');
    await tester.enterText(find.widgetWithText(TextField, 'Project Name'), 'Project Alpha');
    await tester.tap(find.text('Assign Task'));
    await tester.pumpAndSettle();
    expect(find.text('API Integration'), findsOneWidget);

    // Try to add same task in Project Alpha again -> should fail with error
    await tester.tap(find.text('+ New Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Task Title'), 'API Integration');
    await tester.enterText(find.widgetWithText(TextField, 'Project Name'), 'Project Alpha');
    await tester.tap(find.text('Assign Task'));
    await tester.pumpAndSettle();
    expect(find.textContaining('already assigned within project "Project Alpha"'), findsOneWidget);

    // Change Project Name to Project Beta in the modal -> should SUCCEED
    await tester.enterText(find.widgetWithText(TextField, 'Project Name'), 'Project Beta');
    await tester.tap(find.text('Assign Task'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Both tasks now exist!
    expect(find.text('API Integration'), findsNWidgets(2));
    expect(find.text('Project Alpha'), findsOneWidget);
    expect(find.text('Project Beta'), findsOneWidget);
  });

  testWidgets('Smart Search filters by title, assignee name, and "my task" keyword', (WidgetTester tester) async {
    const saleem = Employee.saleem;
    const khadija = Employee.khadija;

    final task1 = TaskItem(
      id: 'task-1',
      title: 'Fix Authentication',
      description: 'Fix token expiry',
      projectId: 'p1',
      projectName: 'Security',
      assignee: saleem,
      status: TaskStatus.inProgress,
      priority: TaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    );

    final task2 = TaskItem(
      id: 'task-2',
      title: 'Build Search Bar',
      description: 'Add quick jump filter',
      projectId: 'p2',
      projectName: 'UI Engine',
      assignee: khadija,
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    );

    await tester.pumpWidget(MaterialApp(
      home: DashboardScreen(
        currentUser: khadija,
        employees: const [saleem, khadija],
        tasks: [task1, task2],
        onLogout: () {},
        onAddEmployee: (_) {},
      ),
    ));
    await tester.pumpAndSettle();

    // Initially both tasks visible (All view)
    expect(find.text('Fix Authentication'), findsOneWidget);
    expect(find.text('Build Search Bar'), findsOneWidget);

    // Search "my task" -> should filter only current user's task
    await tester.enterText(find.widgetWithText(TextField, 'Jump to a task or project...'), 'my task');
    await tester.pumpAndSettle();

    expect(find.text('Build Search Bar'), findsOneWidget);
    expect(find.text('Fix Authentication'), findsNothing);

    // Tap clear (x) button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Both visible again
    expect(find.text('Fix Authentication'), findsOneWidget);
    expect(find.text('Build Search Bar'), findsOneWidget);
  });

  testWidgets('Attendance Tab renders Hero Clock In card, Calendar, and Attendance Ledger for Admin', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Login as Admin
    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'admin123');
    await tester.tap(find.text('Login as Tech Lead'));
    await tester.pumpAndSettle();

    // Switch to Attendance Tab
    await tester.tap(find.text('Attendance').first);
    await tester.pumpAndSettle();

    // Verify Admin Attendance Controls & Roster selector
    expect(find.text('Tech Lead Attendance Controls'), findsOneWidget);
    expect(find.text('All Roster'), findsOneWidget);

    // Verify Hero Clock In / Punch Card (Image 2 style)
    expect(find.text('HOURS LOGGED TODAY'), findsOneWidget);
    expect(find.text('CLOCKED IN'), findsOneWidget);
    expect(find.text('Clock Out'), findsOneWidget);
    expect(find.text('CLOCK IN'), findsOneWidget);
    expect(find.text('SHIFT TARGET'), findsOneWidget);
    expect(find.text('OVERTIME'), findsOneWidget);

    // Verify Monthly Calendar (Image 1 style)
    expect(find.text('November 2026'), findsOneWidget);

    // Test Clock In / Clock Out toggle
    await tester.tap(find.text('Clock Out'));
    await tester.pumpAndSettle();
    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('Clock In'), findsOneWidget);
  });

  testWidgets('Attendance Role Privacy Guard: Non-admin only sees own records and confidentiality notice', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    // Switch to Team Member tab and login as Khadija Yaseen
    await tester.tap(find.text('🚀 Team Member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as Khadija Yaseen'));
    await tester.pumpAndSettle();

    // Switch to Attendance Tab
    await tester.tap(find.text('Attendance').first);
    await tester.pumpAndSettle();

    // Verify Confidential Privacy Notice
    expect(find.textContaining('Confidential: Attendance is strictly private between you & Tech Lead (Saleem).'), findsOneWidget);

    // Verify Admin controls are NOT present
    expect(find.text('Tech Lead Attendance Controls'), findsNothing);
    expect(find.text('All Roster'), findsNothing);

    // Verify Khadija's name is on her attendance records
    expect(find.text('Khadija Yaseen'), findsWidgets);

    // Verify Saleem (Lead) individual records are NOT visible in Khadija's ledger
    expect(find.text('Saleem (Tech Lead)'), findsNothing);
  });
}
