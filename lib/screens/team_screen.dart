import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/employee.dart';
import '../services/supabase_service.dart';
import '../theme/cobalt_theme.dart';
import '../widgets/cobalt_key.dart';

class TeamScreen extends StatefulWidget {
  final List<Employee> employees;
  final Employee currentUser;
  final Function(Employee newEmployee) onAddEmployee;
  final Function(Employee employee)? onDeleteEmployee;

  const TeamScreen({
    super.key,
    required this.employees,
    required this.currentUser,
    required this.onAddEmployee,
    this.onDeleteEmployee,
  });

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late List<Employee> _teamList;

  @override
  void initState() {
    super.initState();
    _teamList = List.from(widget.employees);
  }

  @override
  void didUpdateWidget(covariant TeamScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employees != widget.employees) {
      _teamList = List.from(widget.employees);
    }
  }

  void _confirmDeleteMember(BuildContext context, Employee member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
          side: const BorderSide(color: CobaltTheme.rule2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: CobaltTheme.statusError, size: 22),
            SizedBox(width: 8),
            Text(
              'Remove Member',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CobaltTheme.ink,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${member.name} (${member.role}) from the team roster? This will permanently delete their account.',
          style: const TextStyle(fontSize: 13, color: CobaltTheme.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: CobaltTheme.muted)),
          ),
          CobaltKey(
            label: 'Delete',
            isSmall: true,
            variant: CobaltKeyVariant.outline,
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _teamList.removeWhere((e) => e.id == member.id);
              });
              if (widget.onDeleteEmployee != null) {
                widget.onDeleteEmployee!(member);
              }
              await SupabaseService.instance.deleteEmployee(member.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${member.name} was removed from the team roster.'),
                    backgroundColor: CobaltTheme.ink,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _promptAdminAndAddMember(BuildContext context) {
    if (widget.currentUser.isAdmin) {
      _showAddMemberModal(context);
    } else {
      _showAdminVerificationDialog(context, onAuthorized: () {
        Navigator.pop(context); // Close auth dialog
        _showAddMemberModal(context);
      });
    }
  }

  void _showAdminVerificationDialog(
    BuildContext context, {
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
                  Icon(Icons.lock_outline, size: 20, color: CobaltTheme.accent),
                  SizedBox(width: 8),
                  Text(
                    'Admin Verification',
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
                  const Text(
                    'Only Tech Lead (Saleem) can add new employees. Enter admin credentials to continue:',
                    style: TextStyle(fontSize: 12, color: CobaltTheme.muted, height: 1.4),
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
                  label: 'Verify & Proceed',
                  isSmall: true,
                  variant: CobaltKeyVariant.primary,
                  onPressed: () {
                    final id = adminIdController.text.trim().toLowerCase();
                    final pass = adminPassController.text;
                    if ((id == 'admin' || id == 'saleem') && (pass == 'admin123' || pass == 'saleem123')) {
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

  void _showAddMemberModal(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: 'Welcome@2026');
    bool obscurePassword = false;
    bool makeAdmin = false;

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
                            Icon(Icons.person_add_alt_1, size: 20, color: CobaltTheme.accent),
                            SizedBox(width: 8),
                            Text(
                              'Add New Team Member',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: CobaltTheme.ink,
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
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. Farhan Akhtar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        hintText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Company Email',
                        hintText: 'e.g. farhan@khawajalabs.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Initial Password (Set by Admin)',
                        hintText: 'e.g. Welcome@2026',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 18,
                                color: CobaltTheme.muted,
                              ),
                              tooltip: obscurePassword ? 'Show password' : 'Hide password',
                              onPressed: () => setModalState(() => obscurePassword = !obscurePassword),
                            ),
                            IconButton(
                              icon: const Icon(Icons.auto_fix_high, size: 18, color: CobaltTheme.accent),
                              tooltip: 'Generate secure password',
                              onPressed: () {
                                final rand = (1000 + DateTime.now().millisecond % 9000);
                                passwordController.text = 'Khawaja@$rand';
                                setModalState(() {});
                              },
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          borderSide: const BorderSide(color: CobaltTheme.rule2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Checkbox(
                          value: makeAdmin,
                          activeColor: CobaltTheme.accent,
                          onChanged: (val) {
                            setModalState(() => makeAdmin = val ?? false);
                          },
                        ),
                        const Text(
                          'Grant Tech Lead / Admin Privileges',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CobaltTheme.ink2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: CobaltKey(
                        label: 'Save & Dispatch Welcome Email',
                        icon: Icons.mark_email_read_outlined,
                        variant: CobaltKeyVariant.primary,
                        onPressed: () {
                          final name = nameController.text.trim();
                          final role = roleController.text.trim();
                          final email = emailController.text.trim();
                          final rawPass = passwordController.text.trim().isNotEmpty
                              ? passwordController.text.trim()
                              : 'Welcome@2026';

                          if (name.isNotEmpty && role.isNotEmpty) {
                            // Generate initials
                            final parts = name.split(' ');
                            String initials = parts.isNotEmpty
                                ? parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join()
                                : 'EM';
                            if (initials.isEmpty) initials = 'EM';

                            final newEmp = Employee(
                              id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              role: role,
                              initials: initials,
                              email: email.isNotEmpty ? email : null,
                              password: rawPass,
                              isAdmin: makeAdmin,
                            );

                            setState(() {
                              _teamList.add(newEmp);
                            });
                            widget.onAddEmployee(newEmp);
                            Navigator.pop(ctx);
                            _showWelcomeEmailModal(
                              context,
                              employee: newEmp,
                              initialPassword: rawPass,
                            );
                          }
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

  void _showWelcomeEmailModal(
    BuildContext context, {
    required Employee employee,
    required String initialPassword,
  }) {
    final emailText = '''
Dear ${employee.name},

Welcome to the Khawaja Labs team! You have been registered on the Company Task Manager.

Your Login Credentials:
- Role: ${employee.role}
- Login Email: ${employee.email ?? "Assigned in internal roster"}
- Temporary Password: $initialPassword

Please log in to the Task App using these credentials and keep them confidential.

Best regards,
Saleem (Software Architect & Tech Lead)
Khawaja Labs (khawajaalabs@gmail.com)
'''.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.mark_email_read_outlined, size: 22, color: CobaltTheme.statusSuccess),
                      SizedBox(width: 8),
                      Text(
                        'Welcome Email Dispatched',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: CobaltTheme.ink,
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
                'New team member credentials ready to share.',
                style: TextStyle(fontSize: 12, color: CobaltTheme.muted),
              ),
              const SizedBox(height: 16),

              // Email Envelope Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CobaltTheme.paper2,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                  border: Border.all(color: CobaltTheme.rule),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('To: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CobaltTheme.ink2)),
                        Expanded(
                          child: Text(
                            employee.email ?? 'No email provided',
                            style: const TextStyle(fontSize: 12, color: CobaltTheme.accent, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Text('From: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CobaltTheme.ink2)),
                        Text('khawajaalabs@gmail.com (Khawaja Labs)', style: TextStyle(fontSize: 12, color: CobaltTheme.muted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Subject: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CobaltTheme.ink2)),
                        Expanded(
                          child: Text(
                            'Welcome to Khawaja Labs — ${employee.role}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CobaltTheme.ink),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: CobaltTheme.rule2),
                    Text(
                      'Hi ${employee.name},\n\nWelcome to Khawaja Labs! You have been onboarded to the team roster.\n\n'
                      '• Role: ${employee.role}\n'
                      '• Email: ${employee.email ?? "Registered"}\n'
                      '• Initial Password: $initialPassword\n\n'
                      'You can now sign in to view and track your assigned deliverables.',
                      style: const TextStyle(fontSize: 12, color: CobaltTheme.ink2, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: CobaltKey(
                      label: 'Copy Credentials',
                      icon: Icons.copy,
                      variant: CobaltKeyVariant.outline,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: emailText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding email & password copied to clipboard!'),
                            backgroundColor: CobaltTheme.ink,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CobaltKey(
                      label: 'Done',
                      icon: Icons.check,
                      variant: CobaltKeyVariant.primary,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
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
        title: const Text('Company Team Roster'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: CobaltTheme.rule, height: 1),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead Action Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
                  border: Border.all(color: CobaltTheme.rule2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CobaltTheme.accentWash,
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      ),
                      child: const Icon(
                        Icons.group_add_outlined,
                        color: CobaltTheme.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Directory',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: CobaltTheme.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Manage team members and assign project deliverables',
                            style: TextStyle(fontSize: 11, color: CobaltTheme.muted),
                          ),
                        ],
                      ),
                    ),
                    CobaltKey(
                      label: '+ Add Member',
                      isSmall: true,
                      variant: CobaltKeyVariant.primary,
                      onPressed: () => _promptAdminAndAddMember(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Members (${_teamList.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink2,
                    ),
                  ),
                  if (!widget.currentUser.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CobaltTheme.paper2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CobaltTheme.rule),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, size: 12, color: CobaltTheme.muted),
                          SizedBox(width: 4),
                          Text(
                            'Admin Pin Required to Add',
                            style: TextStyle(fontSize: 10, color: CobaltTheme.muted),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: _teamList.length,
                  itemBuilder: (context, index) {
                    final member = _teamList[index];
                    final isCurrent = member.id == widget.currentUser.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
                        border: Border.all(
                          color: isCurrent ? CobaltTheme.accent : CobaltTheme.rule2,
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: member.isAdmin
                                ? CobaltTheme.accent
                                : CobaltTheme.paper3,
                            child: Text(
                              member.initials,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: member.isAdmin ? Colors.white : CobaltTheme.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: CobaltTheme.ink,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: CobaltTheme.accentWash,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'YOU',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: CobaltTheme.accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  member.role,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: CobaltTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: member.isAdmin
                                  ? CobaltTheme.accentWash
                                  : CobaltTheme.paper2,
                              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                              border: Border.all(
                                color: member.isAdmin
                                    ? CobaltTheme.accentHover.withValues(alpha: 0.2)
                                    : CobaltTheme.rule,
                              ),
                            ),
                            child: Text(
                              member.isAdmin ? '👑 Tech Lead' : '🚀 Team Member',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: member.isAdmin
                                    ? CobaltTheme.accent
                                    : CobaltTheme.ink2,
                              ),
                            ),
                          ),
                          if (widget.currentUser.isAdmin && !member.isAdmin) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: CobaltTheme.statusError),
                              tooltip: 'Delete member',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDeleteMember(context, member),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
