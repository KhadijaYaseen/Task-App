import 'package:flutter/material.dart';
import 'models/employee.dart';
import 'models/task_item.dart';
import 'theme/cobalt_theme.dart';
import 'widgets/cobalt_key.dart';

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
  // Real dynamic task list - starts 100% EMPTY (no fake hardcoded data!)
  final List<TaskItem> _tasks = [];
  int _selectedFilterIndex = 0; // 0: All, 1: My Tasks (KY), 2: In Progress, 3: Completed
  String _searchQuery = '';

  List<TaskItem> get _filteredTasks {
    List<TaskItem> list = _tasks;
    if (_searchQuery.trim().isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.projectName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    switch (_selectedFilterIndex) {
      case 1:
        return list.where((t) => t.assignee.id == Employee.khadija.id).toList();
      case 2:
        return list.where((t) => t.status == TaskStatus.inProgress).toList();
      case 3:
        return list.where((t) => t.status == TaskStatus.done).toList();
      default:
        return list;
    }
  }

  int get _activeCount => _tasks.where((t) => t.status != TaskStatus.done).length;
  int get _inProgressCount => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get _completedCount => _tasks.where((t) => t.status == TaskStatus.done).length;

  void _addNewTask({
    required String title,
    required String projectName,
    required TaskPriority priority,
    required Employee assignee,
  }) {
    setState(() {
      _tasks.insert(
        0,
        TaskItem(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: 'Deliverable for $projectName',
          projectId: 'proj_dynamic',
          projectName: projectName.isEmpty ? 'Internal Ops' : projectName,
          assignee: assignee,
          status: TaskStatus.inProgress,
          priority: priority,
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );
    });
  }

  void _toggleTaskStatus(TaskItem task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final newStatus = task.status == TaskStatus.done
            ? TaskStatus.inProgress
            : TaskStatus.done;
        _tasks[index] = TaskItem(
          id: task.id,
          title: task.title,
          description: task.description,
          projectId: task.projectId,
          projectName: task.projectName,
          assignee: task.assignee,
          status: newStatus,
          priority: task.priority,
          dueDate: task.dueDate,
          completedSubtasks: task.completedSubtasks,
          totalSubtasks: task.totalSubtasks,
        );
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CobaltTheme.paper,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: CobaltTheme.accentWash,
                borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                border: Border.all(color: CobaltTheme.accentHover.withValues(alpha: 0.2)),
              ),
              child: const Text(
                '▸',
                style: TextStyle(
                  color: CobaltTheme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Company Tasks',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: CobaltTheme.ink,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          // Authentic Cobalt Keycap button for New Task
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CobaltKey(
              label: '+ New Task',
              isSmall: true,
              variant: CobaltKeyVariant.primary,
              onPressed: () => _showAddTaskModal(context),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: CobaltTheme.rule, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Jump / Search Bar with "⌘ K" keycap shortcut
            _buildJumpSearchBar(),

            const SizedBox(height: 16),

            // 2. Metric Ledger Overview (Dynamic counts from real tasks!)
            _buildMetricSummary(),

            const SizedBox(height: 20),

            // 3. Segmented Filter Tray
            _buildFilterTray(),

            const SizedBox(height: 16),

            // 4. Tasks Stream (Real dynamic list or Authentic Cobalt Empty State)
            if (_filteredTasks.isEmpty)
              _buildCobaltEmptyState()
            else
              ..._filteredTasks.map((t) => _buildCobaltTaskCard(t)),
          ],
        ),
      ),
    );
  }

  // --- Hallmark Cobalt Components ---

  Widget _buildJumpSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
        border: Border.all(color: CobaltTheme.rule2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: CobaltTheme.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Jump to a task or project...',
                hintStyle: TextStyle(
                  color: CobaltTheme.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: CobaltTheme.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Hallmark Keycap shortcut badge "⌘ K"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CobaltTheme.paper2,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: CobaltTheme.rule2),
              boxShadow: const [
                BoxShadow(color: CobaltTheme.keyEdge, offset: Offset(0, 1)),
              ],
            ),
            child: const Text(
              '⌘ K',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CobaltTheme.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSummary() {
    return Row(
      children: [
        _buildMetricBox('Active', '$_activeCount', CobaltTheme.ink),
        const SizedBox(width: 10),
        _buildMetricBox('In Progress', '$_inProgressCount', CobaltTheme.statusWarning),
        const SizedBox(width: 10),
        _buildMetricBox('Completed', '$_completedCount', CobaltTheme.statusSuccess),
      ],
    );
  }

  Widget _buildMetricBox(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
          border: Border.all(color: CobaltTheme.rule),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CobaltTheme.muted,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTray() {
    final filters = [
      'All ($_activeCount)',
      'My Tasks',
      'In Progress',
      'Completed',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CobaltTheme.paper2,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput + 2),
        border: Border.all(color: CobaltTheme.rule2),
      ),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x120F172A),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filters[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? CobaltTheme.ink : CobaltTheme.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCobaltEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: CobaltTheme.rule2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CobaltTheme.accentWash,
              shape: BoxShape.circle,
              border: Border.all(color: CobaltTheme.accent.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.layers_clear_outlined,
              size: 28,
              color: CobaltTheme.accent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CobaltTheme.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your workspace is clean. Create your first task to start tracking company deliverables.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: CobaltTheme.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          CobaltKey(
            label: '+ Create First Task',
            onPressed: () => _showAddTaskModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCobaltTaskCard(TaskItem task) {
    final isDone = task.status == TaskStatus.done;

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
      case TaskPriority.high:
        priorityColor = CobaltTheme.statusError;
        break;
      case TaskPriority.medium:
        priorityColor = CobaltTheme.statusWarning;
        break;
      case TaskPriority.low:
        priorityColor = CobaltTheme.muted;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: isDone ? CobaltTheme.rule : CobaltTheme.rule2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox toggle
          GestureDetector(
            onTap: () => _toggleTaskStatus(task),
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? CobaltTheme.accent : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDone ? CobaltTheme.accent : CobaltTheme.rule2,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.projectName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDone ? CobaltTheme.muted : CobaltTheme.ink,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: CobaltTheme.paper2,
                          child: Text(
                            task.assignee.initials,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: CobaltTheme.ink2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          task.assignee.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: CobaltTheme.ink2,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _deleteTask(task.id),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: CobaltTheme.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final projectController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.high;
    Employee selectedAssignee = Employee.khadija;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Task Milestone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: CobaltTheme.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'e.g. Implement user login API',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        borderSide: const BorderSide(color: CobaltTheme.rule2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: projectController,
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      hintText: 'e.g. Task-App',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        borderSide: const BorderSide(color: CobaltTheme.rule2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Priority',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CobaltTheme.ink2),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TaskPriority.urgent,
                      TaskPriority.high,
                      TaskPriority.medium,
                      TaskPriority.low,
                    ].map((p) {
                      final isSel = selectedPriority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.name.toUpperCase()),
                          selected: isSel,
                          onSelected: (_) => setModalState(() => selectedPriority = p),
                          selectedColor: CobaltTheme.accent,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : CobaltTheme.ink2,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CobaltKey(
                      label: 'Create Milestone',
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          _addNewTask(
                            title: titleController.text.trim(),
                            projectName: projectController.text.trim(),
                            priority: selectedPriority,
                            assignee: selectedAssignee,
                          );
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
