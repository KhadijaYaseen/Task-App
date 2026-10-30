class Employee {
  final String id;
  final String name;
  final String role;
  final String initials;
  final String? email;
  final bool isAdmin;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    this.email,
    this.isAdmin = false,
  });

  static const Employee saleem = Employee(
    id: 'emp_1',
    name: 'Saleem',
    role: 'Tech Lead / Manager',
    initials: 'SL',
    email: 'saleem@khawajalabs.com',
    isAdmin: true,
  );

  static const Employee khadija = Employee(
    id: 'emp_2',
    name: 'Khadija Yaseen',
    role: 'Mobile Engineer (Intern)',
    initials: 'KY',
    email: 'khadija@khawajalabs.com',
    isAdmin: false,
  );

  static const Employee hamza = Employee(
    id: 'emp_3',
    name: 'Hamza Khan',
    role: 'UI/UX Designer',
    initials: 'HK',
    email: 'hamza@khawajalabs.com',
    isAdmin: false,
  );

  static const Employee zain = Employee(
    id: 'emp_4',
    name: 'Zain Ahmed',
    role: 'Backend Developer',
    initials: 'ZA',
    email: 'zain@khawajalabs.com',
    isAdmin: false,
  );

  static List<Employee> get initialEmployees => [saleem, khadija, hamza, zain];
}
