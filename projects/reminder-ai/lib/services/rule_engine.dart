import 'package:flutter/material.dart';
import '../models/task_model.dart';

// NotificationRule class is defined here and exported for use in other files
class NotificationRule {
  final String id;
  final String name;
  final String message;
  final String priority; // low, medium, high, critical
  final String type; // reminder, urgent, overdue, motivational
  final DateTime triggerTime;
  final Map<String, dynamic> metadata;

  NotificationRule({
    required this.id,
    required this.name,
    required this.message,
    required this.priority,
    required this.type,
    required this.triggerTime,
    this.metadata = const {},
  });

  @override
  String toString() {
    return 'NotificationRule{id: $id, name: $name, priority: $priority, type: $type}';
  }
}

class RuleEngine {
  static final RuleEngine _instance = RuleEngine._internal();
  factory RuleEngine() => _instance;
  RuleEngine._internal();

  // Evaluate single task against all rules
  List<NotificationRule> evaluateTask(Task task) {
    final rules = <NotificationRule>[];
    final now = DateTime.now();
    final deadline = task.deadline;
    final difference = deadline.difference(now);

    // Skip completed tasks
    if (task.status == 'completed') return rules;

    // Rule 1: Overdue tasks (Critical)
    if (difference.isNegative) {
      final daysOverdue = difference.inDays.abs();
      rules.add(NotificationRule(
        id: 'overdue_${task.id}',
        name: 'Task Overdue',
        message: _getOverdueMessage(task, daysOverdue),
        priority: 'critical',
        type: 'overdue',
        triggerTime: now,
        metadata: {
          'taskId': task.id,
          'daysOverdue': daysOverdue,
        },
      ));
    }

    // Rule 2: Due in next hour (Critical)
    else if (difference.inMinutes <= 60 && difference.inMinutes > 0) {
      rules.add(NotificationRule(
        id: 'due_hour_${task.id}',
        name: 'Due Within Hour',
        message: '🚨 URGENT: "${task.title}" deadline dalam ${difference.inMinutes} menit!',
        priority: 'critical',
        type: 'urgent',
        triggerTime: now,
        metadata: {
          'taskId': task.id,
          'minutesLeft': difference.inMinutes,
        },
      ));
    }

    // Rule 3: Due today (High)
    else if (difference.inHours <= 24 && difference.inHours > 1) {
      rules.add(NotificationRule(
        id: 'due_today_${task.id}',
        name: 'Due Today',
        message: '⏰ "${task.title}" deadline hari ini dalam ${difference.inHours} jam!',
        priority: 'high',
        type: 'urgent',
        triggerTime: now,
        metadata: {
          'taskId': task.id,
          'hoursLeft': difference.inHours,
        },
      ));
    }

    // Rule 4: Due tomorrow (Medium)
    else if (difference.inDays == 1) {
      rules.add(NotificationRule(
        id: 'due_tomorrow_${task.id}',
        name: 'Due Tomorrow',
        message: '📅 Jangan lupa! "${task.title}" deadline besok',
        priority: 'medium',
        type: 'reminder',
        triggerTime: now,
        metadata: {
          'taskId': task.id,
          'daysLeft': 1,
        },
      ));
    }

    // Rule 5: Due in 2-3 days (Medium)
    else if (difference.inDays <= 3 && difference.inDays > 1) {
      rules.add(NotificationRule(
        id: 'due_soon_${task.id}',
        name: 'Due Soon',
        message: '📋 "${task.title}" deadline ${difference.inDays} hari lagi',
        priority: 'medium',
        type: 'reminder',
        triggerTime: now,
        metadata: {
          'taskId': task.id,
          'daysLeft': difference.inDays,
        },
      ));
    }

    // Rule 7: High priority tasks get extra reminders
    if (task.priority == 3 && difference.inDays <= 5 && difference.inDays > 0) {
      rules.add(NotificationRule(
        id: 'high_priority_${task.id}',
        name: 'High Priority Task',
        message: '⭐ PRIORITAS TINGGI: "${task.title}" jangan sampai terlupa!',
        priority: 'high',
        type: 'urgent',
        triggerTime: now,
        metadata: {
          'taskId': task.id,
          'taskPriority': task.priority,
        },
      ));
    }

    // Rule 8: Morning motivation (if task due today)
    if (difference.inHours <= 24 && difference.inHours > 0) {
      final hour = now.hour;
      if (hour >= 6 && hour <= 9) {
        rules.add(NotificationRule(
          id: 'morning_motivation_${task.id}',
          name: 'Morning Motivation',
          message: '🌅 Pagi yang produktif! Yuk selesaikan "${task.title}" hari ini!',
          priority: 'medium',
          type: 'motivational',
          triggerTime: now,
          metadata: {
            'taskId': task.id,
            'timeOfDay': 'morning',
          },
        ));
      }
    }

    return rules;
  }

  // Evaluate all tasks
  List<NotificationRule> evaluateAllTasks(List<Task> tasks) {
    debugPrint('Evaluating ${tasks.length} tasks against rules');
    
    final allRules = <NotificationRule>[];
    
    for (var task in tasks) {
      allRules.addAll(evaluateTask(task));
    }

    // Sort by priority: critical > high > medium > low
    allRules.sort((a, b) {
      const priorityOrder = {
        'critical': 4,
        'high': 3,
        'medium': 2,
        'low': 1,
      };
      
      return (priorityOrder[b.priority] ?? 0).compareTo(
          priorityOrder[a.priority] ?? 0);
    });

    debugPrint('Generated ${allRules.length} notification rules');
    return allRules;
  }

  // Generate smart suggestions
  List<String> generateSmartSuggestions(List<Task> tasks) {
    final suggestions = <String>[];
    final now = DateTime.now();
    
    // Analyze task patterns
    final overdueTasks = tasks.where((t) => 
        t.deadline.isBefore(now) && t.status == 'pending').length;
    
    final todayTasks = tasks.where((t) => 
        t.deadline.day == now.day && 
        t.deadline.month == now.month && 
        t.deadline.year == now.year && 
        t.status == 'pending').length;

    final highPriorityTasks = tasks.where((t) => 
        t.priority == 3 && t.status == 'pending').length;

    final weekTasks = tasks.where((t) => 
        t.deadline.isAfter(now) && 
        t.deadline.isBefore(now.add(Duration(days: 7))) &&
        t.status == 'pending').length;

    // Generate contextual suggestions
    if (overdueTasks > 3) {
      suggestions.add('Fokus pada tugas yang terlambat! Prioritaskan yang paling penting.');
    }

    if (todayTasks > 2) {
      suggestions.add('$todayTasks tugas hari ini. Buat time block untuk menyelesaikannya!');
    }

    if (highPriorityTasks > 1) {
      suggestions.add('$highPriorityTasks tugas prioritas tinggi. Kerjakan yang paling urgent dulu!');
    }

    if (weekTasks > 5) {
      suggestions.add('$weekTasks tugas minggu ini. Mulai persiapan dari sekarang!');
    }

    // Time-based suggestions
    final hour = now.hour;
    if (hour < 12 && todayTasks > 0) {
      suggestions.add('Pagi yang produktif! Manfaatkan energi pagi untuk tugas berat.');
    } else if (hour > 18 && todayTasks > 0) {
      suggestions.add('Review progress harian dan siapkan planning untuk besok.');
    }

    // Motivational messages
    final completedToday = tasks.where((t) => 
        t.completedAt != null &&
        t.completedAt!.day == now.day &&
        t.completedAt!.month == now.month &&
        t.completedAt!.year == now.year).length;

    if (completedToday > 0) {
      suggestions.add('Great job! Kamu sudah menyelesaikan $completedToday tugas hari ini!');
    }

    return suggestions.take(3).toList(); // Limit to 3 suggestions
  }

  String _getOverdueMessage(Task task, int daysOverdue) {
    if (daysOverdue == 0) {
      return '❌ "${task.title}" sudah terlambat! Segera selesaikan.';
    } else if (daysOverdue == 1) {
      return '❌ "${task.title}" terlambat 1 hari. Prioritaskan sekarang!';
    } else {
      return '❌ "${task.title}" terlambat $daysOverdue hari. Perlu tindakan cepat!';
    }
  }

  // Get motivation message based on time and context
  String getMotivationalMessage(List<Task> tasks) {
    final hour = DateTime.now().hour;
    final pendingTasks = tasks.where((t) => t.status == 'pending').length;
    
    if (hour < 12) {
      return pendingTasks > 0 
          ? '🌅 Pagi yang produktif! Kamu bisa menyelesaikan $pendingTasks tugas hari ini!'
          : '🌅 Pagi yang indah! Sempurna untuk planning dan produktivitas!';
    } else if (hour < 18) {
      return pendingTasks > 0
          ? '☀️ Siang yang fokus! Manfaatkan energi untuk tugas-tugas penting.'
          : '☀️ Siang yang tenang! Perfect time untuk review dan planning.';
    } else {
      return pendingTasks > 0
          ? '🌙 Sore untuk review! Selesaikan tugas atau siapkan rencana besok.'
          : '🌙 Sore yang rileks! Good job hari ini, siap untuk besok?';
    }
  }

  // Generate scheduled reminders for tasks
  List<NotificationRule> generateScheduledReminders(List<Task> tasks) {
    final rules = <NotificationRule>[];
    
    for (var task in tasks) {
      if (task.status == 'completed') continue;
      
      final deadline = task.deadline;
      final now = DateTime.now();

      // Rule: Day before reminder (at 08:00 AM)
      final dayBefore = deadline.subtract(const Duration(days: 1));
      if (dayBefore.isAfter(now)) {
        rules.add(NotificationRule(
          id: 'rule_day_${task.id}',
          name: 'Day Before Reminder',
          message: '📅 Persiapan! "${task.title}" deadline besok.',
          priority: 'medium',
          type: 'reminder',
          triggerTime: DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 8, 0),
        ));
      }

      // Rule: 2 hours before reminder
      final twoHoursBefore = deadline.subtract(const Duration(hours: 2));
      if (twoHoursBefore.isAfter(now)) {
        rules.add(NotificationRule(
          id: 'rule_hour_${task.id}',
          name: 'Final Preparation',
          message: '⌛ 2 jam lagi! Pastikan "${task.title}" sudah hampir selesai.',
          priority: 'high',
          type: 'urgent',
          triggerTime: twoHoursBefore,
        ));
      }
    }

    return rules;
  }
}