// File: lib/models/notification_rule.dart
// Definisi NotificationRule yang akan digunakan di seluruh aplikasi

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