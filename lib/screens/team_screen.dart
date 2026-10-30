import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../theme/cobalt_theme.dart';
import '../widgets/cobalt_key.dart';

class TeamScreen extends StatefulWidget {
  final List<Employee> employees;
  final Employee currentUser;
  final Function(Employee newEmployee) onAddEmployee;

  const TeamScreen({
    super.key,
    required this.employees,
    required this.currentUser,
    required this.onAddEmployee,
  });

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
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
                      labelText: 'Designation / Role',
                      hintText: 'e.g. Flutter Developer or QA Engineer',
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
                      labelText: 'Company Email (Optional)',
                      hintText: 'e.g. farhan@khawajalabs.com',
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
                      label: 'Save & Register Employee',
                      icon: Icons.check,
                      variant: CobaltKeyVariant.primary,
                      onPressed: () {
                        final name = nameController.text.trim();
                        final role = roleController.text.trim();
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
                            email: emailController.text.trim().isNotEmpty
                                ? emailController.text.trim()
                                : null,
                            isAdmin: makeAdmin,
                          );

                          widget.onAddEmployee(newEmp);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Employee $name successfully added to roster!'),
                              backgroundColor: CobaltTheme.statusSuccess,
                            ),
                          );
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
                    'Active Members (${widget.employees.length})',
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
                  itemCount: widget.employees.length,
                  itemBuilder: (context, index) {
                    final member = widget.employees[index];
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
