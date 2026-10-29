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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 0: All, 1: My Tasks (KY), 2: In Progress, 3: High Priority
  int _selectedFilterIndex = 0;

  List<TaskItem> get _filteredTasks {
    switch (_selectedFilterIndex) {
      case 1:
        return TaskItem.sampleTasks
            .where((t) => t.assignee.id == Employee.khadija.id)
            .toList();
      case 2:
        return TaskItem.sampleTasks
            .where((t) => t.status == TaskStatus.inProgress)
            .toList();
      case 3:
        return TaskItem.sampleTasks
            .where((t) =>
                t.priority == TaskPriority.high ||
                t.priority == TaskPriority.urgent)
            .toList();
      default:
        return TaskItem.sampleTasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todayFormatted.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CobaltTheme.slate500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Company Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: CobaltTheme.slate900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CobaltTheme.slate100,
              shape: BoxShape.circle,
              border: Border.all(color: CobaltTheme.slate200),
            ),
            child: const Text(
              'KY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CobaltTheme.slate900,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Metric Summary Overview
            _buildMetricSummary(),

            const SizedBox(height: 24),

            // 2. Active Projects Hub
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Projects',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.slate900,
                  ),
                ),
                Text(
                  '${Project.sampleProjects.length} Active',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CobaltTheme.cobaltBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProjectsList(),

            const SizedBox(height: 24),

            // 3. Filter Chips
            const Text(
              'Tasks & Milestones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CobaltTheme.slate900,
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterChips(),

            const SizedBox(height: 16),

            // 4. Task Cards List
            ..._filteredTasks.map((task) => _buildTaskCard(task)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New Task creation modal coming in Module 2!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: CobaltTheme.slate900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildMetricSummary() {
    return Row(
      children: [
        _buildMetricBox('Active Tasks', '12', CobaltTheme.slate900),
        const SizedBox(width: 12),
        _buildMetricBox('In Progress', '5', CobaltTheme.statusInProgress),
        const SizedBox(width: 12),
        _buildMetricBox('Completed', '8', CobaltTheme.statusDone),
      ],
    );
  }

  Widget _buildMetricBox(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CobaltTheme.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CobaltTheme.slate500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: Project.sampleProjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final project = Project.sampleProjects[index];
          return Container(
            width: 240,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CobaltTheme.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: CobaltTheme.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        project.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: CobaltTheme.slate700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.slate900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${project.completedTasks}/${project.totalTasks} Tasks',
                          style: const TextStyle(
                            fontSize: 11,
                            color: CobaltTheme.slate500,
                          ),
                        ),
                        Text(
                          '${project.progressPercent}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CobaltTheme.cobaltBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progress,
                        minHeight: 6,
                        backgroundColor: CobaltTheme.slate100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          CobaltTheme.cobaltBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All Tasks',
      'My Tasks (KY)',
      'In Progress',
      'High Priority',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilterIndex = index);
                }
              },
              selectedColor: CobaltTheme.slate900,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CobaltTheme.slate700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: isSelected
                    ? CobaltTheme.slate900
                    : CobaltTheme.slate200,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
      case TaskPriority.high:
        priorityColor = CobaltTheme.priorityUrgent;
        break;
      case TaskPriority.medium:
        priorityColor = CobaltTheme.priorityMedium;
        break;
      case TaskPriority.low:
        priorityColor = CobaltTheme.priorityLow;
        break;
    }

    String statusText;
    Color statusBg;
    Color statusColor;
    switch (task.status) {
      case TaskStatus.todo:
        statusText = 'To-Do';
        statusBg = CobaltTheme.slate100;
        statusColor = CobaltTheme.slate600;
        break;
      case TaskStatus.inProgress:
        statusText = 'In Progress';
        statusBg = const Color(0xFFFEF3C7);
        statusColor = const Color(0xFFB45309);
        break;
      case TaskStatus.review:
        statusText = 'In Review';
        statusBg = const Color(0xFFEDE9FE);
        statusColor = const Color(0xFF6D28D9);
        break;
      case TaskStatus.done:
        statusText = 'Completed';
        statusBg = const Color(0xFFDCFCE7);
        statusColor = const Color(0xFF15803D);
        break;
    }

    final dueFormatted = DateFormat('MMM d').format(task.dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CobaltTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.projectName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CobaltTheme.cobaltBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CobaltTheme.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.description,
            style: const TextStyle(fontSize: 12, color: CobaltTheme.slate500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: CobaltTheme.slate100),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: CobaltTheme.slate200,
                    child: Text(
                      task.assignee.initials,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.slate800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.assignee.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CobaltTheme.slate700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (task.totalSubtasks > 0) ...[
                    const Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: CobaltTheme.slate400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.completedSubtasks}/${task.totalSubtasks}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: CobaltTheme.slate500,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: CobaltTheme.slate400,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    dueFormatted,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CobaltTheme.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
