import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/employee.dart';
import 'models/project.dart';
import 'models/task_item.dart';
import 'theme/cobalt_theme.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company Task Manager',
      debugShowCheckedModeBanner: false,
      theme: CobaltTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company Tasks')),
      body: const Center(
        child: Text(
          'Welcome to Task Manager!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CobaltTheme.slate900,
          ),
        ),
      ),
    );
  }
}
