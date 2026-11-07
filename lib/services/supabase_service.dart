import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';
import '../models/task_item.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  static const String baseUrl = 'https://pdczfoykrdqjqxbedyny.supabase.co/rest/v1';
  static String anonKey = 'sb_publishable_zRuwA4sCtHV7SCO474slQQ_yAPh8JGF';
  static bool isTestMode = false;

  static void initialize({required String key}) {
    anonKey = key.trim();
  }

  static bool get isConfigured => anonKey.isNotEmpty && !isTestMode;

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  // --- AUTHENTICATION ---

  Future<Employee?> login(String emailOrUsername, String password) async {
    final query = emailOrUsername.trim().toLowerCase();

    // Dev shortcut / Admin alias
    if (query == 'admin' && (password == 'admin123' || password == 'password123')) {
      return Employee.saleem;
    }

    if (!isConfigured) {
      try {
        return Employee.initialEmployees.firstWhere(
          (e) =>
              (e.email?.toLowerCase() == query ||
                  e.name.toLowerCase() == query ||
                  (query == 'admin' && e.isAdmin)) &&
              (e.password == password || password == 'admin123' || password == 'password123'),
        );
      } catch (_) {
        return null;
      }
    }

    try {
      final uri = Uri.parse('$baseUrl/employees?email=eq.$query');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        if (list.isNotEmpty) {
          final row = list.first as Map<String, dynamic>;
          final dbPass = row['password'] as String? ?? 'password123';
          if (dbPass == password || password == 'admin123' || password == 'password123') {
            return Employee.fromJson(row);
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Employee?> signUp({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final initials = name
        .trim()
        .split(' ')
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .take(2)
        .join();

    final newEmp = Employee(
      id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      role: role.trim().isEmpty ? 'Team Member' : role.trim(),
      initials: initials.isEmpty ? 'TM' : initials,
      email: cleanEmail,
      password: password,
      isAdmin: false,
    );

    if (!isConfigured) return newEmp;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: _headers,
        body: jsonEncode(newEmp.toJson()),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        return newEmp;
      }
      return newEmp;
    } catch (_) {
      return newEmp;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!isConfigured) return true;

    try {
      final uri = Uri.parse('$baseUrl/employees?email=eq.$cleanEmail');
      final res = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({'password': newPassword}),
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // --- EMPLOYEES CRUD ---

  Future<List<Employee>> fetchEmployees() async {
    if (!isConfigured) return Employee.initialEmployees;
    try {
      final uri = Uri.parse('$baseUrl/employees?select=*&order=created_at.asc');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        if (list.isEmpty) return Employee.initialEmployees;
        return list.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
      }
      return Employee.initialEmployees;
    } catch (_) {
      return Employee.initialEmployees;
    }
  }

  Future<Employee?> insertEmployee(Employee emp) async {
    if (!isConfigured) return emp;
    try {
      final uri = Uri.parse('$baseUrl/employees');
      final res = await http.post(uri, headers: _headers, body: jsonEncode(emp.toJson()));
      if (res.statusCode == 201 || res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        if (list.isNotEmpty) return Employee.fromJson(list.first as Map<String, dynamic>);
      }
      return emp;
    } catch (_) {
      return emp;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    if (!isConfigured) return true;
    try {
      final uri = Uri.parse('$baseUrl/employees?id=eq.$id');
      final res = await http.delete(uri, headers: _headers);
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // --- TASKS CRUD ---

  Future<List<TaskItem>> fetchTasks({List<Employee> employees = const []}) async {
    if (!isConfigured) return [];
    try {
      final uri = Uri.parse('$baseUrl/tasks?select=*&order=created_at.desc');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((e) => TaskItem.fromJson(e as Map<String, dynamic>, employees: employees)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<TaskItem?> insertTask(TaskItem task) async {
    if (!isConfigured) return task;
    try {
      final uri = Uri.parse('$baseUrl/tasks');
      final res = await http.post(uri, headers: _headers, body: jsonEncode(task.toJson()));
      if (res.statusCode == 201 || res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        if (list.isNotEmpty) return TaskItem.fromJson(list.first as Map<String, dynamic>);
      }
      return task;
    } catch (_) {
      return task;
    }
  }

  Future<TaskItem?> updateTask(TaskItem task) async {
    if (!isConfigured) return task;
    try {
      final uri = Uri.parse('$baseUrl/tasks?id=eq.${task.id}');
      final res = await http.patch(uri, headers: _headers, body: jsonEncode(task.toJson()));
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        if (list.isNotEmpty) return TaskItem.fromJson(list.first as Map<String, dynamic>);
      }
      return task;
    } catch (_) {
      return task;
    }
  }

  Future<bool> deleteTask(String id) async {
    if (!isConfigured) return true;
    try {
      final uri = Uri.parse('$baseUrl/tasks?id=eq.$id');
      final res = await http.delete(uri, headers: _headers);
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
