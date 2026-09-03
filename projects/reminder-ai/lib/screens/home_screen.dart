import 'package:reminder_ai/screens/ai_recommendation_screen.dart';
import 'package:reminder_ai/screens/calender_screen.dart';
import 'package:reminder_ai/screens/saw_priority_screen.dart';
import 'package:reminder_ai/services/notification_service.dart';
import 'package:reminder_ai/services/ai_recommendation_service.dart';
import 'package:flutter/material.dart';
import '../services/saw_service.dart';
import '../utils/datetime_helper.dart';
// Removed redundant audioplayers import
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'package:flutter_native_splash/flutter_native_splash.dart' as import_splash;
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../themes/app_theme.dart';
import '../database/database_helper.dart';
import '../services/rule_engine.dart';
import '../widgets/notification_panel.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart' as settings;
import '../utils/app_responsive.dart';
import '../widgets/reminder_splash_screen.dart';

// Helper function untuk mengatasi masalah dengan properti warna yang deprecated
Color colorWithOpacity(Color color, double opacity) {
  final int alpha = (opacity * 255).round();
  final int red = (color.value >> 16) & 0xFF;
  final int green = (color.value >> 8) & 0xFF;
  final int blue = color.value & 0xFF;

  return Color.fromARGB(alpha, red, green, blue);
}

// Removed redundant TimerNotificationService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  final AIRecommendationService _aiService = AIRecommendationService(tasks: []);

  List<Task> tasks = [];
  final List<NotificationRule> activeNotifications = [];
  List<String> _smartSuggestions = [
    'Semua target tercapai! Nikmati waktu luang Anda!',
  ];
  int _selectedIndex = 0;
  StudyRecommendation? _recommendation;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // 🚀 PERBAIKAN FINAL: Logika untuk menghitung stats yang akurat dengan debug

  // 🔥 PERBAIKAN 1: Logika Urgent dengan debug logging
  int _calculateUrgentTasks(List<Task> tasks) {
    final pendingTasks = tasks.where((t) => t.status == 'pending').toList();
    if (pendingTasks.isEmpty) return 0;
    final results = SAWService().calculatePriority(tasks);
    return results.where((r) => r.sawScore >= 0.65).length;
  }

  // 🔔 PERBAIKAN 2: Logika Notifikasi dengan debug logging
  int _calculateNotificationTasks(List<Task> tasks) {
    final now = DateTime.now();
    final notificationTasks = tasks.where((task) {
      if (task.status != 'pending') return false;
      if (now.isAfter(task.deadline)) return false;
      final timeDiff = task.deadline.difference(now);
      return timeDiff.inDays <= 7;
    }).toList();
    return notificationTasks.length;
  }

  // 🆕 TAMBAHAN: Dialog untuk Total Tugas
  void _showTotalTasksDetails(List<Task> pendingTasks) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.assignment, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Semua Tugas Pending',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 300),
              child:
                  pendingTasks.isEmpty
                      ? const Text(
                        '🎉 Tidak ada tugas pending!',
                        style: TextStyle(fontSize: 14),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: pendingTasks.length,
                        itemBuilder: (context, index) {
                          final task = pendingTasks[index];
                          final now = DateTime.now();
                          final timeLeft = DateTimeHelper.formatRemainingTime(task.deadline, now);
                          Color statusColor = Colors.blue;

                          if (now.isAfter(task.deadline)) {
                            statusColor = Colors.red;
                          } else {
                            final diff = task.deadline.difference(now);
                            if (diff.inDays > 0) {
                              statusColor = Colors.green;
                            } else if (diff.inHours > 0) {
                              statusColor = Colors.orange;
                            } else {
                              statusColor = Colors.red;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.primaryColor
                                      .withOpacity(0.2),
                                  child: Text(
                                    '${task.priority}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        timeLeft,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // 🆕 TAMBAHAN: Dialog untuk Tugas Beres
  void _showCompletedTasksDetails(List<Task> allTasks) {
    final completedTasks =
        allTasks.where((task) => task.status == 'completed').toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Tugas yang Udah Beres',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 300),
              child:
                  completedTasks.isEmpty
                      ? const Text(
                        '📝 Belum ada tugas yang selesai',
                        style: TextStyle(fontSize: 14),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          final task = completedTasks[index];
                          final completedDate =
                              task.completedAt ?? task.createdAt;
                          final daysSinceCompleted =
                              DateTime.now().difference(completedDate).inDays;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.successColor
                                      .withOpacity(0.2),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        daysSinceCompleted == 0
                                            ? 'Selesai hari ini'
                                            : 'Selesai $daysSinceCompleted hari lalu',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              if (completedTasks.isNotEmpty) ...[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Konfirmasi hapus semua completed tasks
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Hapus Tugas Selesai?'),
                            content: const Text(
                              'Hapus semua tugas yang sudah selesai? Ini tidak bisa dibatalkan.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirmDelete == true) {
                      try {
                        await _databaseHelper.deleteCompletedTasks();
                        await _loadTasksFromDatabase();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '🗑️ Semua tugas selesai telah dihapus',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // 🔧 PERBAIKAN 3: Dialog Urgent dengan constraint yang proper
  void _showUrgentTasksDetails(List<Task> pendingTasks) {
    List<Task> urgentTasks;
    if (_recommendation != null) {
      urgentTasks = _recommendation!.urgentTasksList;
    } else {
      if (pendingTasks.isEmpty) {
        urgentTasks = [];
      } else {
        final results = SAWService().calculatePriority(pendingTasks);
        urgentTasks = results.where((r) => r.sawScore >= 0.65).map((r) => r.task).toList();
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('Tugas Urgent', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 300),
              child:
                  urgentTasks.isEmpty
                      ? const Text(
                        '🎉 Tidak ada tugas urgent!',
                        style: TextStyle(fontSize: 14),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: urgentTasks.length,
                        itemBuilder: (context, index) {
                          final task = urgentTasks[index];
                          String urgentReason = '';
                          final now = DateTime.now();
                          if (now.isAfter(task.deadline)) {
                            urgentReason = '⏰ Terlambat';
                          } else {
                            urgentReason = '🔥 ${DateTimeHelper.formatRemainingTime(task.deadline, now)}';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.warningColor
                                      .withOpacity(0.2),
                                  child: Text(
                                    '${task.priority}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        urgentReason,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showNotificationTasksDetails(List<Task> pendingTasks) {
    final now = DateTime.now();
    final notificationTasks =
        pendingTasks.where((task) {
          if (now.isAfter(task.deadline)) return false;
          final timeDiff = task.deadline.difference(now);
          return timeDiff.inDays <= 7;
        }).toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppTheme.secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Tugas dengan Notifikasi',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 300),
              child:
                  notificationTasks.isEmpty
                      ? const Text(
                        '📱 Tidak ada notifikasi aktif',
                        style: TextStyle(fontSize: 14),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: notificationTasks.length,
                        itemBuilder: (context, index) {
                          final task = notificationTasks[index];
                          final timeLeft = DateTimeHelper.formatRemainingTime(task.deadline, DateTime.now());

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.secondaryColor
                                      .withOpacity(0.2),
                                  child: const Icon(
                                    Icons.notifications,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '🔔 $timeLeft',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // 🚀 INISIALISASI LENGKAP APLIKASI
  Future<void> _initializeApp() async {
    try {
      // 1. Load data tugas & AI secara instan terlebih dahulu
      await _loadTasksFromDatabase();

      // 2. Offload semua inisialisasi notifikasi & izin ke background microtask agar UI tidak tertahan
      Future.microtask(() async {
        try {
          await _notificationService.initialize();
          await _notificationService.reScheduleAllNotifications();
          if (mounted) {
            _checkAndRequestPermissions();
          }
          await _runInitialAnalysis();

          final pending = tasks.where((t) => t.status == 'pending').toList();
          final completed = tasks.where((t) => t.status == 'completed').toList();
          if (pending.length >= 3 && completed.isEmpty) {
            await _sendMotivationalNotification();
          }
        } catch (e) {
          debugPrint('Background init error: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ Error inisialisasi aplikasi: $e');
    }
  }

  // 🔔 CHECK DAN REQUEST PERMISSIONS - FIXED
  Future<void> _checkAndRequestPermissions() async {
    if (!mounted) return;

    try {
      bool permissionGranted = await _notificationService.checkPermissions();

      if (!permissionGranted && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        bool userWantsNotifications = await _notificationService
            .showPermissionDialog(context);
        if (userWantsNotifications && mounted) {
          permissionGranted = await _notificationService.requestPermissions();

          if (permissionGranted) {
            // Re-schedule notifications after permission granted
            await _scheduleAllTaskNotifications();
          }
        }
      }

      debugPrint('✅ Pemeriksaan izin selesai. Diizinkan: $permissionGranted');
    } catch (e) {
      debugPrint('❌ Error memeriksa izin: $e');
    }
  }

  // FIXED: _loadTasksFromDatabase (1-Pass Render untuk Instant & Stable UI)
  Future<void> _loadTasksFromDatabase() async {
    if (!mounted) return;

    try {
      // Jika fitur Hapus Otomatis aktif, bersihkan tugas selesai yang sudah berusia >30 hari
      final prefs = await SharedPreferences.getInstance();
      final isAutoDelete = prefs.getBool('auto_delete_completed') ?? false;
      if (isAutoDelete) {
        await _databaseHelper.deleteCompletedTasksOlderThanDays(30);
      }

      final loadedTasks = await _databaseHelper.getAllTasks();

      if (!mounted) return;

      // Hitung AI recommendation & smart suggestions SEBELUM setState pertama
      final recommendation = await _aiService.generateStudyRecommendation(loadedTasks);
      List<String> suggestions = [];
      if (recommendation.urgentTaskCount > 0) {
        suggestions.add(
          '${recommendation.urgentTaskCount} tugas urgent! ${recommendation.actionItems.isNotEmpty ? recommendation.actionItems.first : "Fokus pada deadline terdekat"}',
        );
      }
      if (recommendation.recommendedStudyHours > 0) {
        final hoursStr = recommendation.recommendedStudyHours.toStringAsFixed(1).replaceAll('.0', '');
        suggestions.add(
          'Target belajar hari ini: $hoursStr jam. ${recommendation.motivationalMessage.isNotEmpty ? recommendation.motivationalMessage : "Gunakan teknik Pomodoro"}',
        );
      }
      final pendingCount = loadedTasks.where((t) => t.status == 'pending').length;
      if (suggestions.isEmpty) {
        if (pendingCount > 0) {
          suggestions.add('Kamu punya $pendingCount tugas aktif. Atur skala prioritas dengan metode SAW!');
        } else {
          suggestions.add('Semua target tercapai! Nikmati waktu luang Anda!');
        }
      }

      // HANYA SATU KALI setState() — Semua data tugas, saran AI, dan status sudah 100% lengkap!
      setState(() {
        tasks = loadedTasks;
        _smartSuggestions = suggestions;
        _recommendation = recommendation;
      });

      debugPrint('✅ Berhasil memuat ${tasks.length} tugas dari database (1-Pass Render)');
    } catch (e) {
      debugPrint('❌ Error memuat tugas: $e');
    } finally {
      // Hilangkan native splash screen dengan mulus HANYA SETELAH UI siap & data masuk
      import_splash.FlutterNativeSplash.remove();
    }
  }

  // 🎯 PERBAIKAN: Schedule notifikasi dengan delay dan debug yang lebih baik
  Future<void> _scheduleAllTaskNotifications() async {
    try {
      debugPrint('📅 Mulai sinkronisasi jadwal notifikasi (Total)...');

      // RE-SCHEDULE SEMUA (Tugas + Pengingat Harian) agar sinkron
      await _notificationService.reScheduleAllNotifications();

      debugPrint('✅ Sinkronisasi total jadwal notifikasi selesai');
    } catch (e) {
      debugPrint('❌ Error menjadwalkan notifikasi tugas: $e');
    }
  }

  // 🤖 ANALISIS AI AWAL
  Future<void> _runInitialAnalysis() async {
    try {
      if (tasks.isNotEmpty) {
        await _notificationService.sendDailySummary(tasks);
      }
    } catch (e) {
      debugPrint('❌ Error menjalankan analisis awal: $e');
    }
  }





  // FIXED: _handleTaskComplete
  Future<void> _handleTaskComplete(int taskId) async {
    try {
      await _databaseHelper.markTaskCompleted(taskId);

      await _notificationService.showNotification(
        id: 'task_completed_$taskId'.hashCode,
        title: '🎉 Tugas Beres!',
        body: 'Keren banget! Lo udah selesaiin tugasnya!',
      );

      await _loadTasksFromDatabase();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Tugas beres! Mantap bro!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Error menyelesaikan tugas: $e');

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Waduh error nih: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      });
    }
  }

  // FIXED: _handleTaskDelete
  Future<void> _handleTaskDelete(int taskId) async {
    try {
      await _databaseHelper.deleteTask(taskId);
      await _loadTasksFromDatabase();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Udah diapus deh'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Error hapus tugas: $e');

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal apus nih: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      });
    }
  }

  // FIXED: _handleTaskEdit
  Future<void> _handleTaskEdit(Task task) async {
    try {
      if (!mounted) return;

      final BuildContext currentContext = context;

      await Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder:
              (context) => AddTaskScreen(
                task: task,
                onTaskAdded: (updatedTask) async {
                  await _databaseHelper.updateTask(updatedTask);
                  await _notificationService.cancelTaskNotifications(task.id!);
                  await _notificationService.scheduleTaskNotifications(
                    updatedTask,
                  );
                  await _loadTasksFromDatabase();
                },
              ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error edit tugas: $e');
    }
  }

  // 🚀 PERBAIKAN UTAMA: _addNewTask - FIXED
  Future<void> _addNewTask(Task newTask) async {
    try {
      final taskId = await _databaseHelper.insertTask(newTask);

      debugPrint('📝 Tugas baru dimasukkan dengan ID: $taskId');

      final taskWithId = Task(
        id: taskId,
        title: newTask.title,
        description: newTask.description,
        deadline: newTask.deadline,
        category: newTask.category,
        priority: newTask.priority,
        status: newTask.status,
        createdAt: newTask.createdAt,
      );

      // Schedule notifikasi
      debugPrint('📅 Menjadwalkan notifikasi untuk tugas baru...');
      await _notificationService.scheduleTaskNotifications(taskWithId);

      // Send immediate notification untuk konfirmasi - FIXED
      await _notificationService.showNotification(
        id: 'task_added_$taskId'.hashCode,
        title: '✅ Tugas Baru Ditambahkan!',
        body:
            '${newTask.title} - Deadline: ${_formatDeadline(newTask.deadline)}',
      );

      debugPrint('🔔 Notifikasi dijadwalkan untuk tugas ID: $taskId');

      // Reload data
      await _loadTasksFromDatabase();
      await _notificationService.syncNotificationsWithDatabase();

      debugPrint('✅ Tugas baru berhasil ditambah dengan notifikasi');

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Tugas berhasil ditambahkan!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Error menambahkan tugas: $e');

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gak bisa tambahin tugas: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      });
    }
  }

  String _formatDeadline(DateTime deadline) {
    return DateTimeHelper.formatRemainingTime(deadline, DateTime.now());
  }

  // FIXED: _sendMotivationalNotification
  Future<void> _sendMotivationalNotification() async {
    try {
      // Gunakan AI service untuk motivational notification
      await _aiService.sendMotivationalNotification(tasks);

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💪 Notif motivasi udah meluncur!'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Error kirim notif motivasi: $e');
    }
  }

  // FIXED: _testNotifications - Langsung muncul suara default sistem
  Future<void> _testNotifications() async {
    try {
      await _notificationService.sendTestNotification();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🧪 Tes notif sukses (Suara Default)!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Error kirim tes notifikasi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    
    final pendingTasks =
        tasks.where((task) => task.status == 'pending').toList();

    return Scaffold(
      key: const ValueKey('home'),
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _selectedIndex == 0
              ? _buildHomeTab(pendingTasks)
              : CalendarScreen(
                  tasks: tasks,
                  onTaskComplete: _handleTaskComplete,
                  onTaskDelete: _handleTaskDelete,
                  onTaskEdit: _handleTaskEdit,
                ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF384256), Color(0xFF5E6D8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Kalender',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(List<Task> pendingTasks) {
    return RefreshIndicator(
      onRefresh: _loadTasksFromDatabase,
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        slivers: [
          // App Bar
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
              'Reminder AI',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: AppResponsive.font3xl,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () async {
                  if (!mounted) return;
                  final BuildContext currentContext = context;
                  await Navigator.push(
                    currentContext,
                    MaterialPageRoute(
                      builder: (context) => settings.SettingsScreen(),
                    ),
                  );
                  if (!mounted) return;
                  await _loadTasksFromDatabase();
                },
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: AppResponsive.iconMd,
                ),
                tooltip: 'Pengaturan',
              ),
              IconButton(
                onPressed: _testNotifications,
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.white,
                  size: AppResponsive.iconMd,
                ),
                tooltip: 'Tes Notifikasi',
              ),
            ],
          ),

          // 🚀 ORIGINAL VIEWPORT-FILLING EVENLY-SPACED LAYOUT (NO JUMPING)
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final double screenHeight = MediaQuery.of(context).size.height;
                final double statusBarHeight = MediaQuery.of(context).padding.top;
                final double appBarHeight = kToolbarHeight; // 56.0
                final double bottomPadding = MediaQuery.of(context).padding.bottom;
                final double bottomNavigationBarHeight = 56.0 + bottomPadding;
                
                final double availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomNavigationBarHeight;
                final double finalMinHeight = availableHeight > 500.0 ? availableHeight : 500.0;

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: finalMinHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppResponsive.h(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. Smart Suggestions Panel (Always visible at Card 1)
                      _buildSmartSuggestionsPanel(),
                      
                      // 2. AI + SAW Cards side by side
                      _buildAISAWRow(),
                      
                      // 3. Stats Section
                      _buildStatsSection(pendingTasks),
                      
                      // 4. Quick Actions Row (Lihat Kalender & Laporan Harian)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: AppResponsive.pagePaddingH,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.04),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppResponsive.w(12),
                                    vertical: AppResponsive.h(16),
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppTheme.primaryColor,
                                      size: AppResponsive.iconSm,
                                    ),
                                    SizedBox(width: AppResponsive.w(6)),
                                    Flexible(
                                      child: Text(
                                        'Lihat Kalender',
                                        style: GoogleFonts.outfit(
                                          fontSize: AppResponsive.fontSm,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: AppResponsive.w(12)),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _notificationService.sendDailySummary(tasks);

                                  if (!mounted) return;

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '📊 Laporan harian udah dikirim!',
                                            style: GoogleFonts.outfit(
                                              fontSize: AppResponsive.fontBase,
                                            ),
                                          ),
                                          backgroundColor: AppTheme.primaryColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppResponsive.radiusMd,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.04),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppResponsive.w(12),
                                    vertical: AppResponsive.h(16),
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.summarize_rounded,
                                      color: AppTheme.primaryColor,
                                      size: AppResponsive.iconSm,
                                    ),
                                    SizedBox(width: AppResponsive.w(6)),
                                    Flexible(
                                      child: Text(
                                        'Laporan Harian',
                                        style: GoogleFonts.outfit(
                                          fontSize: AppResponsive.fontSm,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 5. Centered wide "+ Bikin Tugas" Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.w(40),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!mounted) return;
                            final BuildContext currentContext = context;
                            await Navigator.push(
                              currentContext,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(onTaskAdded: _addNewTask),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                            padding: EdgeInsets.symmetric(
                              vertical: AppResponsive.h(18),
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+ Bikin Tugas',
                                style: GoogleFonts.outfit(
                                  fontSize: AppResponsive.fontLg,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

          // 7. Tasks List Header (now placed below the fold)
          SliverToBoxAdapter(
            child: Padding(
              padding: AppResponsive.fromLTRB(20, 24, 20, 12),
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
                  Text(
                    'Tugas Terbaru',
                    style: GoogleFonts.outfit(
                      fontSize: AppResponsive.fontXl,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tasks List
          pendingTasks.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyTasksState())
              : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = pendingTasks[index];
                  return TaskCard(
                    task: task,
                    onComplete: () => _handleTaskComplete(task.id!),
                    onDelete: () => _handleTaskDelete(task.id!),
                    onEdit: () => _handleTaskEdit(task),
                  );
                }, childCount: pendingTasks.length),
              ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // AI + SAW side by side row — equal height via IntrinsicHeight, no icons
  Widget _buildAISAWRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.pagePaddingH,
        vertical: AppResponsive.h(6),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Prioritas Tugas Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SAWPriorityScreen(tasks: tasks),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(14),
                    vertical: AppResponsive.h(16),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBA66F), Color(0xFFE5C890)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDBA66F).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prioritas Tugas',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4A321A),
                          fontSize: AppResponsive.fontBase,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(6)),
                      Text(
                        'Urutan tugas berdasarkan kepentingan',
                        style: TextStyle(
                          color: const Color(0xFF4A321A).withOpacity(0.75),
                          fontSize: AppResponsive.fontSm,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(12)),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A321A).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Buka',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF4A321A),
                              fontSize: AppResponsive.fontXs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: AppResponsive.w(12)),
            // AI Recommendation Button
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AIRecommendationScreen(tasks: tasks),
                    ),
                  );
                  await _loadTasksFromDatabase();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(14),
                    vertical: AppResponsive.h(16),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7785A3), Color(0xFF56627A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7785A3).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Asisten Belajar AI',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: AppResponsive.fontBase,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(6)),
                      Text(
                        'Saran jadwal belajar personal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: AppResponsive.fontSm,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(12)),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Buka',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: AppResponsive.fontXs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<Task> pendingTasks) {
    final urgentCount = _recommendation?.urgentTaskCount ?? _calculateUrgentTasks(tasks);
    final notificationCount = _calculateNotificationTasks(tasks);
    final completedCount = tasks.where((t) => t.status == 'completed').length;
    final todayTasksCount = pendingTasks.where((t) => t.isToday).length;

    return Container(
      margin: AppResponsive.fromLTRB(16, 2, 16, 12),
      padding: EdgeInsets.fromLTRB(
        AppResponsive.w(16),
        AppResponsive.h(12),
        AppResponsive.w(16),
        AppResponsive.h(12),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius3xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: AppResponsive.w(20),
            offset: Offset(0, AppResponsive.h(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang!',
            style: GoogleFonts.outfit(
              fontSize: AppResponsive.font3xl,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppResponsive.h(2)),
          Text(
            todayTasksCount > 0
                ? 'Ada $todayTasksCount tugas yang perlu Kamu cek hari ini.'
                : 'Tidak ada tugas yang perlu Kamu cek hari ini.',
            style: GoogleFonts.outfit(
              fontSize: AppResponsive.fontMd,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppResponsive.h(8)),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      'Total Tugas',
                      '${pendingTasks.length}',
                      Icons.assignment_rounded,
                      AppTheme.primaryColor,
                      () => _showTotalTasksDetails(pendingTasks),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(10)),
                  Expanded(
                    child: _buildModernStatCard(
                      'Urgent',
                      '$urgentCount',
                      Icons.bolt_rounded,
                      AppTheme.warningColor,
                      () => _showUrgentTasksDetails(pendingTasks),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.h(8)),
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      'Notifikasi',
                      '$notificationCount',
                      Icons.notifications_active_rounded,
                      AppTheme.secondaryColor,
                      () => _showNotificationTasksDetails(pendingTasks),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(10)),
                  Expanded(
                    child: _buildModernStatCard(
                      'Selesai',
                      '$completedCount',
                      Icons.check_circle_rounded,
                      AppTheme.successColor,
                      () => _showCompletedTasksDetails(tasks),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(10),
            vertical: AppResponsive.h(6),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: AppResponsive.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppResponsive.iconSm,
                ),
              ),
              SizedBox(width: AppResponsive.w(8)),
              // Texts (Value & Title)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: GoogleFonts.outfit(
                          fontSize: AppResponsive.font2xl,
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: AppResponsive.fontXs,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartSuggestionsPanel() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.pagePaddingH,
        vertical: AppResponsive.h(6),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: AppResponsive.w(16),
            offset: Offset(0, AppResponsive.h(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppResponsive.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: AppResponsive.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_fix_high_rounded,
                    color: AppTheme.primaryColor,
                    size: AppResponsive.iconSm,
                  ),
                ),
                SizedBox(width: AppResponsive.w(10)),
                Text(
                  'Saran Cerdas AI',
                  style: GoogleFonts.outfit(
                    fontSize: AppResponsive.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _smartSuggestions.length,
            padding: EdgeInsets.only(bottom: AppResponsive.h(12)),
            itemBuilder: (context, index) {
              final suggestion = _smartSuggestions[index];
              return Padding(
                padding: AppResponsive.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: AppResponsive.h(4)),
                      child: Container(
                        width: AppResponsive.w(6),
                        height: AppResponsive.h(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: AppResponsive.w(12)),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: GoogleFonts.outfit(
                          fontSize: AppResponsive.fontMd,
                          color: AppTheme.textPrimary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Container(
      margin: AppResponsive.all(16),
      padding: AppResponsive.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: AppResponsive.all(14),
            decoration: BoxDecoration(
              color: colorWithOpacity(AppTheme.primaryColor, 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              size: AppResponsive.iconXl * 1.3,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: AppResponsive.gapXxl),
          Text(
            'Wih, semua tugas udah beres! 🎉',
            style: TextStyle(
              fontSize: AppResponsive.font2xl,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppResponsive.gapMd),
          Text(
            'Kamu bisa tambahin tugas baru atau chillax dulu deh.',
            style: TextStyle(
              fontSize: AppResponsive.fontBase,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
