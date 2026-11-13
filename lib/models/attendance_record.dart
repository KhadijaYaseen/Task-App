import 'employee.dart';

enum AttendanceStatus {
  present,
  leave,
  absent,
}

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkInTime;
  final String? checkOutTime;
  final double hours;
  final AttendanceStatus status;
  final String? notes;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.hours,
    this.status = AttendanceStatus.present,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'date': date.toIso8601String(),
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'hours': hours,
      'status': status.name,
      'notes': notes,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    AttendanceStatus status = AttendanceStatus.present;
    final statusStr = json['status'] as String? ?? 'present';
    if (statusStr == 'leave') {
      status = AttendanceStatus.leave;
    } else if (statusStr == 'absent') {
      status = AttendanceStatus.absent;
    }

    final dateStr = json['date'] as String?;
    final date = dateStr != null ? (DateTime.tryParse(dateStr) ?? DateTime.now()) : DateTime.now();

    return AttendanceRecord(
      id: json['id'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      employeeName: json['employee_name'] as String? ?? 'Team Member',
      date: date,
      checkInTime: json['check_in_time'] as String? ?? '8:00 PM',
      checkOutTime: json['check_out_time'] as String?,
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
      status: status,
      notes: json['notes'] as String?,
    );
  }

  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? checkInTime,
    String? checkOutTime,
    double? hours,
    AttendanceStatus? status,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      hours: hours ?? this.hours,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  static List<AttendanceRecord> getSampleRecords(List<Employee> employees) {
    final khadija = employees.firstWhere(
      (e) => e.name.toLowerCase().contains('khadija') || !e.isAdmin,
      orElse: () => Employee.khadija,
    );

    final saleem = employees.firstWhere(
      (e) => e.isAdmin,
      orElse: () => Employee.saleem,
    );

    return [
      // Saleem (Tech Lead) Records
      AttendanceRecord(
        id: 'att_sl_1',
        employeeId: saleem.id,
        employeeName: saleem.name,
        date: DateTime(2026, 11, 13),
        checkInTime: '7:30 PM',
        checkOutTime: '12:30 AM',
        hours: 5.0,
        status: AttendanceStatus.present,
        notes: 'Architecture & Code Review',
      ),
      AttendanceRecord(
        id: 'att_sl_2',
        employeeId: saleem.id,
        employeeName: saleem.name,
        date: DateTime(2026, 11, 12),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
        notes: 'Team Mentorship & Review',
      ),

      // Khadija Yaseen Records (Verified 19 Oct - 13 Nov)
      AttendanceRecord(
        id: 'att_ky_24',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 13),
        checkInTime: '7:45 PM',
        checkOutTime: '12:00 AM',
        hours: 4.25,
        status: AttendanceStatus.present,
        notes: 'Task-App Implementation & UI',
      ),
      AttendanceRecord(
        id: 'att_ky_23',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 12),
        checkInTime: '9:00 PM',
        checkOutTime: '12:00 AM',
        hours: 3.0,
        status: AttendanceStatus.present,
        notes: 'UI/Figma Research',
      ),
      AttendanceRecord(
        id: 'att_ky_22',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 11),
        checkInTime: '--',
        checkOutTime: '--',
        hours: 0.0,
        status: AttendanceStatus.leave,
        notes: 'Leave (Personal Off-Day)',
      ),
      AttendanceRecord(
        id: 'att_ky_21',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 10),
        checkInTime: '8:00 PM',
        checkOutTime: '1:30 AM',
        hours: 5.5,
        status: AttendanceStatus.present,
        notes: 'Native Gmail Channel & Demo',
      ),
      AttendanceRecord(
        id: 'att_ky_20',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 9),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
        notes: 'UI Polish & Login Restructure',
      ),
      AttendanceRecord(
        id: 'att_ky_19',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 8),
        checkInTime: '8:00 PM',
        checkOutTime: '12:30 AM',
        hours: 4.5,
        status: AttendanceStatus.present,
        notes: 'Password Assignment & Credentials',
      ),
      AttendanceRecord(
        id: 'att_ky_18',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 7),
        checkInTime: '8:00 PM',
        checkOutTime: '1:30 AM',
        hours: 5.5,
        status: AttendanceStatus.present,
        notes: 'Admin Security & Deletion',
      ),
      AttendanceRecord(
        id: 'att_ky_17',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 6),
        checkInTime: '8:00 PM',
        checkOutTime: '2:00 AM',
        hours: 6.0,
        status: AttendanceStatus.present,
        notes: 'Supabase Cloud Database Sync',
      ),
      AttendanceRecord(
        id: 'att_ky_16',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 5),
        checkInTime: '8:00 PM',
        checkOutTime: '1:30 AM',
        hours: 5.5,
        status: AttendanceStatus.present,
        notes: 'Exclusivity Rules & Search Filter',
      ),
      AttendanceRecord(
        id: 'att_ky_15',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 4),
        checkInTime: '8:00 PM',
        checkOutTime: '12:30 AM',
        hours: 4.5,
        status: AttendanceStatus.present,
        notes: 'Analytics & Due Date Enhancements',
      ),
      AttendanceRecord(
        id: 'att_ky_14',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 3),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
        notes: 'Documentation & User Guide',
      ),
      AttendanceRecord(
        id: 'att_ky_13',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 2),
        checkInTime: '--',
        checkOutTime: '--',
        hours: 0.0,
        status: AttendanceStatus.leave,
        notes: 'Leave (University Degree / FYP Defence)',
      ),
      AttendanceRecord(
        id: 'att_ky_12',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 11, 1),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
        notes: 'Testing & Bug Fixes',
      ),
      AttendanceRecord(
        id: 'att_ky_11',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 31),
        checkInTime: '8:00 PM',
        checkOutTime: '11:00 PM',
        hours: 3.0,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_10',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 30),
        checkInTime: '8:00 PM',
        checkOutTime: '1:30 AM',
        hours: 5.5,
        status: AttendanceStatus.present,
        notes: 'Auth & Team Roster Modules',
      ),
      AttendanceRecord(
        id: 'att_ky_9',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 29),
        checkInTime: '8:00 PM',
        checkOutTime: '1:00 AM',
        hours: 5.0,
        status: AttendanceStatus.present,
        notes: 'Cobalt UI System Integration',
      ),
      AttendanceRecord(
        id: 'att_ky_8',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 28),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_7',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 27),
        checkInTime: '8:00 PM',
        checkOutTime: '12:30 AM',
        hours: 4.5,
        status: AttendanceStatus.present,
        notes: 'Task-App Architecture',
      ),
      AttendanceRecord(
        id: 'att_ky_6',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 26),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_5',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 23),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_4',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 22),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_3',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 21),
        checkInTime: '8:00 PM',
        checkOutTime: '11:30 PM',
        hours: 3.5,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_2',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 20),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
      ),
      AttendanceRecord(
        id: 'att_ky_1',
        employeeId: khadija.id,
        employeeName: khadija.name,
        date: DateTime(2026, 10, 19),
        checkInTime: '8:00 PM',
        checkOutTime: '12:00 AM',
        hours: 4.0,
        status: AttendanceStatus.present,
        notes: 'Project Onboarding & Setup',
      ),
    ];
  }
}
