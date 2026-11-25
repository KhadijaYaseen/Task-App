class Employee {
  final String id;
  final String name;
  final String role;
  final String initials;
  final String? email;
  final String? password;
  final bool isAdmin;
  final String shiftTiming;
  final String shiftTarget;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    this.email,
    this.password,
    this.isAdmin = false,
    this.shiftTiming = '8:00 PM – 12:00 AM',
    this.shiftTarget = '4h 00m',
  });

  static const Employee saleem = Employee(
    id: 'emp_1',
    name: 'Saleem',
    role: 'Software Architect & Tech Lead',
    initials: 'SL',
    email: 'saleemali001232@gmail.com',
    password: 'password123',
    isAdmin: true,
  );

  static const Employee khadija = Employee(
    id: 'emp_2',
    name: 'Khadija Yaseen',
    role: 'Mobile Engineer (Intern)',
    initials: 'KY',
    email: 'khadijayaseen36@gmail.com',
    password: 'password123',
    isAdmin: false,
  );

  // Backward compatible static references
  static const Employee hamza = Employee(
    id: 'emp_3',
    name: 'Hamza Khan',
    role: 'UI/UX Designer',
    initials: 'HK',
    email: 'hamza@khawajalabs.com',
    password: 'password123',
    isAdmin: false,
  );

  static const Employee zain = Employee(
    id: 'emp_4',
    name: 'Zain Ahmed',
    role: 'Backend Developer',
    initials: 'ZN',
    email: 'zain@khawajalabs.com',
    password: 'password123',
    isAdmin: false,
  );

  static const Employee zubair = Employee(
    id: 'emp_5',
    name: 'Zubair Ahmed',
    role: 'QA / Software Engineer',
    initials: 'ZA',
    email: 'zubair@khawajalabs.com',
    password: 'password123',
    isAdmin: false,
  );

  static List<Employee> get initialEmployees => [saleem, khadija, zubair, hamza, zain];

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Team Member',
      role: json['role'] as String? ?? 'Engineer',
      initials: json['initials'] as String? ??
          (json['name'] != null && (json['name'] as String).isNotEmpty
              ? (json['name'] as String).trim().substring(0, 1).toUpperCase()
              : 'TM'),
      email: json['email'] as String?,
      password: json['password'] as String?,
      isAdmin: json['is_admin'] == true,
      shiftTiming: json['shift_timing'] as String? ?? '8:00 PM – 12:00 AM',
      shiftTarget: json['shift_target'] as String? ?? '4h 00m',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'initials': initials,
      'email': email,
      'password': password ?? 'password123',
      'is_admin': isAdmin,
      'shift_timing': shiftTiming,
      'shift_target': shiftTarget,
    };
  }
}
