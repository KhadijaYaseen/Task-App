import 'package:flutter/material.dart';
import '../models/employee.dart';
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

  // Admin Form Controllers (clean empty fields, no pre-filled text)
  final _adminIdController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  String? _adminErrorMessage;
  bool _obscurePassword = true;

  // Team Member Selection
  Employee? _selectedMember;

  @override
  void initState() {
    super.initState();
    // Default selected member to Khadija if present
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

  void _handleAdminLogin() {
    final id = _adminIdController.text.trim().toLowerCase();
    final pass = _adminPasswordController.text;

    // Hardcoded dev credentials for Tech Lead / Admin
    final isIdValid = id == 'admin' || id == 'saleem' || id == 'saleem@khawajalabs.com';
    final isPassValid = pass == 'admin123' || pass == 'saleem123';

    if (isIdValid && isPassValid) {
      setState(() => _adminErrorMessage = null);
      // Find or construct admin employee
      final adminUser = widget.employees.firstWhere(
        (e) => e.isAdmin,
        orElse: () => Employee.saleem,
      );
      widget.onLoginSuccess(adminUser);
    } else {
      setState(() {
        _adminErrorMessage = 'Invalid Admin ID or Password. Please try again.';
      });
    }
  }

  void _handleMemberLogin() {
    if (_selectedMember != null) {
      widget.onLoginSuccess(_selectedMember!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CobaltTheme.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Company Identity Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          Text(
                            '▸',
                            style: TextStyle(
                              color: CobaltTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'KHAWAJA LABS INTERNAL',
                            style: TextStyle(
                              color: CobaltTheme.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Company Tasks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: CobaltTheme.ink,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Role-based milestone & project management system',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: CobaltTheme.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Hallmark Cobalt Segmented Switcher (Admin vs Team Member)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CobaltTheme.paper2,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
                      border: Border.all(color: CobaltTheme.rule),
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
                  const SizedBox(height: 20),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
                      border: Border.all(color: CobaltTheme.rule2),
                    ),
                    child: _selectedTab == 0
                        ? _buildAdminLoginForm()
                        : _buildMemberLoginForm(),
                  ),

                  const SizedBox(height: 20),
                  // Help / Footnote
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: CobaltTheme.paper2,
                      borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
                      border: Border.all(color: CobaltTheme.rule),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: CobaltTheme.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedTab == 0
                                ? 'Admin credentials: ID: "admin" • Pass: "admin123"'
                                : 'Select your name to view assigned tasks & update status.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: CobaltTheme.muted,
                              height: 1.3,
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
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedTab = index;
          _adminErrorMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
          border: isSelected
              ? Border.all(color: CobaltTheme.rule2)
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                color: CobaltTheme.accentWash,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 18,
                color: CobaltTheme.accent,
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

        // Admin ID Field
        TextField(
          controller: _adminIdController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Admin Username / ID',
            hintText: 'e.g. admin or saleem',
            prefixIcon: const Icon(Icons.person_outline, size: 18, color: CobaltTheme.muted),
            suffixIcon: _adminIdController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: CobaltTheme.muted),
                    onPressed: () {
                      _adminIdController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.rule2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.rule2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),

        // Admin Password Field
        TextField(
          controller: _adminPasswordController,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Admin Password',
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: CobaltTheme.muted),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_adminPasswordController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: CobaltTheme.muted),
                    onPressed: () {
                      _adminPasswordController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: CobaltTheme.muted,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.rule2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.rule2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
              borderSide: const BorderSide(color: CobaltTheme.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onSubmitted: (_) => _handleAdminLogin(),
        ),
        const SizedBox(height: 20),

        // 3D Cobalt Primary Button
        CobaltKey(
          label: 'Login as Tech Lead (Saleem)',
          icon: Icons.login,
          variant: CobaltKeyVariant.primary,
          onPressed: _handleAdminLogin,
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
                            member.role,
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

        const SizedBox(height: 16),
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
