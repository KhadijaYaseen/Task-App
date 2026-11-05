import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart';
import '../models/task_item.dart';

/// Service to interact directly with Supabase Database via PostgREST REST API.
/// This approach is 100% pure Dart, super fast, and avoids Android native build conflicts.
class SupabaseService {
  // Singleton instance
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  // Supabase Project URL from your dashboard
  static const String baseUrl = 'https://pdczfoykrdqjqxbedyny.supabase.co/rest/v1';

  // Publishable Key from Supabase Dashboard
  static String anonKey = 'sb_publishable_zRuwA4sCtHV7SCO474slQQ_yAPh8JGF';

  // Test mode flag to prevent mock HTTP 400 errors during widget tests
  static bool isTestMode = false;

  static void initialize({required String key}) {
    anonKey = key.trim();
  }

  static bool get isConfigured => anonKey.isNotEmpty && !isTestMode;

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json; charset=UTF-8',
        'Prefer': 'return=representation',
      };

  // ==========================================
  // EMPLOYEES CRUD
  // ==========================================

  /// Fetch all employees from Supabase
  Future<List<Employee>> fetchEmployees() async {
    if (!isConfigured) return Employee.initialEmployees;

    try {
      final uri = Uri.parse('$baseUrl/employees?select=*&order=created_at.asc');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) return Employee.initialEmployees;
        return data.map((item) => Employee.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        debugPrint('Supabase fetchEmployees error [${response.statusCode}]: ${response.body}');
        return Employee.initialEmployees;
      }
    } catch (e) {
      debugPrint('Supabase fetchEmployees exception: $e');
      return Employee.initialEmployees;
    }
  }

  /// Add a new employee
  Future<Employee?> insertEmployee(Employee emp) async {
    if (!isConfigured) return emp;

    try {
      final uri = Uri.parse('$baseUrl/employees');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(emp.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Employee.fromJson(data.first as Map<String, dynamic>);
        }
        return emp;
      } else {
        debugPrint('Supabase insertEmployee error [${response.statusCode}]: ${response.body}');
        return emp;
      }
    } catch (e) {
      debugPrint('Supabase insertEmployee exception: $e');
      return emp;
    }
  }

  /// Delete an employee by ID
  Future<bool> deleteEmployee(String id) async {
    if (!isConfigured) return true;

    try {
      final uri = Uri.parse('$baseUrl/employees?id=eq.$id');
      final response = await http.delete(uri, headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Supabase deleteEmployee exception: $e');
      return false;
    }
  }

  // ==========================================
  // TASKS CRUD
  // ==========================================

  /// Fetch all tasks from Supabase
  Future<List<TaskItem>> fetchTasks({List<Employee> employees = const []}) async {
    if (!isConfigured) return [];

    try {
      final uri = Uri.parse('$baseUrl/tasks?select=*&order=created_at.desc');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => TaskItem.fromJson(item as Map<String, dynamic>, employees: employees))
            .toList();
      } else {
        debugPrint('Supabase fetchTasks error [${response.statusCode}]: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Supabase fetchTasks exception: $e');
      return [];
    }
  }

  /// Insert a new task
  Future<TaskItem?> insertTask(TaskItem task) async {
    if (!isConfigured) return task;

    try {
      final uri = Uri.parse('$baseUrl/tasks');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return TaskItem.fromJson(data.first as Map<String, dynamic>);
        }
        return task;
      } else {
        debugPrint('Supabase insertTask error [${response.statusCode}]: ${response.body}');
        return task;
      }
    } catch (e) {
      debugPrint('Supabase insertTask exception: $e');
      return task;
    }
  }

  /// Update an existing task
  Future<TaskItem?> updateTask(TaskItem task) async {
    if (!isConfigured) return task;

    try {
      final uri = Uri.parse('$baseUrl/tasks?id=eq.${task.id}');
      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return TaskItem.fromJson(data.first as Map<String, dynamic>);
        }
        return task;
      } else {
        debugPrint('Supabase updateTask error [${response.statusCode}]: ${response.body}');
        return task;
      }
    } catch (e) {
      debugPrint('Supabase updateTask exception: $e');
      return task;
    }
  }

  /// Delete a task by ID
  Future<bool> deleteTask(String id) async {
    if (!isConfigured) return true;

    try {
      final uri = Uri.parse('$baseUrl/tasks?id=eq.$id');
      final response = await http.delete(uri, headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Supabase deleteTask exception: $e');
      return false;
    }
  }
}
