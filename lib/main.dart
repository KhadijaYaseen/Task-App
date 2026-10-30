import 'package:flutter/material.dart';
import 'models/employee.dart';
import 'models/task_item.dart';
import 'screens/login_screen.dart';
import 'screens/team_screen.dart';
import 'theme/cobalt_theme.dart';
import 'widgets/cobalt_key.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  // Global dynamic state
  final List<Employee> _employees = List.from(Employee.initialEmployees);
  Employee? _currentUser;
  final List<TaskItem> _tasks = [];

  void _handleLogin(Employee user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
    });
  }

  void _handleAddEmployee(Employee newEmp) {
    setState(() {
      _employees.add(newEmp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company Task Manager',
      debugShowCheckedModeBanner: false,
      theme: CobaltTheme.lightTheme,
      home: _currentUser == null
          ? LoginScreen(
              employees: _employees,
              onLoginSuccess: _handleLogin,
            )
          : DashboardScreen(
              currentUser: _currentUser!,
              employees: _employees,
              tasks: _tasks,
              onLogout: _handleLogout,
              onAddEmployee: _handleAddEmployee,
            ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final Employee currentUser;
  final List<Employee> employees;
  final List<TaskItem> tasks;
  final VoidCallback onLogout;
  final Function(Employee newEmp) onAddEmployee;

  const DashboardScreen({
    super.key,
    required this.currentUser,
    required this.employees,
    required this.tasks,
    required this.onLogout,
    required this.onAddEmployee,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: My Tasks, 2: In Progress, 3: Completed
  String _searchQuery = '';

  List<TaskItem> get _filteredTasks {
    List<TaskItem> list = widget.tasks;
    if (_searchQuery.trim().isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.projectName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    switch (_selectedFilterIndex) {
      case 1:
        // Filter dynamically by active current user's ID
        return list.where((t) => t.assignee.id == widget.currentUser.id).toList();
      case 2:
        return list.where((t) => t.status == TaskStatus.inProgress).toList();
      case 3:
        return list.where((t) => t.status == TaskStatus.done).toList();
      default:
        return list;
    }
  }

  int get _activeCount => widget.tasks.where((t) => t.status != TaskStatus.done).length;
  int get _inProgressCount => widget.tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get _completedCount => widget.tasks.where((t) => t.status == TaskStatus.done).length;

  void _addNewTask({
    required String title,
    required String projectName,
    required TaskPriority priority,
    required Employee assignee,
  }) {
    setState(() {
      widget.tasks.insert(
        0,
        TaskItem(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: 'Deliverable for $projectName',
          projectId: 'proj_dynamic',
          projectName: projectName.isEmpty ? 'Company Task-App' : projectName,
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
      final index = widget.tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final newStatus = task.status == TaskStatus.done
            ? TaskStatus.inProgress
            : TaskStatus.done;
        widget.tasks[index] = TaskItem(
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
      widget.tasks.removeWhere((t) => t.id == id);
    });
  }

  void _requestAdminAuth({
    required String actionDescription,
    required VoidCallback onAuthorized,
  }) {
    final adminIdController = TextEditingController(text: 'admin');
    final adminPassController = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
                side: const BorderSide(color: CobaltTheme.rule2),
              ),
              title: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 20, color: CobaltTheme.accent),
                  SizedBox(width: 8),
                  Text(
                    'Admin Access Required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$actionDescription is restricted to Tech Lead (Saleem). Enter Admin ID & Password to proceed:',
                    style: const TextStyle(fontSize: 12, color: CobaltTheme.muted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text(
                        errorMsg!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CobaltTheme.statusError,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: adminIdController,
                    decoration: InputDecoration(
                      labelText: 'Admin ID',
                      hintText: 'admin or saleem',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        borderSide: const BorderSide(color: CobaltTheme.rule2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: adminPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Admin Password',
                      hintText: '••••••••',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        borderSide: const BorderSide(color: CobaltTheme.rule2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: CobaltTheme.muted)),
                ),
                CobaltKey(
                  label: 'Authorize',
                  isSmall: true,
                  variant: CobaltKeyVariant.primary,
                  onPressed: () {
                    final id = adminIdController.text.trim().toLowerCase();
                    final pass = adminPassController.text;
                    if ((id == 'admin' || id == 'saleem') && (pass == 'admin123' || pass == 'saleem123')) {
                      Navigator.pop(ctx);
                      onAuthorized();
                    } else {
                      setDialogState(() {
                        errorMsg = 'Incorrect Admin ID or Password. Try again.';
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onAddTaskPressed() {
    if (widget.currentUser.isAdmin) {
      _showAddTaskModal(context);
    } else {
      _requestAdminAuth(
        actionDescription: 'Assigning new milestone deliverables',
        onAuthorized: () => _showAddTaskModal(context),
      );
    }
  }

  void _openTeamScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamScreen(
          employees: widget.employees,
          currentUser: widget.currentUser,
          onAddEmployee: widget.onAddEmployee,
        ),
      ),
    );
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: widget.currentUser.isAdmin
                    ? CobaltTheme.accent
                    : CobaltTheme.paper3,
                child: Text(
                  widget.currentUser.initials,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: widget.currentUser.isAdmin ? Colors.white : CobaltTheme.ink,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.currentUser.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: CobaltTheme.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.currentUser.role,
                style: const TextStyle(fontSize: 12, color: CobaltTheme.muted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.currentUser.isAdmin
                      ? CobaltTheme.accentWash
                      : CobaltTheme.paper2,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.currentUser.isAdmin
                        ? CobaltTheme.accentHover.withValues(alpha: 0.2)
                        : CobaltTheme.rule,
                  ),
                ),
                child: Text(
                  widget.currentUser.isAdmin ? '👑 Tech Lead / Admin' : '🚀 Team Member',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.currentUser.isAdmin ? CobaltTheme.accent : CobaltTheme.ink2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CobaltKey(
                label: 'Switch Profile / Sign Out',
                icon: Icons.logout,
                variant: CobaltKeyVariant.neutral,
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onLogout();
                },
              ),
            ],
          ),
        );
      },
    );
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
                border: Border.all(
                  color: CobaltTheme.accentHover.withValues(alpha: 0.2),
                ),
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
          // Team Roster Shortcut
          IconButton(
            tooltip: 'Team Directory',
            icon: const Icon(Icons.group_outlined, color: CobaltTheme.ink2, size: 21),
            onPressed: _openTeamScreen,
          ),

          // User Profile Badge
          InkWell(
            onTap: _showProfileModal,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: widget.currentUser.isAdmin
                    ? CobaltTheme.accent
                    : CobaltTheme.paper3,
                child: Text(
                  widget.currentUser.initials,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: widget.currentUser.isAdmin ? Colors.white : CobaltTheme.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // New Task Tactile Keycap
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CobaltKey(
              label: '+ New Task',
              isSmall: true,
              variant: CobaltKeyVariant.primary,
              onPressed: _onAddTaskPressed,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: CobaltTheme.rule, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Role Status Banner
              _buildRoleBanner(),
              const SizedBox(height: 14),

              // Hallmark Cobalt Jump Search Bar
              _buildCobaltJumpBar(),
              const SizedBox(height: 16),

              // Executive Metric Ledger
              _buildExecutiveLedger(),
              const SizedBox(height: 18),

              // Hallmark Cobalt Filter Tray
              _buildFilterTray(),
              const SizedBox(height: 16),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedFilterIndex == 1
                        ? 'My Deliverables (${_filteredTasks.length})'
                        : 'Deliverables & Milestones (${_filteredTasks.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink2,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (widget.tasks.isNotEmpty)
                    Text(
                      '${_filteredTasks.length} shown',
                      style: const TextStyle(fontSize: 11, color: CobaltTheme.muted),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Task List or Clean Cobalt Empty State
              _filteredTasks.isEmpty
                  ? _buildCobaltEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBanner() {
    final isAdmin = widget.currentUser.isAdmin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAdmin ? CobaltTheme.accentWash : CobaltTheme.paper2,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
        border: Border.all(
          color: isAdmin
              ? CobaltTheme.accentHover.withValues(alpha: 0.25)
              : CobaltTheme.rule,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
            size: 16,
            color: isAdmin ? CobaltTheme.accent : CobaltTheme.ink2,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Session: ${widget.currentUser.name} (${isAdmin ? "Tech Lead • Full Rights" : "Team Member • Updating Deliverables"})',
              style: TextStyle(
                fontSize: 12,
                color: CobaltTheme.ink,
                fontWeight: isAdmin ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: CobaltTheme.rule2),
              ),
              child: const Text(
                'Switch',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: CobaltTheme.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCobaltJumpBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
        border: Border.all(color: CobaltTheme.rule2),
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
                hintStyle: TextStyle(fontSize: 13, color: CobaltTheme.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // ⌘ K tactile keycap badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: CobaltTheme.paper2,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: CobaltTheme.rule2),
            ),
            child: const Text(
              '⌘ K',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: CobaltTheme.ink2,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveLedger() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricBox(
            label: 'Active',
            count: _activeCount,
            countColor: CobaltTheme.ink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricBox(
            label: 'In Progress',
            count: _inProgressCount,
            countColor: CobaltTheme.statusWarning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricBox(
            label: 'Completed',
            count: _completedCount,
            countColor: CobaltTheme.statusSuccess,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required int count,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: CobaltTheme.rule2),
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
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: countColor,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTray() {
    final filters = [
      'All (${widget.tasks.length})',
      'My Tasks',
      'In Progress',
      'Completed',
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CobaltTheme.paper2,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: CobaltTheme.rule),
      ),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                  border: isSelected
                      ? Border.all(color: CobaltTheme.rule2)
                      : Border.all(color: Colors.transparent),
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
              border: Border.all(
                color: CobaltTheme.accent.withValues(alpha: 0.2),
              ),
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
          Text(
            widget.currentUser.isAdmin
                ? 'Your workspace is clean. Create your first milestone deliverable and assign it to a team member.'
                : 'You have no assigned tasks in this view. Check back once Tech Lead assigns deliverables.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: CobaltTheme.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          CobaltKey(
            label: widget.currentUser.isAdmin ? '+ Create First Task' : 'Refresh Workspace',
            icon: widget.currentUser.isAdmin ? Icons.add : Icons.refresh,
            onPressed: () {
              if (widget.currentUser.isAdmin) {
                _showAddTaskModal(context);
              } else {
                setState(() => _selectedFilterIndex = 0);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    final isDone = task.status == TaskStatus.done;
    final isAssignedToMe = task.assignee.id == widget.currentUser.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(
          color: isAssignedToMe ? CobaltTheme.accent : CobaltTheme.rule2,
          width: isAssignedToMe ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Project Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: CobaltTheme.paper2,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.projectName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.accent,
                  ),
                ),
              ),
              const Spacer(),
              // Priority Dot
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _getPriorityColor(task.priority),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title & Completion Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _toggleTaskStatus(task),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2, right: 10),
                  decoration: BoxDecoration(
                    color: isDone ? CobaltTheme.statusSuccess : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDone ? CobaltTheme.statusSuccess : CobaltTheme.rule2,
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone ? CobaltTheme.muted : CobaltTheme.ink,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 17, color: CobaltTheme.muted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _deleteTask(task.id),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Assignee & Status Footer
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: task.assignee.isAdmin
                    ? CobaltTheme.accent
                    : CobaltTheme.paper3,
                child: Text(
                  task.assignee.initials,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: task.assignee.isAdmin ? Colors.white : CobaltTheme.ink,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.assignee.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CobaltTheme.ink2,
                ),
              ),
              if (isAssignedToMe) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: CobaltTheme.accentWash,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: CobaltTheme.accent,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDone
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  isDone ? 'Completed' : 'In Progress',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDone
                        ? CobaltTheme.statusSuccess
                        : CobaltTheme.statusWarning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Color(0xFFDC2626);
      case TaskPriority.high:
        return const Color(0xFFEA580C);
      case TaskPriority.medium:
        return const Color(0xFFD97706);
      case TaskPriority.low:
        return const Color(0xFF64748B);
    }
  }

  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final projectController = TextEditingController(text: 'Task-App');
    TaskPriority selectedPriority = TaskPriority.high;
    Employee selectedAssignee = widget.employees.firstWhere(
      (e) => e.id == Employee.khadija.id,
      orElse: () => widget.employees.first,
    );

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
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Milestone Deliverable',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: CobaltTheme.ink,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: CobaltTheme.muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Deliverable Title',
                      hintText: 'e.g. Implement Role-Based Login UI',
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

                  // Assignee Dynamic Selector
                  const Text(
                    'Assignee (Team Member)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      border: Border.all(color: CobaltTheme.rule2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Employee>(
                        isExpanded: true,
                        value: selectedAssignee,
                        items: widget.employees.map((emp) {
                          return DropdownMenuItem<Employee>(
                            value: emp,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: emp.isAdmin
                                      ? CobaltTheme.accent
                                      : CobaltTheme.paper3,
                                  child: Text(
                                    emp.initials,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: emp.isAdmin ? Colors.white : CobaltTheme.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  emp.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: CobaltTheme.ink,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${emp.role})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: CobaltTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newEmp) {
                          if (newEmp != null) {
                            setModalState(() => selectedAssignee = newEmp);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink2,
                    ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CobaltKey(
                      label: 'Assign Milestone',
                      icon: Icons.assignment_turned_in,
                      variant: CobaltKeyVariant.primary,
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
