import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task_item.dart';
import '../models/employee.dart';
import '../theme/cobalt_theme.dart';

class StatsScreen extends StatefulWidget {
  final List<TaskItem> tasks;
  final List<Employee> employees;
  final VoidCallback? onBackToTasks;

  const StatsScreen({
    super.key,
    required this.tasks,
    required this.employees,
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
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CobaltTheme.rule2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 14, color: CobaltTheme.accent),
                    SizedBox(width: 6),
                    Text(
                      'Back to Tasks Dashboard',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CobaltTheme.accent,
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
                  color: CobaltTheme.accentWash,
                  borderRadius: BorderRadius.circular(CobaltTheme.radiusButton),
                  border: Border.all(color: CobaltTheme.accentLight),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: CobaltTheme.accent,
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

          // 4 Metric Highlight Cards in Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Tasks',
                  count: totalTasks,
                  icon: Icons.checklist_rounded,
                  color: CobaltTheme.accent,
                  bgColor: CobaltTheme.paper2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Completed',
                  count: completedTasks,
                  icon: Icons.check_circle_outline_rounded,
                  color: CobaltTheme.statusSuccess,
                  bgColor: const Color(0xFFF0FDF4),
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
                  bgColor: const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Overdue',
                  count: overdueTasks,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card 1: Completion Status (Pie Chart)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
              border: Border.all(color: CobaltTheme.rule2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CobaltTheme.accentWash,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${completionRate.toStringAsFixed(0)}% Done',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CobaltTheme.accent,
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
                                      color: const Color(0xFFEF4444),
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
                                    color: const Color(0xFFEF4444),
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
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
              border: Border.all(color: CobaltTheme.rule2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
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
                                        : CobaltTheme.accent;
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
                                    color: CobaltTheme.accent,
                                    width: 32,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: ((overdueTasks > upcomingTasks ? overdueTasks : upcomingTasks) + 2).toDouble(),
                                      color: CobaltTheme.accentWash,
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
              borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
              border: Border.all(color: CobaltTheme.rule2),
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
                              backgroundColor: emp.isAdmin ? CobaltTheme.accent : CobaltTheme.paper3,
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
                              progress == 1.0 ? CobaltTheme.statusSuccess : CobaltTheme.accent,
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
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CobaltTheme.radiusCard),
        border: Border.all(color: CobaltTheme.rule2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: CobaltTheme.ink,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CobaltTheme.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
}
