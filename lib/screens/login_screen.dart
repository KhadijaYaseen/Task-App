import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/supabase_service.dart';
import '../theme/cobalt_theme.dart';
import '../widgets/cobalt_key.dart';

class LoginScreen extends StatefulWidget {
  final List<Employee> employees;
  final Function(Employee user) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.employees,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0; // 0: Admin / Lead, 1: Team Member

  // Form Controllers
  final _adminIdController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  String? _adminErrorMessage;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Team Member Selection
  Employee? _selectedMember;

  @override
  void initState() {
    super.initState();
    _selectedMember = widget.employees.firstWhere(
      (e) => !e.isAdmin,
      orElse: () => widget.employees.first,
    );
  }

  @override
  void dispose() {
    _adminIdController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    final id = _adminIdController.text.trim();
    final pass = _adminPasswordController.text;

    if (id.isEmpty || pass.isEmpty) {
      setState(() {
        _adminErrorMessage = 'Invalid Admin ID or Password. Please try again.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final user = await SupabaseService.instance.login(id, pass);

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        setState(() => _adminErrorMessage = null);
        widget.onLoginSuccess(user);
      } else {
        setState(() {
          _adminErrorMessage = 'Invalid Admin ID or Password. Please try again.';
        });
      }
    }
  }

  void _handleMemberLogin() {
    if (_selectedMember != null) {
      widget.onLoginSuccess(_selectedMember!);
    }
  }

  void _showResetPasswordDialog(BuildContext context, {String initialEmail = ''}) {
    final emailController = TextEditingController(text: initialEmail);
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    String? modalError;
    bool isResetting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_reset, size: 20, color: CobaltTheme.accent),
                            SizedBox(width: 8),
                            Text(
                              'Reset Password',
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
                      'Enter your registered email and choose a new password.',
                      style: TextStyle(fontSize: 12, color: CobaltTheme.muted),
                    ),
                    const SizedBox(height: 16),
                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Text(
                          modalError!,
                          style: const TextStyle(fontSize: 12, color: CobaltTheme.statusError, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Registered Email',
                        hintText: 'e.g. saleemali001232@gmail.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        hintText: 'Re-enter new password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CobaltKey(
                      label: isResetting ? 'Updating...' : 'Update Password',
                      icon: Icons.check,
                      variant: CobaltKeyVariant.primary,
                      onPressed: () async {
                        if (isResetting) return;
                        final email = emailController.text.trim();
                        final pass = newPassController.text;
                        final confirm = confirmPassController.text;

                        if (email.isEmpty || !email.contains('@')) {
                          setModalState(() => modalError = 'Please enter a valid email address.');
                          return;
                        }
                        if (pass.length < 6) {
                          setModalState(() => modalError = 'Password must be at least 6 characters.');
                          return;
                        }
                        if (pass != confirm) {
                          setModalState(() => modalError = 'Passwords do not match.');
                          return;
                        }

                        setModalState(() {
                          isResetting = true;
                          modalError = null;
                        });

                        final ok = await SupabaseService.instance.resetPassword(
                          email: email,
                          newPassword: pass,
                        );

                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Password updated successfully! You can now log in.'
                                : 'Could not reset password. Please check your email.'),
                            backgroundColor: ok ? CobaltTheme.statusSuccess : CobaltTheme.statusError,
                          ),
                        );
                      },
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

  void _showSignUpDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final passController = TextEditingController();
    String? modalError;
    bool isRegistering = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_add_outlined, size: 20, color: CobaltTheme.accent),
                            SizedBox(width: 8),
                            Text(
                              'Register New Member',
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
                      'Create a real team member profile connected to Supabase.',
                      style: TextStyle(fontSize: 12, color: CobaltTheme.muted),
                    ),
                    const SizedBox(height: 16),
                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Text(
                          modalError!,
                          style: const TextStyle(fontSize: 12, color: CobaltTheme.statusError, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. Ayesha Noor',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'e.g. ayesha@khawajalabs.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        hintText: 'Role',
                        prefixIcon: const Icon(Icons.work_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create a password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CobaltKey(
                      label: isRegistering ? 'Registering...' : 'Create Account',
                      icon: Icons.person_add,
                      variant: CobaltKeyVariant.primary,
                      onPressed: () async {
                        if (isRegistering) return;
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final role = roleController.text.trim();
                        final pass = passController.text;

                        if (name.isEmpty) {
                          setModalState(() => modalError = 'Please enter full name.');
                          return;
                        }
                        if (email.isEmpty || !email.contains('@')) {
                          setModalState(() => modalError = 'Please enter a valid email.');
                          return;
                        }
                        if (pass.length < 6) {
                          setModalState(() => modalError = 'Password must be at least 6 characters.');
                          return;
                        }

                        setModalState(() {
                          isRegistering = true;
                          modalError = null;
                        });

                        final newEmp = await SupabaseService.instance.signUp(
                          name: name,
                          email: email,
                          role: role,
                          password: pass,
                        );

                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (newEmp != null) {
                          widget.onLoginSuccess(newEmp);
                        }
                      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CobaltTheme.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Company Identity Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CobaltTheme.accentWash,
                        borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                        border: Border.all(
                          color: CobaltTheme.accentHover.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 14, color: CobaltTheme.accent),
                          SizedBox(width: 4),
                          Text(
                            'KHAWAJA LABS INTERNAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: CobaltTheme.accent,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Company Tasks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: CobaltTheme.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Role-based milestone & project management system',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: CobaltTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Role Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CobaltTheme.paper2,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      border: Border.all(color: CobaltTheme.rule2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRoleTab(
                            title: '👑 Admin / Lead',
                            index: 0,
                          ),
                        ),
                        Expanded(
                          child: _buildRoleTab(
                            title: '🚀 Team Member',
                            index: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login Card Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
                      border: Border.all(color: CobaltTheme.rule2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _selectedTab == 0
                        ? _buildAdminLoginForm()
                        : _buildMemberLoginForm(),
                  ),
                  const SizedBox(height: 18),

                  // Footer info note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CobaltTheme.paper2,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      border: Border.all(color: CobaltTheme.rule),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: CobaltTheme.muted),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connected to Supabase PostgreSQL cloud authentication.',
                            style: TextStyle(
                              fontSize: 11,
                              color: CobaltTheme.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({required String title, required int index}) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _adminErrorMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput - 2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? CobaltTheme.ink : CobaltTheme.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CobaltTheme.paper2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 18,
                color: CobaltTheme.ink2,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tech Lead Access',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink,
                    ),
                  ),
                  Text(
                    'Full rights to add employees & assign tasks',
                    style: TextStyle(
                      fontSize: 11,
                      color: CobaltTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (_adminErrorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                    _adminErrorMessage!,
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

        // Username / Email
        TextField(
          controller: _adminIdController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'saleemali001232@gmail.com or admin',
            prefixIcon: const Icon(Icons.person_outline, size: 18, color: CobaltTheme.muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.rule2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),

        // Password
        TextField(
          controller: _adminPasswordController,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: CobaltTheme.muted),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: CobaltTheme.muted,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.rule2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onSubmitted: (_) => _handleAdminLogin(),
        ),

        // Forgot password row
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showResetPasswordDialog(
              context,
              initialEmail: _adminIdController.text.trim().contains('@')
                  ? _adminIdController.text.trim()
                  : 'saleemali001232@gmail.com',
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(fontSize: 12, color: CobaltTheme.accent, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Quick Autofill Chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ActionChip(
              avatar: const Icon(Icons.security, size: 13, color: CobaltTheme.accent),
              label: const Text('Saleem (Lead)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              backgroundColor: CobaltTheme.paper2,
              onPressed: () {
                _adminIdController.text = 'saleemali001232@gmail.com';
                _adminPasswordController.text = 'password123';
                setState(() {});
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.person, size: 13, color: CobaltTheme.ink),
              label: const Text('Khadija (Intern)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              backgroundColor: CobaltTheme.paper2,
              onPressed: () {
                _adminIdController.text = 'khadijayaseen36@gmail.com';
                _adminPasswordController.text = 'password123';
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Login as Tech Lead Button
        CobaltKey(
          label: _isLoading ? 'Authenticating...' : 'Login as Tech Lead',
          icon: Icons.login,
          variant: CobaltKeyVariant.primary,
          onPressed: () {
            if (!_isLoading) {
              _handleAdminLogin();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMemberLoginForm() {
    final regularMembers = widget.employees.where((e) => !e.isAdmin).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CobaltTheme.paper2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.badge_outlined,
                size: 18,
                color: CobaltTheme.ink2,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Member Sign-in',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CobaltTheme.ink,
                    ),
                  ),
                  Text(
                    'Access your assigned tasks & update milestones',
                    style: TextStyle(
                      fontSize: 11,
                      color: CobaltTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        const Text(
          'Select Your Profile',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: CobaltTheme.ink2,
          ),
        ),
        const SizedBox(height: 8),

        // Member Selection Cards
        ...regularMembers.map((member) {
          final isSelected = _selectedMember?.id == member.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedMember = member),
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? CobaltTheme.accentWash : Colors.white,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                  border: Border.all(
                    color: isSelected ? CobaltTheme.accent : CobaltTheme.rule2,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isSelected ? CobaltTheme.accent : CobaltTheme.paper3,
                      child: Text(
                        member.initials,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : CobaltTheme.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CobaltTheme.ink,
                            ),
                          ),
                          Text(
                            member.email ?? member.role,
                            style: const TextStyle(
                              fontSize: 11,
                              color: CobaltTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: CobaltTheme.accent,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        // Register New Member Button & Forgot Password row
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.person_add, size: 14, color: CobaltTheme.accent),
                  label: const Text('New Member?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _showSignUpDialog(context),
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showResetPasswordDialog(
                context,
                initialEmail: _selectedMember?.email ?? 'khadijayaseen36@gmail.com',
              ),
              child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: CobaltTheme.muted)),
            ),
          ],
        ),

        const SizedBox(height: 10),
        CobaltKey(
          label: 'Continue as ${_selectedMember?.name ?? "Member"}',
          icon: Icons.arrow_forward,
          variant: CobaltKeyVariant.primary,
          onPressed: _handleMemberLogin,
        ),
      ],
    );
  }
}
