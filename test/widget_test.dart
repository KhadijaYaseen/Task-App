import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());
    expect(find.text('Company Tasks'), findsOneWidget);
    expect(find.text('Welcome to Task Manager!'), findsOneWidget);
  });
}
