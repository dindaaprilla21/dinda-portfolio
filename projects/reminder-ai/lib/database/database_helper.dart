import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _databaseName = 'reminder_ai.db';
  static const int _databaseVersion = 4;

  // Table and column names
  static const String tableTask = 'tasks';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnDeadline = 'deadline';
  static const String columnCategory = 'category';
  static const String columnPriority = 'priority';
  static const String columnStatus = 'status';
  static const String columnCreatedAt = 'created_at';
  static const String columnCompletedAt = 'completed_at';
  static const String columnDifficultyLevel = 'difficulty_level';
  static const String columnEstimatedHours = 'estimated_hours';
  static const String columnRingtone = 'ringtone';
  static const String columnNotificationSchedule = 'notification_schedule';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTask (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnDeadline TEXT NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnPriority INTEGER DEFAULT 1,
        $columnStatus TEXT DEFAULT 'pending',
        $columnCreatedAt TEXT NOT NULL,
        $columnCompletedAt TEXT,
        $columnDifficultyLevel INTEGER DEFAULT 3,
        $columnEstimatedHours REAL DEFAULT 1.0,
        $columnRingtone TEXT DEFAULT 'default',
        $columnNotificationSchedule TEXT DEFAULT 'default'
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_task_deadline ON $tableTask($columnDeadline)
    ''');

    await db.execute('''
      CREATE INDEX idx_task_status ON $tableTask($columnStatus)
    ''');

    await db.execute('''
      CREATE INDEX idx_task_category ON $tableTask($columnCategory)
    ''');

    debugPrint('✅ Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('📈 Database upgraded from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Migrasi v1 → v2: Tambah kolom untuk SAW
      await db.execute(
        'ALTER TABLE $tableTask ADD COLUMN $columnDifficultyLevel INTEGER DEFAULT 3',
      );
      await db.execute(
        'ALTER TABLE $tableTask ADD COLUMN $columnEstimatedHours REAL DEFAULT 1.0',
      );
      debugPrint(
        '✅ Migrasi v2: Kolom difficulty_level dan estimated_hours ditambahkan',
      );
    }

    if (oldVersion < 3) {
      // Migrasi v2 → v3: Tambah kolom ringtone
      await db.execute(
        "ALTER TABLE $tableTask ADD COLUMN $columnRingtone TEXT DEFAULT 'default'",
      );
      debugPrint('✅ Migrasi v3: Kolom ringtone ditambahkan');
    }

    if (oldVersion < 4) {
      // Migrasi v3 → v4: Tambah kolom notification schedule
      await db.execute(
        "ALTER TABLE $tableTask ADD COLUMN $columnNotificationSchedule TEXT DEFAULT 'default'",
      );
      debugPrint('✅ Migrasi v4: Kolom notification_schedule ditambahkan');
    }
  }

  Future<void> _onOpen(Database db) async {
    debugPrint('✅ Database opened successfully');
  }

  // CRUD Operations

  // Insert new task
  Future<int> insertTask(Task task) async {
    try {
      final db = await database;
      final id = await db.insert(
        tableTask,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Task inserted with ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ Error inserting task: $e');
      rethrow;
    }
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('📋 Retrieved ${tasks.length} tasks from database');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error getting all tasks: $e');
      return [];
    }
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(String status) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where: '$columnStatus = ?',
        whereArgs: [status],
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('📋 Retrieved ${tasks.length} tasks with status: $status');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error getting tasks by status: $e');
      return [];
    }
  }

  // Get tasks by date range
  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where: '$columnDeadline >= ? AND $columnDeadline <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('📋 Retrieved ${tasks.length} tasks in date range');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error getting tasks by date range: $e');
      return [];
    }
  }

  // Get tasks for specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getTasksByDateRange(startOfDay, endOfDay);
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        debugPrint('✅ Task found with ID: $id');
        return Task.fromMap(maps.first);
      }
      debugPrint('⚠️ Task not found with ID: $id');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting task by ID: $e');
      return null;
    }
  }

  // Update task
  Future<int> updateTask(Task task) async {
    try {
      final db = await database;
      final count = await db.update(
        tableTask,
        task.toMap(),
        where: '$columnId = ?',
        whereArgs: [task.id],
      );
      debugPrint('✅ Task updated: $count rows affected');
      return count;
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
      rethrow;
    }
  }

  // Delete task - UPDATED dengan cancel notification
  Future<int> deleteTask(int id) async {
    try {
      final db = await database;

      // Cancel notifikasi dulu sebelum hapus task
      await NotificationService().cancelTaskNotifications(id);

      final count = await db.delete(
        tableTask,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      debugPrint(
        '✅ Task deleted and notifications cancelled: $count rows affected',
      );
      return count;
    } catch (e) {
      debugPrint('❌ Error deleting task: $e');
      rethrow;
    }
  }

  // Mark task as completed - UPDATED dengan cancel notification
  Future<int> markTaskCompleted(int id) async {
    try {
      final db = await database;
      final count = await db.update(
        tableTask,
        {
          columnStatus: 'completed',
          columnCompletedAt: DateTime.now().toIso8601String(),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );

      // Cancel notifikasi untuk task ini
      await NotificationService().cancelTaskNotifications(id);

      debugPrint(
        '✅ Task marked as completed and notifications cancelled: $count rows affected',
      );
      return count;
    } catch (e) {
      debugPrint('❌ Error marking task as completed: $e');
      rethrow;
    }
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStatistics() async {
    try {
      final db = await database;

      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableTask',
      );
      final total = totalResult.first['count'] as int;

      final pendingResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableTask WHERE $columnStatus = ?',
        ['pending'],
      );
      final pending = pendingResult.first['count'] as int;

      final completedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableTask WHERE $columnStatus = ?',
        ['completed'],
      );
      final completed = completedResult.first['count'] as int;

      final overdueResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableTask WHERE $columnStatus = ? AND $columnDeadline < ?',
        ['pending', DateTime.now().toIso8601String()],
      );
      final overdue = overdueResult.first['count'] as int;

      final stats = {
        'total': total,
        'pending': pending,
        'completed': completed,
        'overdue': overdue,
      };

      debugPrint('📊 Task statistics: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ Error getting task statistics: $e');
      return {'total': 0, 'pending': 0, 'completed': 0, 'overdue': 0};
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where: '$columnTitle LIKE ? OR $columnDescription LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('🔍 Search found ${tasks.length} tasks for query: "$query"');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error searching tasks: $e');
      return [];
    }
  }

  // Get tasks by category
  Future<List<Task>> getTasksByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where: '$columnCategory = ?',
        whereArgs: [category],
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('📂 Retrieved ${tasks.length} tasks in category: $category');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error getting tasks by category: $e');
      return [];
    }
  }

  // Delete all completed tasks - UPDATED dengan cancel notification
  Future<int> deleteCompletedTasks() async {
    try {
      final db = await database;

      // Get completed tasks first to cancel their notifications
      final completedTasks = await getTasksByStatus('completed');

      // Cancel notifications for each completed task
      for (var task in completedTasks) {
        if (task.id != null) {
          await NotificationService().cancelTaskNotifications(task.id!);
        }
      }

      final count = await db.delete(
        tableTask,
        where: '$columnStatus = ?',
        whereArgs: ['completed'],
      );
      debugPrint(
        '🗑️ Deleted $count completed tasks and cancelled their notifications',
      );
      return count;
    } catch (e) {
      debugPrint('❌ Error deleting completed tasks: $e');
      rethrow;
    }
  }

  /// Hapus otomatis tugas selesai yang lebih tua dari N hari (default: 30 hari)
  Future<int> deleteCompletedTasksOlderThanDays([int days = 30]) async {
    try {
      final db = await database;
      final completedTasks = await getTasksByStatus('completed');
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      int deletedCount = 0;

      for (var task in completedTasks) {
        if (task.id == null) continue;

        final completedDate = task.completedAt ?? task.createdAt;

        if (completedDate.isBefore(cutoffDate)) {
          await NotificationService().cancelTaskNotifications(task.id!);
          await db.delete(
            tableTask,
            where: '$columnId = ?',
            whereArgs: [task.id],
          );
          deletedCount++;
        }
      }

      debugPrint(
        '🗑️ Auto-deleted $deletedCount completed tasks older than $days days',
      );
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error auto-deleting completed tasks: $e');
      return 0;
    }
  }

  // 🚀 PERBAIKAN UTAMA: Clear all data dengan comprehensive cleanup
  Future<void> clearAllData() async {
    try {
      final db = await database;

      debugPrint('🧹 Starting comprehensive data cleanup...');

      // Step 1: Cancel all notifications SEBELUM hapus data
      debugPrint('🔔 Cancelling all notifications...');
      await NotificationService().cancelAllNotifications();

      // Step 2: Hapus semua data dalam transaction untuk atomicity
      await db.transaction((txn) async {
        debugPrint('🗑️ Deleting all tasks...');

        // Delete all tasks
        final taskCount = await txn.delete(tableTask);
        debugPrint('📋 Deleted $taskCount tasks');

        // Reset auto increment counter untuk tasks table
        debugPrint('🔄 Resetting auto increment counters...');
        await txn.execute('DELETE FROM sqlite_sequence WHERE name = ?', [
          tableTask,
        ]);

        // Optional: Reset any other tables jika ada
        // await txn.delete('other_table');
        // await txn.execute('DELETE FROM sqlite_sequence WHERE name = ?', ['other_table']);

        debugPrint('✅ All data deleted successfully within transaction');
      });

      // Step 3: Verify cleanup dengan count
      final remainingTasks = await getAllTasks();
      if (remainingTasks.isEmpty) {
        debugPrint('✅ Data cleanup verification passed - no remaining tasks');
      } else {
        debugPrint(
          '⚠️ Warning: ${remainingTasks.length} tasks still remain after cleanup',
        );
      }

      // Step 4: Vacuum database untuk cleanup storage
      debugPrint('🧽 Vacuuming database...');
      await db.execute('VACUUM');

      debugPrint('🎉 Complete data cleanup finished successfully!');
    } catch (e) {
      debugPrint('❌ Error during comprehensive data cleanup: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // 🆕 TAMBAHAN: Clear specific data types
  Future<void> clearTasksOnly() async {
    try {
      final db = await database;

      // Get all tasks first to cancel notifications
      final allTasks = await getAllTasks();

      // Cancel notifications for all tasks
      for (var task in allTasks) {
        if (task.id != null) {
          await NotificationService().cancelTaskNotifications(task.id!);
        }
      }

      // Delete all tasks
      await db.delete(tableTask);

      // Reset auto increment
      await db.execute('DELETE FROM sqlite_sequence WHERE name = ?', [
        tableTask,
      ]);

      debugPrint('✅ All tasks cleared and notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error clearing tasks only: $e');
      rethrow;
    }
  }

  // 🆕 TAMBAHAN: Database integrity check
  Future<bool> checkDatabaseIntegrity() async {
    try {
      final db = await database;

      // PRAGMA integrity_check
      final result = await db.rawQuery('PRAGMA integrity_check');
      final isOk = result.isNotEmpty && result.first.values.first == 'ok';

      debugPrint('🔍 Database integrity check: ${isOk ? "PASSED" : "FAILED"}');

      if (!isOk) {
        debugPrint('❌ Database integrity issues found: $result');
      }

      return isOk;
    } catch (e) {
      debugPrint('❌ Error checking database integrity: $e');
      return false;
    }
  }

  // 🆕 TAMBAHAN: Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;

      // Get database file size
      final dbPath = db.path;
      final file = File(dbPath);
      final sizeInBytes = await file.length();
      final sizeInKB = (sizeInBytes / 1024).round();

      // Get table info
      final tableInfo = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tables = tableInfo.map((row) => row['name']).toList();

      // Get task counts
      final stats = await getTaskStatistics();

      final info = {
        'databasePath': dbPath,
        'sizeInBytes': sizeInBytes,
        'sizeInKB': sizeInKB,
        'tables': tables,
        'taskStatistics': stats,
        'version': _databaseVersion,
      };

      debugPrint('ℹ️ Database info: $info');
      return info;
    } catch (e) {
      debugPrint('❌ Error getting database info: $e');
      return {};
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      final db = _database!;
      await db.close();
      _database = null;
      debugPrint('🔒 Database closed successfully');
    }
  }

  // Additional helper methods for better performance

  // Batch insert multiple tasks
  Future<void> insertTasksBatch(List<Task> tasks) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (var task in tasks) {
        batch.insert(tableTask, task.toMap());
      }

      await batch.commit(noResult: true);
      debugPrint('✅ Batch inserted ${tasks.length} tasks');
    } catch (e) {
      debugPrint('❌ Error batch inserting tasks: $e');
      rethrow;
    }
  }

  // Get task count by status
  Future<int> getTaskCountByStatus(String status) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableTask WHERE $columnStatus = ?',
        [status],
      );
      final count = result.first['count'] as int;
      debugPrint('📊 Task count for status "$status": $count');
      return count;
    } catch (e) {
      debugPrint('❌ Error getting task count by status: $e');
      return 0;
    }
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where: '$columnStatus = ? AND $columnDeadline < ?',
        whereArgs: ['pending', DateTime.now().toIso8601String()],
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('⏰ Retrieved ${tasks.length} overdue tasks');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error getting overdue tasks: $e');
      return [];
    }
  }

  // Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTask,
        where:
            '$columnStatus = ? AND $columnDeadline >= ? AND $columnDeadline < ?',
        whereArgs: [
          'pending',
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
        orderBy: '$columnDeadline ASC',
      );

      final tasks = List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });

      debugPrint('📅 Retrieved ${tasks.length} tasks due today');
      return tasks;
    } catch (e) {
      debugPrint('❌ Error getting tasks due today: $e');
      return [];
    }
  }

  // Update task status only - UPDATED dengan cancel notification jika completed
  Future<int> updateTaskStatus(int id, String status) async {
    try {
      final db = await database;
      final updateData = <String, dynamic>{columnStatus: status};

      if (status == 'completed') {
        updateData[columnCompletedAt] = DateTime.now().toIso8601String();
        // Cancel notification jika status jadi completed
        await NotificationService().cancelTaskNotifications(id);
        debugPrint('🔔 Notifications cancelled for completed task ID: $id');
      }

      final count = await db.update(
        tableTask,
        updateData,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Task status updated to "$status": $count rows affected');
      return count;
    } catch (e) {
      debugPrint('❌ Error updating task status: $e');
      rethrow;
    }
  }

  // 🆕 TAMBAHAN: Backup and restore methods
  Future<List<Map<String, dynamic>>> exportAllData() async {
    try {
      final db = await database;
      final data = await db.query(tableTask);
      debugPrint('📤 Exported ${data.length} tasks');
      return data;
    } catch (e) {
      debugPrint('❌ Error exporting data: $e');
      return [];
    }
  }

  Future<void> importData(List<Map<String, dynamic>> data) async {
    try {
      final db = await database;

      await db.transaction((txn) async {
        for (var taskData in data) {
          await txn.insert(
            tableTask,
            taskData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      debugPrint('📥 Imported ${data.length} tasks');
    } catch (e) {
      debugPrint('❌ Error importing data: $e');
      rethrow;
    }
  }
}
