class Employee {
  final String id;
  final String name;
  final String role;
  final String initials;
  final String? avatarUrl;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    this.avatarUrl,
  });

  static const Employee saleem = Employee(
    id: 'emp_1',
    name: 'Saleem',
    role: 'Tech Lead / Manager',
    initials: 'SL',
  );

  static const Employee khadija = Employee(
    id: 'emp_2',
    name: 'Khadija Yaseen',
    role: 'Mobile Engineer (Intern)',
    initials: 'KY',
  );

  static const Employee hamza = Employee(
    id: 'emp_3',
    name: 'Hamza Khan',
    role: 'UI/UX Designer',
    initials: 'HK',
  );

  static const Employee zain = Employee(
    id: 'emp_4',
    name: 'Zain Ahmed',
    role: 'Backend Developer',
    initials: 'ZA',
  );

  static List<Employee> get allEmployees => [saleem, khadija, hamza, zain];
}
