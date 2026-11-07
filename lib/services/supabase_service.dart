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
