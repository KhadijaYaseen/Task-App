import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/employee.dart';
import '../theme/cobalt_theme.dart';

class AttendanceScreen extends StatefulWidget {
  final Employee currentUser;
  final List<Employee> employees;
  final List<AttendanceRecord> attendanceRecords;
  final Function(AttendanceRecord newRecord) onAddAttendance;

  const AttendanceScreen({
    super.key,
    required this.currentUser,
    required this.employees,
    required this.attendanceRecords,
    required this.onAddAttendance,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _selectedMonth;
  Employee? _adminSelectedEmployee;
  bool _isClockedIn = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(2026, 11, 1);
    if (widget.currentUser.isAdmin) {
      _adminSelectedEmployee = null; // null = View All, or select specific
    } else {
      _adminSelectedEmployee = widget.currentUser;
    }
  }

  // Filter records by role privacy rule
  List<AttendanceRecord> get _visibleRecords {
    if (widget.currentUser.isAdmin) {
      if (_adminSelectedEmployee == null) {
        return widget.attendanceRecords;
      }
      return widget.attendanceRecords
          .where((r) => r.employeeId == _adminSelectedEmployee!.id)
          .toList();
    } else {
      // STRICT PRIVACY: Non-admin only sees THEIR OWN records!
      return widget.attendanceRecords
          .where((r) => r.employeeId == widget.currentUser.id)
          .toList();
    }
  }

  void _toggleClockIn() {
    setState(() {
      _isClockedIn = !_isClockedIn;
    });

    final now = DateTime.now();
    final timeStr = "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    if (_isClockedIn) {
      final newRecord = AttendanceRecord(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: widget.currentUser.id,
        employeeName: widget.currentUser.name,
        date: DateTime(now.year, now.month, now.day),
        checkInTime: timeStr,
        checkOutTime: null,
        hours: 0.0,
        status: AttendanceStatus.present,
        notes: 'Shift Clocked In',
      );
      widget.onAddAttendance(newRecord);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clocked in successfully at $timeStr!'),
          backgroundColor: CobaltTheme.statusSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clocked out successfully at $timeStr. Great job today!'),
          backgroundColor: CobaltTheme.purplePrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CobaltTheme.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy Badge or Admin Employee Selector
              _buildPrivacyHeader(),
              const SizedBox(height: 16),

              // Hero Clock In / Clock Out Card (Image 2 style)
              _buildHeroClockCard(),
              const SizedBox(height: 18),

              // Monthly Attendance Calendar View (Image 1 style)
              _buildCalendarView(),
              const SizedBox(height: 20),

              // Attendance History Ledger List
              _buildAttendanceLedgerHeader(),
              const SizedBox(height: 12),
              _buildAttendanceLogList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyHeader() {
    if (widget.currentUser.isAdmin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
          border: Border.all(color: CobaltTheme.rule),
          boxShadow: CobaltTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CobaltTheme.purpleWash,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_rounded, size: 16, color: CobaltTheme.purplePrimary),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tech Lead Attendance Controls',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Roster'),
                    selected: _adminSelectedEmployee == null,
                    selectedColor: CobaltTheme.purpleLight,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _adminSelectedEmployee == null ? CobaltTheme.purpleDark : CobaltTheme.muted,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _adminSelectedEmployee = null;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  ...widget.employees.map((emp) {
                    final isSel = _adminSelectedEmployee?.id == emp.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        avatar: CircleAvatar(
                          radius: 10,
                          backgroundColor: CobaltTheme.purplePrimary,
                          child: Text(
                            emp.initials,
                            style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        label: Text(emp.name),
                        selected: isSel,
                        selectedColor: CobaltTheme.purpleLight,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel ? CobaltTheme.purpleDark : CobaltTheme.ink2,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _adminSelectedEmployee = selected ? emp : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Regular Team Member Privacy Notice
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CobaltTheme.purpleWash,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
        border: Border.all(color: CobaltTheme.purpleLight),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: CobaltTheme.purplePrimary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Confidential: Attendance is strictly private between you & Tech Lead (Saleem).',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CobaltTheme.purpleDark,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroClockCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
        border: Border.all(color: CobaltTheme.rule),
        boxShadow: CobaltTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: CobaltTheme.purplePrimary,
                    child: Text(
                      widget.currentUser.initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good evening, ${widget.currentUser.name} 👋',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: CobaltTheme.ink),
                      ),
                      Text(
                        widget.currentUser.role,
                        style: const TextStyle(fontSize: 11, color: CobaltTheme.muted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isClockedIn ? const Color(0xFFDCFCE7) : CobaltTheme.purpleWash,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isClockedIn ? CobaltTheme.statusSuccess : CobaltTheme.purplePrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isClockedIn ? 'CLOCKED IN' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _isClockedIn ? CobaltTheme.statusSuccess : CobaltTheme.purplePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Digital Timer & Punch Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: CobaltTheme.primaryGradient,
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
              boxShadow: CobaltTheme.purpleGlowShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOURS LOGGED TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE0E7FF),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '04:15:30',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Standard Shift: 8:00 PM – 12:00 AM',
                      style: TextStyle(fontSize: 11, color: Color(0xFFC7D2FE)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _toggleClockIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _isClockedIn ? CobaltTheme.statusError : CobaltTheme.purplePrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(_isClockedIn ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded, size: 18),
                  label: Text(
                    _isClockedIn ? 'Clock Out' : 'Clock In',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Metric Pills
          Row(
            children: [
              _buildMetricPill('CLOCK IN', '07:45 PM', Icons.login_rounded, const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildMetricPill('SHIFT TARGET', '4h 00m', Icons.timer_outlined, CobaltTheme.purplePrimary),
              const SizedBox(width: 8),
              _buildMetricPill('OVERTIME', '+0:15m', Icons.bolt_rounded, const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: CobaltTheme.paper2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CobaltTheme.rule),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: CobaltTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: CobaltTheme.ink),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstDayOffset = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
        border: Border.all(color: CobaltTheme.rule),
        boxShadow: CobaltTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Switcher Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: CobaltTheme.ink),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                },
              ),
              Text(
                'November 2026',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CobaltTheme.ink,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: CobaltTheme.ink),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Day of week labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Sun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
              Text('Mon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
              Text('Tue', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
              Text('Wed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
              Text('Thu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
              Text('Fri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
              Text('Sat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CobaltTheme.muted)),
            ],
          ),
          const SizedBox(height: 10),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDayOffset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (ctx, index) {
              if (index < firstDayOffset) {
                return const SizedBox.shrink();
              }
              final day = index - firstDayOffset + 1;
              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

              // Check if there's a record for this date
              final match = _visibleRecords.where((r) =>
                  r.date.year == date.year &&
                  r.date.month == date.month &&
                  r.date.day == date.day).toList();

              Color bgColor = Colors.transparent;
              Color textColor = CobaltTheme.ink;
              Border? border = Border.all(color: CobaltTheme.rule2.withValues(alpha: 0.5));
              String? label;

              if (match.isNotEmpty) {
                final rec = match.first;
                if (rec.status == AttendanceStatus.leave) {
                  bgColor = const Color(0xFFFEF3C7);
                  textColor = const Color(0xFFB45309);
                  border = Border.all(color: const Color(0xFFFCD34D));
                  label = 'L';
                } else if (rec.status == AttendanceStatus.present) {
                  bgColor = const Color(0xFFDCFCE7);
                  textColor = const Color(0xFF15803D);
                  border = Border.all(color: const Color(0xFF86EFAC));
                  label = 'P';
                }
              }

              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              if (isSelected) {
                bgColor = CobaltTheme.purplePrimary;
                textColor = Colors.white;
                border = Border.all(color: CobaltTheme.purpleDark);
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: border,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      if (label != null && !isSelected)
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFFDCFCE7), const Color(0xFF15803D), 'Present'),
              const SizedBox(width: 14),
              _buildLegend(const Color(0xFFFEF3C7), const Color(0xFFB45309), 'Leave'),
              const SizedBox(width: 14),
              _buildLegend(CobaltTheme.paper2, CobaltTheme.muted, 'Weekend / Off'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color bg, Color text, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: text.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: CobaltTheme.muted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAttendanceLedgerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance Records (${_visibleRecords.length})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: CobaltTheme.ink,
          ),
        ),
        if (widget.currentUser.isAdmin)
          const Text(
            'Audited by Lead',
            style: TextStyle(fontSize: 11, color: CobaltTheme.purplePrimary, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }

  Widget _buildAttendanceLogList() {
    if (_visibleRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text('No attendance records found.', style: TextStyle(color: CobaltTheme.muted)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _visibleRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final rec = _visibleRecords[index];
        final isLeave = rec.status == AttendanceStatus.leave;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
            border: Border.all(color: isLeave ? const Color(0xFFFDE68A) : CobaltTheme.rule),
            boxShadow: CobaltTheme.softCardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLeave ? const Color(0xFFFEF3C7) : CobaltTheme.purpleWash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${rec.date.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isLeave ? const Color(0xFFB45309) : CobaltTheme.purpleDark,
                      ),
                    ),
                    Text(
                      _getMonthName(rec.date.month),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isLeave ? const Color(0xFFB45309) : CobaltTheme.purplePrimary,
                      ),
                    ),
                  ],
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
                          rec.employeeName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: CobaltTheme.ink),
                        ),
                        if (widget.currentUser.isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CobaltTheme.paper2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              rec.employeeId,
                              style: const TextStyle(fontSize: 9, color: CobaltTheme.muted, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isLeave
                          ? (rec.notes ?? 'Leave Approved')
                          : '${rec.checkInTime} → ${rec.checkOutTime ?? "In Progress"} (${rec.hours} hrs)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLeave ? const Color(0xFFB45309) : CobaltTheme.muted,
                        fontWeight: isLeave ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLeave ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLeave ? 'LEAVE' : 'PRESENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isLeave ? const Color(0xFFB45309) : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
