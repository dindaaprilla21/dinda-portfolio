import 'package:reminder_ai/models/task_model.dart';
import 'package:reminder_ai/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_ai/utils/app_responsive.dart';


class StatisticsScreen extends StatefulWidget {
  final List<Task> tasks;

  const StatisticsScreen({
    super.key,
    required this.tasks,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final stats = _calculateStatistics();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: TextStyle(fontSize: AppResponsive.fontXl),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: AppResponsive.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(stats),
                SizedBox(height: AppResponsive.gapHuge),
                _buildProductivityChart(stats),
                SizedBox(height: AppResponsive.gapHuge),
                _buildCategoryBreakdown(stats),
                SizedBox(height: AppResponsive.gapHuge),
                _buildWeeklyProgress(stats),
                SizedBox(height: AppResponsive.gapHuge),
                _buildInsights(stats),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStatistics() {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);
    
    final totalTasks = widget.tasks.length;
    final completedTasks = widget.tasks.where((t) => t.status == 'completed').length;
    final pendingTasks = widget.tasks.where((t) => t.status == 'pending').length;
    final overdueTasks = widget.tasks.where((t) => 
        t.deadline.isBefore(now) && t.status == 'pending').length;
    
    final thisWeekCompleted = widget.tasks.where((t) => 
        t.completedAt != null && 
        t.completedAt!.isAfter(thisWeekStart)).length;
    
    final thisMonthCompleted = widget.tasks.where((t) => 
        t.completedAt != null && 
        t.completedAt!.isAfter(thisMonthStart)).length;
    
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
    
    // Category breakdown
    final categoryStats = <String, int>{};
    for (var task in widget.tasks) {
      categoryStats[task.category] = (categoryStats[task.category] ?? 0) + 1;
    }
    
    // Priority breakdown
    final priorityStats = <int, int>{};
    for (var task in widget.tasks.where((t) => t.status == 'pending')) {
      priorityStats[task.priority] = (priorityStats[task.priority] ?? 0) + 1;
    }
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'thisWeekCompleted': thisWeekCompleted,
      'thisMonthCompleted': thisMonthCompleted,
      'completionRate': completionRate,
      'categoryStats': categoryStats,
      'priorityStats': priorityStats,
    };
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: AppResponsive.font2xl,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppResponsive.gapXl),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppResponsive.h(12),
          crossAxisSpacing: AppResponsive.w(12),
          childAspectRatio: AppResponsive.statCardAspectRatio,
          children: [
            _buildStatCard(
              'Total Tasks',
              stats['totalTasks'].toString(),
              Icons.assignment,
              AppTheme.primaryColor,
              'All time',
            ),
            _buildStatCard(
              'Completed',
              stats['completedTasks'].toString(),
              Icons.check_circle,
              AppTheme.successColor,
              '${stats['completionRate'].toStringAsFixed(1)}% rate',
            ),
            _buildStatCard(
              'Pending',
              stats['pendingTasks'].toString(),
              Icons.pending,
              AppTheme.warningColor,
              'In progress',
            ),
            _buildStatCard(
              'Overdue',
              stats['overdueTasks'].toString(),
              Icons.warning,
              AppTheme.errorColor,
              'Need attention',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: AppResponsive.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppResponsive.w(9)),
            decoration: BoxDecoration(
              color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            ),
            child: Icon(icon, color: color, size: AppResponsive.iconMd),
          ),
          SizedBox(height: AppResponsive.gapMd),
          Text(
            value,
            style: TextStyle(
              fontSize: AppResponsive.font4xl,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          Text(
            title,
            style: TextStyle(
              fontSize: AppResponsive.fontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppResponsive.fontXs,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityChart(Map<String, dynamic> stats) {
    return Container(
      padding: AppResponsive.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productivity Metrics',
            style: TextStyle(
              fontSize: AppResponsive.fontXl,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppResponsive.gapXxl),
          
          // Completion Rate Progress Bar
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Completion Rate',
                  style: TextStyle(fontSize: AppResponsive.fontBase),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stats['completionRate'].toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: AppResponsive.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(4)),
                    LinearProgressIndicator(
                      value: stats['completionRate'] / 100,
                      backgroundColor: Color.fromRGBO(128, 128, 128, 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppResponsive.gapXxl),
          
          // Weekly & Monthly Stats
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'This Week',
                  stats['thisWeekCompleted'].toString(),
                  'completed',
                  AppTheme.successColor,
                ),
              ),
              SizedBox(width: AppResponsive.w(16)),
              Expanded(
                child: _buildMetricItem(
                  'This Month',
                  stats['thisMonthCompleted'].toString(),
                  'completed',
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String period, String value, String label, Color color) {
    return Container(
      padding: AppResponsive.all(10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppResponsive.font2xl,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '$label $period',
            style: TextStyle(
              fontSize: AppResponsive.fontSm,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(Map<String, dynamic> stats) {
    final categoryStats = stats['categoryStats'] as Map<String, int>;
    
    return Container(
      padding: AppResponsive.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks by Category',
            style: TextStyle(
              fontSize: AppResponsive.fontXl,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppResponsive.gapXl),
          for (var entry in categoryStats.entries)
            Padding(
              padding: AppResponsive.vertical(4),
              child: Row(
                children: [
                  Container(
                    width: AppResponsive.w(12),
                    height: AppResponsive.h(12),
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(entry.key),
                      borderRadius: BorderRadius.circular(AppResponsive.r(2)),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(8)),
                  Expanded(
                    child: Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(fontSize: AppResponsive.fontSm),
                    ),
                  ),
                  Text(
                    '${entry.value} (${stats['totalTasks'] > 0
                      ? (entry.value / stats['totalTasks'] * 100).toStringAsFixed(1)
                      : 0.0}%)',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(Map<String, dynamic> stats) {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayTasks = widget.tasks.where((task) =>
          task.completedAt != null &&
          task.completedAt!.day == date.day &&
          task.completedAt!.month == date.month &&
          task.completedAt!.year == date.year).length;
      
      return {
        'day': DateFormat('E').format(date),
        'completed': dayTasks,
      };
    });

    return Container(
      padding: AppResponsive.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: AppResponsive.fontXl,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppResponsive.gapXxl),
          SizedBox(
            height: AppResponsive.h(90),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekData.map((day) {
                final maxHeight = AppResponsive.h(70);
                final maxValue = weekData
                    .map((d) => d['completed'] as int)
                    .reduce((a, b) => a > b ? a : b);
                final height = maxValue > 0
                    ? (day['completed'] as int) / maxValue * maxHeight
                    : 0.0;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${day['completed']}',
                      style: TextStyle(
                        fontSize: AppResponsive.fontXs,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(4)),
                    Container(
                      width: AppResponsive.w(18),
                      height: height,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(AppResponsive.r(4)),
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(4)),
                    Text(
                      day['day'] as String,
                      style: TextStyle(
                        fontSize: AppResponsive.fontXs,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(Map<String, dynamic> stats) {
    final insights = _generateInsights(stats);
    
    return Container(
      padding: AppResponsive.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights & Tips',
            style: TextStyle(
              fontSize: AppResponsive.fontXl,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppResponsive.gapXl),
          for (var insight in insights)
            Padding(
              padding: AppResponsive.vertical(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: AppResponsive.h(6)),
                    width: AppResponsive.w(6),
                    height: AppResponsive.h(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(12)),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: AppResponsive.fontBase,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<String> _generateInsights(Map<String, dynamic> stats) {
    final insights = <String>[];
    
    if (stats['completionRate'] >= 80) {
      insights.add('Excellent work! You have a ${stats['completionRate'].toStringAsFixed(1)}% completion rate.');
    } else if (stats['completionRate'] >= 60) {
      insights.add('Good progress! Try to improve your completion rate from ${stats['completionRate'].toStringAsFixed(1)}%.');
    } else {
      insights.add('Focus on completing existing tasks before adding new ones.');
    }
    
    if (stats['overdueTasks'] > 0) {
      insights.add('You have ${stats['overdueTasks']} overdue tasks. Consider prioritizing them.');
    }
    
    if (stats['thisWeekCompleted'] > stats['thisMonthCompleted'] / 4) {
      insights.add('Great weekly performance! You\'re ahead of your monthly average.');
    }
    
    final categoryStats = stats['categoryStats'] as Map<String, int>;
    if (categoryStats.isNotEmpty) {
      final topCategory = categoryStats.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Most of your tasks are in ${topCategory.key} category (${topCategory.value} tasks).');
    }
    
    if (insights.isEmpty) {
      insights.add('Keep adding tasks and track your productivity over time!');
    }
    
    return insights;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}