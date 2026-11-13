import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/employee.dart';
import 'models/task_item.dart';
import 'models/attendance_record.dart';
import 'screens/login_screen.dart';
import 'screens/team_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/attendance_screen.dart';
import 'services/supabase_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
  }

  Future<void> _loadDataFromSupabase() async {
    try {
      final emps = await SupabaseService.instance.fetchEmployees();
      final tasks = await SupabaseService.instance.fetchTasks(employees: emps);
      if (mounted) {
        setState(() {
          if (emps.isNotEmpty) {
            _employees.clear();
            _employees.addAll(emps);
          }
          if (tasks.isNotEmpty) {
            _tasks.clear();
            _tasks.addAll(tasks);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading from Supabase: $e');
    }
  }

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
    SupabaseService.instance.insertEmployee(newEmp);
  }

  void _handleDeleteEmployee(Employee emp) {
    setState(() {
      _employees.removeWhere((e) => e.id == emp.id);
    });
    SupabaseService.instance.deleteEmployee(emp.id);
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
              onDeleteEmployee: _handleDeleteEmployee,
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
  final Function(Employee emp)? onDeleteEmployee;
  final List<AttendanceRecord>? initialAttendanceRecords;
  final Function(AttendanceRecord newRecord)? onAddAttendance;

  const DashboardScreen({
    super.key,
    required this.currentUser,
    required this.employees,
    required this.tasks,
    required this.onLogout,
    required this.onAddEmployee,
    this.onDeleteEmployee,
    this.initialAttendanceRecords,
    this.onAddAttendance,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0; // 0: Tasks, 1: Attendance, 2: Analytics
  int _selectedFilterIndex = 0; // 0: All, 1: My Tasks, 2: In Progress, 3: Completed
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _hoveredTaskId;
  late List<AttendanceRecord> _attendanceRecords;

  @override
  void initState() {
    super.initState();
    _attendanceRecords = widget.initialAttendanceRecords != null
        ? List.from(widget.initialAttendanceRecords!)
        : AttendanceRecord.getSampleRecords(widget.employees);
  }

  void _handleAddAttendance(AttendanceRecord newRecord) {
    setState(() {
      _attendanceRecords.insert(0, newRecord);
    });
    if (widget.onAddAttendance != null) {
      widget.onAddAttendance!(newRecord);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TaskItem> get _filteredTasks {
    List<TaskItem> list = widget.tasks;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      final isSelfIntent = q == 'my task' || q == 'my tasks' || q == 'mine' || q == 'me';
      list = list.where((t) {
        if (isSelfIntent) {
          return t.assignee.id == widget.currentUser.id;
        }
        return t.title.toLowerCase().contains(q) ||
            t.projectName.toLowerCase().contains(q) ||
            t.assignee.name.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q);
      }).toList();
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
    required DateTime dueDate,
  }) {
    final newTask = TaskItem(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'Deliverable for $projectName',
      projectId: 'proj_dynamic',
      projectName: projectName.isEmpty ? 'Company Task-App' : projectName,
      assignee: assignee,
      status: TaskStatus.inProgress,
      priority: priority,
      dueDate: dueDate,
    );
    setState(() {
      widget.tasks.insert(0, newTask);
    });
    SupabaseService.instance.insertTask(newTask);
  }

  void _editTask({
    required String id,
    required String title,
    required String projectName,
    required TaskPriority priority,
    required Employee assignee,
    required DateTime dueDate,
  }) {
    setState(() {
      final index = widget.tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final updated = widget.tasks[index].copyWith(
          title: title,
          projectName: projectName.isEmpty ? widget.tasks[index].projectName : projectName,
          priority: priority,
          assignee: assignee,
          dueDate: dueDate,
        );
        widget.tasks[index] = updated;
        SupabaseService.instance.updateTask(updated);
      }
    });
  }

  void _toggleTaskStatus(TaskItem task) {
    final isAssignedToMe = task.assignee.id == widget.currentUser.id;
    if (!widget.currentUser.isAdmin && !isAssignedToMe) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${task.assignee.name} or Tech Lead can update this deliverable.',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: CobaltTheme.ink,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      final index = widget.tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final newStatus = task.status == TaskStatus.done
            ? TaskStatus.inProgress
            : TaskStatus.done;
        final updated = task.copyWith(
          status: newStatus,
        );
        widget.tasks[index] = updated;
        SupabaseService.instance.updateTask(updated);
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      widget.tasks.removeWhere((t) => t.id == id);
    });
    SupabaseService.instance.deleteTask(id);
  }

  Future<void> _refreshFromCloud() async {
    try {
      final freshTasks = await SupabaseService.instance.fetchTasks(employees: widget.employees);
      if (mounted && freshTasks.isNotEmpty) {
        setState(() {
          widget.tasks.clear();
          widget.tasks.addAll(freshTasks);
        });
      }
    } catch (_) {}
  }

  void _confirmDeleteTask(TaskItem task) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
            side: const BorderSide(color: CobaltTheme.rule2),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Delete Task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CobaltTheme.ink,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"? This cannot be undone.',
            style: const TextStyle(
              fontSize: 13,
              color: CobaltTheme.ink2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: CobaltTheme.muted)),
            ),
            CobaltKey(
              label: 'Delete',
              isSmall: true,
              variant: CobaltKeyVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                _deleteTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task "${task.title}" deleted.'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: CobaltTheme.ink,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _requestAdminAuth({
    required String actionDescription,
    required VoidCallback onAuthorized,
  }) {
    final adminIdController = TextEditingController();
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
          onDeleteEmployee: widget.onDeleteEmployee,
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
        title: InkWell(
          onTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentTabIndex != 0) ...[
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: CobaltTheme.paper2,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      border: Border.all(color: CobaltTheme.rule2),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: CobaltTheme.ink,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Back to Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink,
                      letterSpacing: -0.4,
                    ),
                  ),
                ] else ...[
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
              ],
            ),
          ),
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
                    ? CobaltTheme.purplePrimary
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

          // Action Keycap: "+ New Task" on Tasks tab, "View Tasks" on other tabs
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _currentTabIndex == 0
                ? CobaltKey(
                    label: '+ New Task',
                    isSmall: true,
                    variant: CobaltKeyVariant.primary,
                    onPressed: _onAddTaskPressed,
                  )
                : CobaltKey(
                    label: 'Tasks',
                    icon: Icons.checklist_rounded,
                    isSmall: true,
                    variant: CobaltKeyVariant.neutral,
                    onPressed: () {
                      setState(() {
                        _currentTabIndex = 0;
                      });
                    },
                  ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Column(
            children: [
              Container(color: CobaltTheme.rule, height: 1),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTabIndex = 0),
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentTabIndex == 0 ? CobaltTheme.purpleWash : Colors.transparent,
                            borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                            border: Border.all(
                              color: _currentTabIndex == 0 ? CobaltTheme.purplePrimary : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 15,
                                color: _currentTabIndex == 0 ? CobaltTheme.purplePrimary : CobaltTheme.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tasks',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _currentTabIndex == 0 ? FontWeight.w800 : FontWeight.w600,
                                  color: _currentTabIndex == 0 ? CobaltTheme.purplePrimary : CobaltTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTabIndex = 1),
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentTabIndex == 1 ? CobaltTheme.purpleWash : Colors.transparent,
                            borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                            border: Border.all(
                              color: _currentTabIndex == 1 ? CobaltTheme.purplePrimary : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 15,
                                color: _currentTabIndex == 1 ? CobaltTheme.purplePrimary : CobaltTheme.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Attendance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _currentTabIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                                  color: _currentTabIndex == 1 ? CobaltTheme.purplePrimary : CobaltTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTabIndex = 2),
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentTabIndex == 2 ? CobaltTheme.purpleWash : Colors.transparent,
                            borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                            border: Border.all(
                              color: _currentTabIndex == 2 ? CobaltTheme.purplePrimary : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pie_chart_outline_rounded,
                                size: 15,
                                color: _currentTabIndex == 2 ? CobaltTheme.purplePrimary : CobaltTheme.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Analytics',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _currentTabIndex == 2 ? FontWeight.w800 : FontWeight.w600,
                                  color: _currentTabIndex == 2 ? CobaltTheme.purplePrimary : CobaltTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(color: CobaltTheme.rule, height: 1),
            ],
          ),
        ),
      ),
      body: _currentTabIndex == 0
          ? _buildTasksTab()
          : _currentTabIndex == 1
              ? AttendanceScreen(
                  currentUser: widget.currentUser,
                  employees: widget.employees,
                  attendanceRecords: _attendanceRecords,
                  onAddAttendance: _handleAddAttendance,
                )
              : StatsScreen(
                  tasks: widget.tasks,
                  employees: widget.employees,
                  attendanceRecords: _attendanceRecords,
                  onBackToTasks: () => setState(() => _currentTabIndex = 0),
                ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: CobaltTheme.rule2, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: CobaltTheme.purplePrimary,
          unselectedItemColor: CobaltTheme.muted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role status banner
            _buildRoleBanner(),
            const SizedBox(height: 14),

            // Search bar
            _buildCobaltJumpBar(),
            const SizedBox(height: 16),

            // Metrics summary
            _buildExecutiveLedger(),
            const SizedBox(height: 18),

            // Status filters
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

            // Task list or empty state
            _filteredTasks.isEmpty
                ? _buildCobaltEmptyState()
                : _selectedFilterIndex == 0 && _searchQuery.isEmpty
                    ? ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredTasks.length,
                        onReorderItem: (oldIndex, newIndex) {
                          setState(() {
                            final item = widget.tasks.removeAt(oldIndex);
                            widget.tasks.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return Container(
                            key: ValueKey(task.id),
                            child: _buildTaskCard(task),
                          );
                        },
                      )
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
    );
  }

  Widget _buildRoleBanner() {
    final isAdmin = widget.currentUser.isAdmin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAdmin ? CobaltTheme.purpleWash : CobaltTheme.paper2,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
        border: Border.all(
          color: isAdmin
              ? CobaltTheme.purpleLight
              : CobaltTheme.rule,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
            size: 16,
            color: isAdmin ? CobaltTheme.purplePrimary : CobaltTheme.ink2,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: CobaltTheme.primaryGradient,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: CobaltTheme.purplePrimary.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Switch',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
              controller: _searchController,
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
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.close, size: 16, color: CobaltTheme.muted),
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
            gradient: const LinearGradient(
              colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: const Color(0xFFDDD6FE),
            countColor: CobaltTheme.purplePrimary,
            icon: Icons.bolt_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricBox(
            label: 'In Progress',
            count: _inProgressCount,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: const Color(0xFFFDE68A),
            countColor: const Color(0xFFD97706),
            icon: Icons.hourglass_top_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricBox(
            label: 'Completed',
            count: _completedCount,
            gradient: const LinearGradient(
              colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: const Color(0xFFBBF7D0),
            countColor: const Color(0xFF16A34A),
            icon: Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required int count,
    required Gradient gradient,
    required Color borderColor,
    required Color countColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CobaltTheme.ink2,
                ),
              ),
              Icon(icon, size: 14, color: countColor.withAlpha(200)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CobaltTheme.paper2,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
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
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected ? CobaltTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: CobaltTheme.purplePrimary.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                    color: isSelected ? Colors.white : CobaltTheme.muted,
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
                _refreshFromCloud();
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
    final canToggle = widget.currentUser.isAdmin || isAssignedToMe;
    final isHovered = _hoveredTaskId == task.id;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTaskId = task.id),
      onExit: (_) => setState(() {
        if (_hoveredTaskId == task.id) _hoveredTaskId = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
          border: Border.all(
            color: isHovered
                ? CobaltTheme.purplePrimary
                : CobaltTheme.rule2,
            width: isHovered ? 1.8 : 1.0,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: CobaltTheme.purplePrimary.withAlpha(35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Project Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CobaltTheme.purpleWash,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: CobaltTheme.purpleLight),
                  ),
                  child: Text(
                    task.projectName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.purplePrimary,
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
              Tooltip(
                message: canToggle
                    ? (isDone ? 'Mark as In Progress' : 'Mark as Done')
                    : 'Assigned to ${task.assignee.name} (View only)',
                child: GestureDetector(
                  onTap: () => _toggleTaskStatus(task),
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2, right: 10),
                    decoration: BoxDecoration(
                      color: isDone
                          ? (canToggle ? CobaltTheme.statusSuccess : CobaltTheme.statusSuccess.withValues(alpha: 0.6))
                          : (canToggle ? Colors.white : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDone
                            ? (canToggle ? CobaltTheme.statusSuccess : CobaltTheme.statusSuccess.withValues(alpha: 0.6))
                            : (canToggle ? CobaltTheme.rule2 : const Color(0xFFCBD5E1)),
                        width: 1.5,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : (!canToggle
                            ? const Icon(Icons.lock_outline, size: 11, color: Color(0xFF94A3B8))
                            : null),
                  ),
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
              if (widget.currentUser.isAdmin)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 17, color: CobaltTheme.purplePrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit Task',
                      onPressed: () => _showEditTaskModal(context, task),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 17, color: Color(0xFFDC2626)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Delete Task',
                      onPressed: () => _confirmDeleteTask(task),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),

          // TaskNexus Due Date & Deadline Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isDone
                  ? CobaltTheme.paper2
                  : task.isOverdue
                      ? const Color(0xFFFEF2F2)
                      : CobaltTheme.paper2,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDone
                    ? CobaltTheme.rule
                    : task.isOverdue
                        ? const Color(0xFFFCA5A5)
                        : CobaltTheme.rule2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone
                      ? Icons.check_circle_outline
                      : task.isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.event_outlined,
                  size: 13,
                  color: isDone
                      ? CobaltTheme.muted
                      : task.isOverdue
                          ? const Color(0xFFDC2626)
                          : CobaltTheme.ink2,
                ),
                const SizedBox(width: 5),
                Text(
                  isDone
                      ? 'Completed (${DateFormat('MMM d').format(task.dueDate)})'
                      : task.isOverdue
                          ? 'Overdue: ${DateFormat('MMM d, h:mm a').format(task.dueDate)}'
                          : 'Due: ${DateFormat('MMM d, h:mm a').format(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDone
                        ? CobaltTheme.muted
                        : task.isOverdue
                            ? const Color(0xFFDC2626)
                            : CobaltTheme.ink2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Assignee & Status Footer
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: task.assignee.isAdmin
                    ? CobaltTheme.purplePrimary
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CobaltTheme.purpleWash,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: CobaltTheme.purpleLight),
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: CobaltTheme.purplePrimary,
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
    ),);
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
    final projectController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.high;
    Employee selectedAssignee = widget.employees.firstWhere(
      (e) => e.id == Employee.khadija.id,
      orElse: () => widget.employees.first,
    );
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 3));
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_task_outlined, size: 20, color: CobaltTheme.accent),
                            SizedBox(width: 8),
                            Text(
                              'Create New Task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: CobaltTheme.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: CobaltTheme.muted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Assign a milestone deliverable exclusively to one team member',
                      style: TextStyle(fontSize: 12, color: CobaltTheme.muted),
                    ),
                    const SizedBox(height: 18),

                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: CobaltTheme.statusError),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalError!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CobaltTheme.statusError,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Clean Generic Task Title
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Clean Generic Project Name
                    TextField(
                      controller: projectController,
                      decoration: InputDecoration(
                        labelText: 'Project Name',
                        hintText: 'Enter project name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Single Assignee Selector
                    const Text(
                      'Assign To (Single Team Member)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.ink2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                    const SizedBox(height: 16),

                    // TaskNexus Due Date & Time Picker
                    const Text(
                      'Deadline & Due Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.ink2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (pickedDate != null) {
                          if (!ctx.mounted) return;
                          final pickedTime = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.fromDateTime(selectedDueDate),
                          );
                          setModalState(() {
                            selectedDueDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime?.hour ?? selectedDueDate.hour,
                              pickedTime?.minute ?? selectedDueDate.minute,
                            );
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          border: Border.all(color: CobaltTheme.rule2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 18, color: CobaltTheme.accent),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEE, MMM d, yyyy • h:mm a').format(selectedDueDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: CobaltTheme.ink,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CobaltTheme.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: CobaltKey(
                        label: 'Assign Task',
                        icon: Icons.assignment_turned_in,
                        variant: CobaltKeyVariant.primary,
                        onPressed: () {
                          final title = titleController.text.trim();
                          final proj = projectController.text.trim().isEmpty
                              ? 'General'
                              : projectController.text.trim();

                          if (title.isEmpty) {
                            setModalState(() {
                              modalError = 'Please enter a task title.';
                            });
                            return;
                          }

                          // Single Assignee & Exclusivity Rule per Project:
                          // A task with the same title cannot be duplicated within the same project!
                          // Different projects CAN have the same task title.
                          final duplicate = widget.tasks.any((t) =>
                              t.projectName.trim().toLowerCase() == proj.toLowerCase() &&
                              t.title.trim().toLowerCase() == title.toLowerCase() &&
                              t.status != TaskStatus.done);

                          if (duplicate) {
                            final existing = widget.tasks.firstWhere((t) =>
                                t.projectName.trim().toLowerCase() == proj.toLowerCase() &&
                                t.title.trim().toLowerCase() == title.toLowerCase() &&
                                t.status != TaskStatus.done);
                            setModalState(() {
                              modalError =
                                  'Task "$title" is already assigned within project "$proj" to ${existing.assignee.name}. Each task can only be assigned to one member per project.';
                            });
                            return;
                          }

                          _addNewTask(
                            title: title,
                            projectName: proj,
                            priority: selectedPriority,
                            assignee: selectedAssignee,
                            dueDate: selectedDueDate,
                          );
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTaskModal(BuildContext context, TaskItem task) {
    final titleController = TextEditingController(text: task.title);
    final projectController = TextEditingController(text: task.projectName);
    TaskPriority selectedPriority = task.priority;
    Employee selectedAssignee = widget.employees.firstWhere(
      (e) => e.id == task.assignee.id,
      orElse: () => widget.employees.first,
    );
    DateTime selectedDueDate = task.dueDate;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 22, color: CobaltTheme.accent),
                            SizedBox(width: 8),
                            Text(
                              'Edit Task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: CobaltTheme.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: CobaltTheme.muted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Update task deliverables, priority, or deadline',
                      style: TextStyle(fontSize: 12, color: CobaltTheme.muted),
                    ),
                    const SizedBox(height: 18),

                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: CobaltTheme.statusError),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalError!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CobaltTheme.statusError,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: projectController,
                      decoration: InputDecoration(
                        labelText: 'Project Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Assign To (Single Team Member)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.ink2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                    const SizedBox(height: 16),

                    const Text(
                      'Deadline & Due Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.ink2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (pickedDate != null) {
                          if (!ctx.mounted) return;
                          final pickedTime = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.fromDateTime(selectedDueDate),
                          );
                          setModalState(() {
                            selectedDueDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime?.hour ?? selectedDueDate.hour,
                              pickedTime?.minute ?? selectedDueDate.minute,
                            );
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          border: Border.all(color: CobaltTheme.rule2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 18, color: CobaltTheme.accent),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEE, MMM d, yyyy • h:mm a').format(selectedDueDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: CobaltTheme.ink,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CobaltTheme.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: CobaltKey(
                        label: 'Save Changes',
                        icon: Icons.check,
                        variant: CobaltKeyVariant.primary,
                        onPressed: () {
                          final title = titleController.text.trim();
                          final proj = projectController.text.trim().isEmpty
                              ? 'General'
                              : projectController.text.trim();

                          if (title.isEmpty) {
                            setModalState(() {
                              modalError = 'Please enter a task title.';
                            });
                            return;
                          }

                          // Duplicate check within same project
                          final duplicate = widget.tasks.any((t) =>
                              t.id != task.id &&
                              t.projectName.trim().toLowerCase() == proj.toLowerCase() &&
                              t.title.trim().toLowerCase() == title.toLowerCase() &&
                              t.status != TaskStatus.done);

                          if (duplicate) {
                            final existing = widget.tasks.firstWhere((t) =>
                                t.id != task.id &&
                                t.projectName.trim().toLowerCase() == proj.toLowerCase() &&
                                t.title.trim().toLowerCase() == title.toLowerCase() &&
                                t.status != TaskStatus.done);
                            setModalState(() {
                              modalError =
                                  'Task "$title" is already assigned within project "$proj" to ${existing.assignee.name}. Each task can only be assigned to one member per project.';
                            });
                            return;
                          }

                          _editTask(
                            id: task.id,
                            title: title,
                            projectName: proj,
                            priority: selectedPriority,
                            assignee: selectedAssignee,
                            dueDate: selectedDueDate,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task updated successfully!'),
                              duration: Duration(seconds: 2),
                              backgroundColor: CobaltTheme.ink,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
