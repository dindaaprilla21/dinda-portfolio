import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';


class CustomCalendar extends StatefulWidget {
  final List<Task> tasks;
  final Function(DateTime)? onDaySelected;
  final DateTime? selectedDay;

  const CustomCalendar({
    super.key,
    required this.tasks,
    this.onDaySelected,
    this.selectedDay,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
  }

  @override
  void didUpdateWidget(CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      setState(() {
        _selectedDay = widget.selectedDay;
      });
    }
  }

  // Group tasks by date (normalized)
  Map<DateTime, List<Task>> _groupTasksByDate() {
    Map<DateTime, List<Task>> taskMap = {};
    
    for (var task in widget.tasks) {
      final deadlineDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      
      taskMap.putIfAbsent(deadlineDate, () => []).add(task);

      if (task.status == 'completed' && task.completedAt != null) {
        final completedDate = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        if (completedDate != deadlineDate) {
          taskMap.putIfAbsent(completedDate, () => []).add(task);
        }
      }
    }
    
    return taskMap;
  }

  // Get tasks for specific day
  List<Task> _getTasksForDay(DateTime day) {
    final taskMap = _groupTasksByDate();
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return taskMap[normalizedDay] ?? [];
  }

  // Check if day has tasks
  bool _hasTasksOnDay(DateTime day) {
    return _getTasksForDay(day).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius3xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF384256).withOpacity(0.12),
            blurRadius: AppResponsive.w(24),
            offset: Offset(0, AppResponsive.h(10)),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.pagePaddingH,
        vertical: AppResponsive.h(6),
      ),
      child: Column(
        children: [
          // Calendar Header — matching app bar purple gradient
          Container(
            padding: AppResponsive.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF384256), Color(0xFF5E6D8C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppResponsive.radius3xl),
                topRight: Radius.circular(AppResponsive.radius3xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: AppResponsive.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: AppResponsive.iconMd,
                  ),
                ),
                SizedBox(width: AppResponsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDay),
                        style: GoogleFonts.outfit(
                          fontSize: AppResponsive.fontLg,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Ringkasan Jadwal',
                        style: GoogleFonts.outfit(
                          fontSize: AppResponsive.fontSm,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Table Calendar
          TableCalendar<Task>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            
            // Calendar format
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            
            // Event loader (tasks for each day)
            eventLoader: _getTasksForDay,
            
            // Calendar style
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle: GoogleFonts.outfit(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              selectedTextStyle: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              weekendTextStyle: GoogleFonts.outfit(
                color: AppTheme.errorColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              defaultTextStyle: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              outsideTextStyle: GoogleFonts.outfit(
                color: AppTheme.textSecondary.withOpacity(0.3),
              ),
              markerDecoration: BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: EdgeInsets.zero,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            headerVisible: false, // Sembunyikan header bawaan karena kita sudah buat custom
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: AppResponsive.fontSm,
              ),
              weekendStyle: GoogleFonts.outfit(
                color: AppTheme.errorColor.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: AppResponsive.fontSm,
              ),
            ),
            
            // Calendar builders for custom indicators
            calendarBuilders: CalendarBuilders(
              // Custom marker builder for task indicators
              markerBuilder: (context, day, tasks) {
                if (tasks.isEmpty) return null;
                
                return _buildTaskIndicators(tasks);
              },
              
              // Custom day builder for special styling
              defaultBuilder: (context, day, focusedDay) {
                final hasTask = _hasTasksOnDay(day);
                
                return Container(
                  margin: EdgeInsets.all(AppResponsive.r(2)),
                  decoration: BoxDecoration(
                    color: hasTask 
                        ? AppTheme.primaryColor.withOpacity(0.05)
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: hasTask ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Callbacks
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDaySelected?.call(selectedDay);
            },
            
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget? _buildTaskIndicators(List<Task> tasks) {
    // Group tasks by priority
    final highPriority = tasks.where((t) => t.priority == 3 && t.status == 'pending').length;
    final mediumPriority = tasks.where((t) => t.priority == 2 && t.status == 'pending').length;
    final lowPriority = tasks.where((t) => t.priority == 1 && t.status == 'pending').length;
    final completed = tasks.where((t) => t.status == 'completed').length;

    List<Widget> indicators = [];

    // Show priority indicators
    if (highPriority > 0) {
      indicators.add(_createIndicator(AppTheme.errorColor, highPriority));
    }
    if (mediumPriority > 0) {
      indicators.add(_createIndicator(AppTheme.warningColor, mediumPriority));
    }
    if (lowPriority > 0) {
      indicators.add(_createIndicator(AppTheme.successColor, lowPriority));
    }
    if (completed > 0) {
      indicators.add(_createIndicator(AppTheme.textSecondary, completed));
    }

    if (indicators.isEmpty) return null;

    return Positioned(
      bottom: AppResponsive.h(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: indicators.take(3).map((indicator) => 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(0.5)),
            child: indicator,
          )
        ).toList(),
      ),
    );
  }

  Widget _createIndicator(Color color, int count) {
    return Container(
      width: AppResponsive.w(6),
      height: AppResponsive.h(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(16)),
          child: Divider(
            height: 1,
            color: AppTheme.borderColor.withOpacity(0.5),
          ),
        ),
        Container(
          padding: AppResponsive.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.transparent, // Uses the parent white background seamlessly
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppResponsive.radius3xl),
              bottomRight: Radius.circular(AppResponsive.radius3xl),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keterangan:',
                style: GoogleFonts.outfit(
                  fontSize: AppResponsive.fontSm,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: AppResponsive.h(10)),
              Wrap(
                spacing: AppResponsive.w(16),
                runSpacing: AppResponsive.h(8),
                children: [
                  _buildLegendItem('Tinggi', AppTheme.errorColor),
                  _buildLegendItem('Sedang', AppTheme.warningColor),
                  _buildLegendItem('Rendah', AppTheme.successColor),
                  _buildLegendItem('Selesai', AppTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppResponsive.w(8),
          height: AppResponsive.h(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: AppResponsive.w(4),
                offset: Offset(0, AppResponsive.h(2)),
              ),
            ],
          ),
        ),
        SizedBox(width: AppResponsive.w(8)),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: AppResponsive.fontSm,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}