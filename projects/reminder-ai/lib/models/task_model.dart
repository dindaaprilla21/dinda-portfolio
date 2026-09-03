import '../utils/datetime_helper.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime deadline;
  final String category;
  final int priority; // 1 = Low, 2 = Medium, 3 = High
  final String status; // pending, completed, overdue
  final DateTime createdAt;
  final DateTime? completedAt;
  final int difficultyLevel; // 1-5: Sangat Mudah - Sangat Sulit
  final double estimatedHours; // Estimasi waktu pengerjaan dalam jam
  final String ringtone; // Pilihan nada dering (deprecated)
  final String notificationSchedule; // Pilihan waktu notifikasi

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.category,
    this.priority = 1,
    this.status = 'pending',
    required this.createdAt,
    this.completedAt,
    this.difficultyLevel = 3,
    this.estimatedHours = 1.0,
    this.ringtone = 'default',
    this.notificationSchedule = 'default',
  });

  // Convert Task to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'category': category,
      'priority': priority,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'difficulty_level': difficultyLevel,
      'estimated_hours': estimatedHours,
      'ringtone': ringtone,
      'notification_schedule': notificationSchedule,
    };
  }

  // Create Task from Map (database result)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      category: map['category'] ?? 'lainnya',
      priority: map['priority']?.toInt() ?? 1,
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      difficultyLevel: map['difficulty_level']?.toInt() ?? 3,
      estimatedHours: (map['estimated_hours'] ?? 1.0).toDouble(),
      ringtone: map['ringtone'] ?? 'default',
      notificationSchedule: map['notification_schedule'] ?? 'default',
    );
  }

  // Copy with changes
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    String? category,
    int? priority,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? difficultyLevel,
    double? estimatedHours,
    String? ringtone,
    String? notificationSchedule,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      ringtone: ringtone ?? this.ringtone,
      notificationSchedule: notificationSchedule ?? this.notificationSchedule,
    );
  }

  // Helper methods
  bool get isOverdue {
    return DateTimeHelper.isOverdue(deadline, DateTime.now()) && status == 'pending';
  }

  bool get isToday {
    final now = DateTime.now();
    return deadline.day == now.day && 
           deadline.month == now.month && 
           deadline.year == now.year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return deadline.day == tomorrow.day && 
           deadline.month == tomorrow.month && 
           deadline.year == tomorrow.year;
  }

  // Helper: Label tingkat kesulitan
  String get difficultyLabel {
    switch (difficultyLevel) {
      case 1: return 'Sangat Mudah';
      case 2: return 'Mudah';
      case 3: return 'Sedang';
      case 4: return 'Sulit';
      case 5: return 'Sangat Sulit';
      default: return 'Sedang';
    }
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, deadline: $deadline, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}