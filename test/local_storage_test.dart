import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/models/attendance_record.dart';
import 'package:task_app/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocalStorageService persists attendance records and survives offline operations', () async {
    final record1 = AttendanceRecord(
      id: 'att_test_1',
      employeeId: 'emp_2',
      employeeName: 'Khadija Yaseen',
      date: DateTime.now(),
      checkInTime: '8:00 PM',
      checkOutTime: '12:00 AM',
      hours: 4.0,
      status: AttendanceStatus.present,
      notes: 'Test offline clock out',
    );

    // 1. Persist record locally
    await LocalStorageService.instance.persistRecord(record1);

    // 2. Load records directly from local disk (simulating offline app restart)
    final loaded = await LocalStorageService.instance.loadAttendanceRecords();
    expect(loaded.any((r) => r.id == 'att_test_1'), isTrue);
    final fetched = loaded.firstWhere((r) => r.id == 'att_test_1');
    expect(fetched.employeeName, 'Khadija Yaseen');
    expect(fetched.hours, 4.0);

    // 3. Verify queued in pending sync
    final pending = await LocalStorageService.instance.loadPendingSyncRecords();
    expect(pending.any((r) => r.id == 'att_test_1'), isTrue);
  });
}
