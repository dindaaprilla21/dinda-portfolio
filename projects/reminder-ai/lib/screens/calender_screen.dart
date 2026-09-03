import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../widgets/custom_calender.dart';
import '../widgets/task_card.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(int)? onTaskComplete;
  final Function(int)? onTaskDelete;
  final Function(Task)? onTaskEdit;

  const CalendarScreen({
    super.key,
    required this.tasks,
    this.onTaskComplete,
    this.onTaskDelete,
    this.onTaskEdit,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Task> _selectedDayTasks = [];

  @override
  void initState() {
    super.initState();
    _updateSelectedDayTasks();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedDayTasks();
  }

  void _updateSelectedDayTasks() {
    final normalizedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() {
      _selectedDayTasks = widget.tasks.where((task) {
        if (task.status != 'completed') return false;

        final deadlineDate = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
        );

        final completedDate = task.completedAt != null
            ? DateTime(
                task.completedAt!.year,
                task.completedAt!.month,
                task.completedAt!.day,
              )
            : null;

        return deadlineDate == normalizedDay || completedDate == normalizedDay;
      }).toList();
      
      // Sort by completedAt or deadline time (most recent first)
      _selectedDayTasks.sort((a, b) {
        final timeA = a.completedAt ?? a.deadline;
        final timeB = b.completedAt ?? b.deadline;
        return timeB.compareTo(timeA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar — matches home screen dark purple gradient
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF384256), Color(0xFF5E6D8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            title: Text(
              'Kalender',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: AppResponsive.font3xl,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: false,
          ),

          // Calendar Widget
          SliverToBoxAdapter(
            child: CustomCalendar(
              tasks: widget.tasks,
              selectedDay: _selectedDay,
              onDaySelected: (selectedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
                _updateSelectedDayTasks();
              },
            ),
          ),

          // Selected Day Tasks Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppResponsive.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: AppResponsive.w(4),
                    height: AppResponsive.h(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(AppResponsive.r(2)),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(12)),
                  Expanded(
                    child: Text(
                      isSameDay(_selectedDay, DateTime.now())
                          ? 'Tugas yang Sudah Terselesaikan'
                          : 'Tugas Terselesaikan (${DateFormat('dd MMM yyyy').format(_selectedDay)})',
                      style: GoogleFonts.outfit(
                        fontSize: AppResponsive.fontXl,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tasks List or Empty State
          _selectedDayTasks.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyState(),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = _selectedDayTasks[index];
                      return TaskCard(
                        task: task,
                        onComplete: () {
                          widget.onTaskComplete?.call(task.id!);
                          _updateSelectedDayTasks();
                        },
                        onDelete: () {
                          widget.onTaskDelete?.call(task.id!);
                          _updateSelectedDayTasks();
                        },
                        onEdit: () {
                          widget.onTaskEdit?.call(task);
                        },
                      );
                    },
                    childCount: _selectedDayTasks.length,
                  ),
                ),
          
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildEmptyState() {
    final isTodayFlag = isSameDay(_selectedDay, DateTime.now());

    return Container(
      margin: AppResponsive.symmetric(horizontal: 16, vertical: 14),
      padding: AppResponsive.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: AppResponsive.w(16),
            offset: Offset(0, AppResponsive.h(8)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: AppResponsive.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTodayFlag
                  ? Icons.auto_awesome_rounded
                  : Icons.calendar_today_rounded,
              size: AppResponsive.iconXl,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: AppResponsive.gapXxl),
          Text(
            isTodayFlag ? 'Belum Ada Tugas Selesai' : 'Tidak Ada Tugas Selesai',
            style: GoogleFonts.outfit(
              fontSize: AppResponsive.font2xl,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppResponsive.gapMd),
          Text(
            isTodayFlag
                ? 'Belum ada tugas yang diselesaikan hari ini. Tetap semangat, ya!'
                : 'Belum ada riwayat tugas selesai untuk tanggal ini.',
            style: GoogleFonts.outfit(
              fontSize: AppResponsive.fontBase,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}