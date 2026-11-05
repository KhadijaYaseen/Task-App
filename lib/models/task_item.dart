import 'employee.dart';

enum TaskStatus { todo, inProgress, review, done }
enum TaskPriority { urgent, high, medium, low }

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String projectName;
  final Employee assignee;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final int completedSubtasks;
  final int totalSubtasks;

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.projectName,
    required this.assignee,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.completedSubtasks = 0,
    this.totalSubtasks = 0,
  });

  bool get isOverdue =>
      status != TaskStatus.done && dueDate.isBefore(DateTime.now());

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? projectName,
    Employee? assignee,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    int? completedSubtasks,
    int? totalSubtasks,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
      totalSubtasks: totalSubtasks ?? this.totalSubtasks,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json, {List<Employee> employees = const []}) {
    final statusStr = json['status'] as String? ?? 'todo';
    final TaskStatus status;
    switch (statusStr.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        status = TaskStatus.inProgress;
        break;
      case 'review':
        status = TaskStatus.review;
        break;
      case 'done':
        status = TaskStatus.done;
        break;
      default:
        status = TaskStatus.todo;
    }

    final priorityStr = json['priority'] as String? ?? 'medium';
    final TaskPriority priority;
    switch (priorityStr.toLowerCase()) {
      case 'urgent':
        priority = TaskPriority.urgent;
        break;
      case 'high':
        priority = TaskPriority.high;
        break;
      case 'low':
        priority = TaskPriority.low;
        break;
      default:
        priority = TaskPriority.medium;
    }

    final assigneeId = json['assignee_id'] as String? ?? '';
    Employee assignee = Employee.khadija;
    if (employees.isNotEmpty) {
      assignee = employees.firstWhere(
        (e) => e.id == assigneeId,
        orElse: () => Employee.khadija,
      );
    } else {
      assignee = Employee.initialEmployees.firstWhere(
        (e) => e.id == assigneeId,
        orElse: () => Employee.khadija,
      );
    }

    final dueDateStr = json['due_date'] as String?;
    final DateTime dueDate = dueDateStr != null
        ? (DateTime.tryParse(dueDateStr) ?? DateTime.now().add(const Duration(days: 1)))
        : DateTime.now().add(const Duration(days: 1));

    return TaskItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      projectId: json['project_id'] as String? ?? 'proj_1',
      projectName: json['project_name'] as String? ?? 'General',
      assignee: assignee,
      status: status,
      priority: priority,
      dueDate: dueDate,
      completedSubtasks: (json['completed_subtasks'] as num?)?.toInt() ?? 0,
      totalSubtasks: (json['total_subtasks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr = 'todo';
    switch (status) {
      case TaskStatus.inProgress:
        statusStr = 'inProgress';
        break;
      case TaskStatus.review:
        statusStr = 'review';
        break;
      case TaskStatus.done:
        statusStr = 'done';
        break;
      case TaskStatus.todo:
        statusStr = 'todo';
        break;
    }

    String priorityStr = 'medium';
    switch (priority) {
      case TaskPriority.urgent:
        priorityStr = 'urgent';
        break;
      case TaskPriority.high:
        priorityStr = 'high';
        break;
      case TaskPriority.medium:
        priorityStr = 'medium';
        break;
      case TaskPriority.low:
        priorityStr = 'low';
        break;
    }

    return {
      'id': id,
      'title': title,
      'description': description,
      'project_id': projectId,
      'project_name': projectName,
      'assignee_id': assignee.id,
      'status': statusStr,
      'priority': priorityStr,
      'due_date': dueDate.toIso8601String(),
      'completed_subtasks': completedSubtasks,
      'total_subtasks': totalSubtasks,
    };
  }

  static List<TaskItem> sampleTasks = [
    TaskItem(
      id: 'task_1',
      title: 'Initialize Task Manager architecture & Cobalt theme',
      description: 'Set up Flutter project structure, Hallmark design tokens, and routing.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.khadija,
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      completedSubtasks: 2,
      totalSubtasks: 3,
    ),
    TaskItem(
      id: 'task_2',
      title: 'Review open-source project tracking repositories',
      description: 'Analyze TaskNexus and Plane against company mobile requirements.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.khadija,
      status: TaskStatus.done,
      priority: TaskPriority.high,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      completedSubtasks: 5,
      totalSubtasks: 5,
    ),
    TaskItem(
      id: 'task_3',
      title: 'Implement employee assignment filter & tag chips',
      description: 'Allow engineers to filter tasks by assignee and view personal workload.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.khadija,
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      completedSubtasks: 0,
      totalSubtasks: 4,
    ),
    TaskItem(
      id: 'task_4',
      title: 'Architecture sync & weekly sprint review',
      description: 'Lead review of engineering progress and milestones before Friday deploy.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.saleem,
      status: TaskStatus.review,
      priority: TaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(hours: 18)),
      completedSubtasks: 2,
      totalSubtasks: 2,
    ),
    TaskItem(
      id: 'task_5',
      title: 'Design high-contrast UI component mockups',
      description: 'Export SVG icons, status tokens, and bottom tab navigation badges.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.hamza,
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      completedSubtasks: 4,
      totalSubtasks: 4,
    ),
    TaskItem(
      id: 'task_6',
      title: 'API endpoint for real-time task status updates',
      description: 'Create Supabase / PostgreSQL schema for projects, tasks, and members.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.zain,
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      completedSubtasks: 1,
      totalSubtasks: 3,
    ),
    TaskItem(
      id: 'task_7',
      title: 'Verify offline cache fallback with local SQLite / Hive',
      description: 'Ensure tasks are viewable and queue changes when offline.',
      projectId: 'proj_1',
      projectName: 'Company Task Manager App',
      assignee: Employee.khadija,
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 4)),
      completedSubtasks: 0,
      totalSubtasks: 3,
    ),
  ];
}
