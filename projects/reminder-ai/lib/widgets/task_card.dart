import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';
import '../utils/datetime_helper.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
    final calendarDaysDiff = deadlineDay.difference(today).inDays;
    
    final isOverdue = task.deadline.isBefore(now) && task.status == 'pending';
    final isToday = calendarDaysDiff == 0 && !task.deadline.isBefore(now);
    final isCompleted = task.status == 'completed';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.pagePaddingH,
        vertical: AppResponsive.h(8),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: AppResponsive.w(16),
            offset: Offset(0, AppResponsive.h(8)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priority color indicator bar
                Container(
                  width: AppResponsive.w(5),
                  color: isCompleted
                      ? AppTheme.textSecondary
                      : AppTheme.getPriorityColor(task.priority),
                ),
                Expanded(
                  child: Padding(
                    padding: AppResponsive.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: AppResponsive.fontXl,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted
                                          ? AppTheme.textSecondary
                                          : AppTheme.textPrimary,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: AppResponsive.gapMd),
                                  Wrap(
                                    spacing: AppResponsive.w(6),
                                    runSpacing: AppResponsive.h(4),
                                    children: [
                                      _buildBadge(
                                        task.category.toUpperCase(),
                                        AppTheme.getCategoryColor(task.category),
                                      ),
                                      _buildBadge(
                                        _getDifficultyText(task.difficultyLevel),
                                        _getDifficultyColor(task.difficultyLevel),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppResponsive.w(8)),
                            _buildUrgencyIndicator(
                                task.deadline, now, isOverdue, isToday, isCompleted),
                          ],
                        ),
                        if (task.description.isNotEmpty) ...[
                          SizedBox(height: AppResponsive.gapLg),
                          Text(
                            task.description,
                            style: GoogleFonts.outfit(
                              fontSize: AppResponsive.fontMd,
                              color: AppTheme.textSecondary.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: AppResponsive.gapXl),
                        const Divider(height: 1, thickness: 0.5),
                        SizedBox(height: AppResponsive.gapLg),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: AppResponsive.iconSm,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: AppResponsive.w(5)),
                            Expanded(
                              child: Text(
                                DateFormat('dd MMM, HH:mm').format(task.deadline),
                                style: GoogleFonts.outfit(
                                  fontSize: AppResponsive.fontSm,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildActions(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(8),
        vertical: AppResponsive.h(3),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: AppResponsive.fontXs,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildUrgencyIndicator(
      DateTime deadline, DateTime now, bool isOverdue, bool isToday, bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: EdgeInsets.all(AppResponsive.w(6)),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: AppResponsive.iconSm,
          color: AppTheme.successColor,
        ),
      );
    }

    final color = isOverdue
        ? AppTheme.errorColor
        : (isToday ? AppTheme.warningColor : AppTheme.successColor);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(8),
        vertical: AppResponsive.h(5),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      ),
      child: Text(
        _getUrgencyText(deadline, now, isOverdue),
        style: GoogleFonts.outfit(
          color: color,
          fontSize: AppResponsive.fontXs,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.status == 'pending') ...[
          _buildActionButton(
              Icons.check_circle_rounded, AppTheme.successColor, onComplete),
          SizedBox(width: AppResponsive.w(2)),
        ],
        _buildActionButton(
            Icons.edit_rounded, AppTheme.primaryColor, onEdit),
        SizedBox(width: AppResponsive.w(2)),
        _buildActionButton(
            Icons.delete_outline_rounded, AppTheme.errorColor, onDelete),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppResponsive.radiusSm + 2),
        child: Padding(
          padding: EdgeInsets.all(AppResponsive.w(7)),
          child: Icon(icon, size: AppResponsive.iconMd, color: color),
        ),
      ),
    );
  }

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return 'SANGAT MUDAH';
      case 2:
        return 'MUDAH';
      case 3:
        return 'SEDANG';
      case 4:
        return 'SULIT';
      case 5:
        return 'SANGAT SULIT';
      default:
        return 'SEDANG';
    }
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getUrgencyText(DateTime deadline, DateTime now, bool isOverdue) {
    return DateTimeHelper.formatRemainingTime(deadline, now).toUpperCase();
  }
}