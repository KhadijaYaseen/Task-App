import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task_item.dart';
import '../models/employee.dart';
import '../models/attendance_record.dart';
import '../theme/cobalt_theme.dart';

class StatsScreen extends StatefulWidget {
  final List<TaskItem> tasks;
  final List<Employee> employees;
  final List<AttendanceRecord>? attendanceRecords;
  final VoidCallback? onBackToTasks;

  const StatsScreen({
    super.key,
    required this.tasks,
    required this.employees,
    this.attendanceRecords,
    this.onBackToTasks,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProgressTasks = tasks.where((t) => t.status != TaskStatus.done).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    final upcomingTasks = tasks.where((t) => !t.isOverdue && t.status != TaskStatus.done).length;

    final completionRate = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.onBackToTasks != null) ...[
            InkWell(
              onTap: widget.onBackToTasks,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CobaltTheme.purpleLight),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 14, color: CobaltTheme.purplePrimary),
                    SizedBox(width: 6),
                    Text(
                      'Back to Tasks Dashboard',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.purplePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          // Header section matching TaskNexus
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CobaltTheme.purpleWash,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusButton),
                  border: Border.all(color: CobaltTheme.purpleLight),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: CobaltTheme.purplePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TASK SUMMARY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: CobaltTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your tasks, at a glance 🚀',
                      style: TextStyle(
                        fontSize: 12,
                        color: CobaltTheme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 4 Metric Highlight Cards in Grid (Modern Pastel Gradients)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Tasks',
                  count: totalTasks,
                  icon: Icons.checklist_rounded,
                  color: CobaltTheme.purplePrimary,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderColor: const Color(0xFFDDD6FE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Completed',
                  count: completedTasks,
                  icon: Icons.check_circle_outline_rounded,
                  color: CobaltTheme.statusSuccess,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderColor: const Color(0xFFBBF7D0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'In Progress',
                  count: inProgressTasks,
                  icon: Icons.hourglass_top_rounded,
                  color: CobaltTheme.statusWarning,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderColor: const Color(0xFFFDE68A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Overdue',
                  count: overdueTasks,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderColor: const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card: Workforce & Attendance Analytics (Peoplo Modern Style)
          _buildWorkforceAttendanceSection(completionRate, completedTasks, inProgressTasks, overdueTasks),
          const SizedBox(height: 18),

          // Card 1: Completion Status (Pie Chart)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
              border: Border.all(color: CobaltTheme.rule2),
              boxShadow: CobaltTheme.softCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Completion Status',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.ink,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CobaltTheme.purpleWash,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CobaltTheme.purpleLight),
                      ),
                      child: Text(
                        '${completionRate.toStringAsFixed(0)}% Done',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CobaltTheme.purplePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                totalTasks == 0
                    ? _buildEmptyChartPlaceholder('No tasks available for status breakdown.')
                    : SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection == null) {
                                          _touchedPieIndex = -1;
                                          return;
                                        }
                                        _touchedPieIndex = pieTouchResponse
                                            .touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    PieChartSectionData(
                                      color: CobaltTheme.statusSuccess,
                                      value: completedTasks.toDouble(),
                                      title: completedTasks > 0
                                          ? '${((completedTasks / totalTasks) * 100).toStringAsFixed(0)}%'
                                          : '',
                                      radius: _touchedPieIndex == 0 ? 55 : 48,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: CobaltTheme.purplePrimary,
                                      value: (totalTasks - completedTasks).toDouble(),
                                      title: (totalTasks - completedTasks) > 0
                                          ? '${(((totalTasks - completedTasks) / totalTasks) * 100).toStringAsFixed(0)}%'
                                          : '',
                                      radius: _touchedPieIndex == 1 ? 55 : 48,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem(
                                    color: CobaltTheme.statusSuccess,
                                    label: 'Completed',
                                    count: completedTasks,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildLegendItem(
                                    color: CobaltTheme.purplePrimary,
                                    label: 'Incomplete',
                                    count: totalTasks - completedTasks,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Card 2: Overdue vs Upcoming Tasks (Bar Chart)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
              border: Border.all(color: CobaltTheme.rule2),
              boxShadow: CobaltTheme.softCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overdue vs Upcoming Tasks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Timeline analysis of incomplete deliverables',
                  style: TextStyle(
                    fontSize: 11,
                    color: CobaltTheme.muted,
                  ),
                ),
                const SizedBox(height: 20),
                inProgressTasks == 0
                    ? _buildEmptyChartPlaceholder('All tasks are completed! No pending items.')
                    : SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (overdueTasks > upcomingTasks ? overdueTasks : upcomingTasks)
                                    .toDouble() +
                                2.0,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => CobaltTheme.ink,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final label = group.x == 0 ? 'Overdue' : 'Upcoming';
                                  return BarTooltipItem(
                                    '$label\n${rod.toY.toInt()} tasks',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final text = value.toInt() == 0 ? 'Overdue' : 'Upcoming';
                                    final color = value.toInt() == 0
                                        ? const Color(0xFFDC2626)
                                        : CobaltTheme.purplePrimary;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 != 0) return const SizedBox.shrink();
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: CobaltTheme.muted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: CobaltTheme.paper3,
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: overdueTasks.toDouble(),
                                    color: const Color(0xFFEF4444),
                                    width: 32,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: ((overdueTasks > upcomingTasks ? overdueTasks : upcomingTasks) + 2).toDouble(),
                                      color: const Color(0xFFFEF2F2),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: upcomingTasks.toDouble(),
                                    color: CobaltTheme.purplePrimary,
                                    width: 32,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: ((overdueTasks > upcomingTasks ? overdueTasks : upcomingTasks) + 2).toDouble(),
                                      color: CobaltTheme.purpleWash,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Card 3: Team Workload Breakdown
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
              border: Border.all(color: CobaltTheme.rule2),
              boxShadow: CobaltTheme.softCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workload by Team Member',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active assignments per registered engineer',
                  style: TextStyle(
                    fontSize: 11,
                    color: CobaltTheme.muted,
                  ),
                ),
                const SizedBox(height: 14),
                ...widget.employees.map((emp) {
                  final empTasks = tasks.where((t) => t.assignee.id == emp.id).toList();
                  final empTotal = empTasks.length;
                  final empDone = empTasks.where((t) => t.status == TaskStatus.done).length;
                  final progress = empTotal == 0 ? 0.0 : empDone / empTotal;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: emp.isAdmin ? CobaltTheme.purplePrimary : CobaltTheme.paper3,
                              child: Text(
                                emp.initials,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: emp.isAdmin ? Colors.white : CobaltTheme.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              emp.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: CobaltTheme.ink,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$empDone / $empTotal done',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: CobaltTheme.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: CobaltTheme.paper3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress == 1.0 ? CobaltTheme.statusSuccess : CobaltTheme.purplePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CobaltTheme.ink2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CobaltTheme.ink,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: CobaltTheme.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChartPlaceholder(String message) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: CobaltTheme.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWorkforceAttendanceSection(
    double completionRate,
    int completedTasks,
    int inProgressTasks,
    int overdueTasks,
  ) {
    final records = widget.attendanceRecords ?? AttendanceRecord.getSampleRecords(widget.employees);
    final totalShifts = records.length;
    final presentShifts = records.where((r) => r.status == AttendanceStatus.present).length;
    final leaveShifts = records.where((r) => r.status == AttendanceStatus.leave).length;
    final totalHours = records.fold<double>(0.0, (sum, r) => sum + r.hours);
    final attendanceRate = totalShifts > 0 ? (presentShifts / totalShifts) * 100 : 94.6;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCardLarge),
        border: Border.all(color: CobaltTheme.rule2),
        boxShadow: CobaltTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CobaltTheme.purpleWash,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.donut_large_rounded,
                        color: CobaltTheme.purplePrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workforce & Attendance',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: CobaltTheme.ink,
                            ),
                          ),
                          Text(
                            'Dual-ring attendance & task analytics',
                            style: TextStyle(
                              fontSize: 11,
                              color: CobaltTheme.muted,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CobaltTheme.purpleWash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CobaltTheme.purpleLight),
                ),
                child: const Text(
                  'Live · 95%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.purplePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Two Circular Donut Rings Side-by-Side
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 550;
              final ring1 = _buildDonutRingCard(
                title: 'Attendance Today',
                badgeText: '94.6% vs 95%',
                percentage: attendanceRate,
                centerPrimaryText: '${attendanceRate.toStringAsFixed(1)}%',
                centerSecondaryText: 'present',
                progressColor: CobaltTheme.purplePrimary,
                trackColor: CobaltTheme.purpleLight,
                legends: [
                  _DonutLegendItem(color: CobaltTheme.purplePrimary, label: 'In office / Active', value: '${attendanceRate.toStringAsFixed(0)}%'),
                  _DonutLegendItem(color: const Color(0xFF06B6D4), label: 'Remote / Flexible', value: '${(100 - attendanceRate).toStringAsFixed(0)}%'),
                  _DonutLegendItem(color: const Color(0xFFF59E0B), label: 'On leave', value: '$leaveShifts days'),
                ],
              );

              final ring2 = _buildDonutRingCard(
                title: 'Task Completion',
                badgeText: '$completedTasks / ${completedTasks + inProgressTasks}',
                percentage: completionRate,
                centerPrimaryText: '${completionRate.toStringAsFixed(0)}%',
                centerSecondaryText: 'done',
                progressColor: CobaltTheme.statusSuccess,
                trackColor: const Color(0xFFDCFCE7),
                legends: [
                  _DonutLegendItem(color: CobaltTheme.statusSuccess, label: 'Finished Tasks', value: '$completedTasks'),
                  _DonutLegendItem(color: CobaltTheme.statusWarning, label: 'In progress', value: '$inProgressTasks'),
                  _DonutLegendItem(color: const Color(0xFFEF4444), label: 'Overdue', value: '$overdueTasks'),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ring1),
                    const SizedBox(width: 14),
                    Expanded(child: ring2),
                  ],
                );
              } else {
                return Column(
                  children: [
                    ring1,
                    const SizedBox(height: 14),
                    ring2,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // 3 KPI Metric Pills
          Row(
            children: [
              Expanded(
                child: _buildAttendanceKpiPill(
                  label: 'Attendance Rate',
                  value: '${attendanceRate.toStringAsFixed(1)}%',
                  subtext: '+1.8% vs last month',
                  subtextColor: CobaltTheme.statusSuccess,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceKpiPill(
                  label: 'Logged Hours',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  subtext: '$totalShifts tracked shifts',
                  subtextColor: CobaltTheme.muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceKpiPill(
                  label: 'Active Personnel',
                  value: '${widget.employees.length}',
                  subtext: '$leaveShifts on leave',
                  subtextColor: CobaltTheme.purplePrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonutRingCard({
    required String title,
    required String badgeText,
    required double percentage,
    required String centerPrimaryText,
    required String centerSecondaryText,
    required Color progressColor,
    required Color trackColor,
    required List<_DonutLegendItem> legends,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CobaltTheme.paper,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: CobaltTheme.rule2.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CobaltTheme.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: CobaltTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Circular Donut Ring
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: (percentage.clamp(0.0, 100.0)) / 100.0,
                        strokeWidth: 10,
                        backgroundColor: trackColor,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerPrimaryText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: CobaltTheme.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          centerSecondaryText,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: CobaltTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Breakdown Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legends.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: CobaltTheme.ink2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CobaltTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceKpiPill({
    required String label,
    required String value,
    required String subtext,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CobaltTheme.paper2,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: CobaltTheme.rule2.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CobaltTheme.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: CobaltTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DonutLegendItem {
  final Color color;
  final String label;
  final String value;

  const _DonutLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
}
