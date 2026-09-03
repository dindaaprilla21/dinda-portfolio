import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/task_model.dart';
import '../database/database_helper.dart';
import '../services/rule_engine.dart'; // Import RuleEngine

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _permissionsGranted = false;

  // Getters for status
  bool get isInitialized => _isInitialized;
  bool get permissionsGranted => _permissionsGranted;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone dengan zona Indonesia
      tz.initializeTimeZones();

      // PERBAIKAN: Set timezone Indonesia dengan benar
      try {
        final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
        debugPrint('✅ Timezone otomatis diatur ke: $currentTimeZone');
      } catch (e) {
        debugPrint('⚠️ Gagal deteksi timezone otomatis, pakai Jakarta: $e');
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        } catch (e2) {
          tz.setLocalLocation(tz.local);
        }
      }

      // Create notification channel for Android
      await _createNotificationChannel();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('✅ Notif udah siap banget!');
    } catch (e) {
      debugPrint('❌ Waduh notif error: $e');
      _isInitialized = false;
    }
  }

  // Create notification channel (CRITICAL for Android 8.0+)
  Future<void> _createNotificationChannel() async {
    try {
      final AndroidNotificationChannel urgentChannel =
          AndroidNotificationChannel(
            'urgent_reminders_v3',
            'Notif Urgent Banget',
            description: 'Buat deadline yang super penting',
            importance: Importance.max,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            enableLights: true,
            ledColor: const Color.fromARGB(255, 255, 0, 0),
            sound: RawResourceAndroidNotificationSound('bel_darurat'),
          );

      const AndroidNotificationChannel normalChannel =
          AndroidNotificationChannel(
            'task_reminders',
            'Pengingat Tugas',
            description: 'Notif tugas biasa aja',
            importance: Importance.high,
            enableVibration: true,
          );

      const AndroidNotificationChannel aiChannel = AndroidNotificationChannel(
        'ai_recommendations',
        'Tips AI Kece',
        description: 'Saran belajar dari AI yang cerdas',
        importance: Importance.high, // Diubah agar muncul banner
      );

      // PERBAIKAN: Tambah channel untuk daily reminder
      const AndroidNotificationChannel dailyChannel =
          AndroidNotificationChannel(
            'daily_reminders_v3',
            'Pengingat Harian',
            description: 'Pengingat harian untuk cek tugas',
            importance: Importance.high,
            enableVibration: true,
            sound: RawResourceAndroidNotificationSound('bel_darurat'),
          );

      // PERBAIKAN: Tambah channel untuk aturan berbasis rule engine
      const AndroidNotificationChannel ruleChannel = AndroidNotificationChannel(
        'rule_reminders',
        'Pengingat Aturan',
        description: 'Notifikasi berdasarkan aturan sistem',
        importance: Importance.high,
        enableVibration: true,
      );

      final plugin =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (plugin != null) {
        await plugin.createNotificationChannel(urgentChannel);
        await plugin.createNotificationChannel(normalChannel);
        await plugin.createNotificationChannel(aiChannel);
        await plugin.createNotificationChannel(dailyChannel);
        await plugin.createNotificationChannel(ruleChannel);

        // Channel baru v15 untuk bypass cache sistem Samsung
        await plugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'task_reminders_v16',
            'Pengingat Tugas Utama',
            description: 'Channel prioritas tinggi untuk tugas',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
        debugPrint('✅ Channel notif v16 (Samsung Fix) sudah didaftarkan!');
      }
    } catch (e) {
      debugPrint('❌ Gagal bikin channel notif: $e');
    }
  }

  // Request permissions dengan handling yang lebih baik
  Future<bool> requestPermissions({BuildContext? context}) async {
    if (!_isInitialized) await initialize();

    try {
      // Check if already granted
      bool alreadyGranted = await checkPermissions();
      if (alreadyGranted) {
        _permissionsGranted = true;
        return true;
      }

      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidInfo();

        if (androidInfo >= 33) {
          final granted =
              await _flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.requestNotificationsPermission();
          _permissionsGranted = granted ?? false;
        } else {
          _permissionsGranted = true;
        }

        // Request exact alarm permission for Android 12+
        if (androidInfo >= 31) {
          try {
            final alarmStatus = await Permission.scheduleExactAlarm.status;
            if (!alarmStatus.isGranted) {
              await Permission.scheduleExactAlarm.request();
            }
            debugPrint('✅ Exact alarm permission: ${alarmStatus.isGranted}');
          } catch (e) {
            debugPrint('⚠️ Exact alarm permission gak bisa: $e');
          }
        }

        // 🚀 CRITICAL FOR SAMSUNG/XIAOMI: Request ignore battery optimizations
        try {
          final batteryStatus =
              await Permission.ignoreBatteryOptimizations.status;
          if (!batteryStatus.isGranted) {
            debugPrint(
              '⚠️ Battery optimization is active, notifications might be delayed.',
            );
            await Permission.ignoreBatteryOptimizations.request();
          }
        } catch (e) {
          debugPrint('⚠️ Ignore battery optimization request failed: $e');
        }

        // 🔗 AUTO-START PERMISSION (Informative)
        debugPrint(
          '💡 Tip: For brands like Xiaomi/Oppo, please enable "Auto-start" in app settings.',
        );
      }

      if (Platform.isIOS) {
        final granted = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        _permissionsGranted = granted ?? false;
      }

      debugPrint('🔔 Permission notif: $_permissionsGranted');
      return _permissionsGranted;
    } catch (e) {
      debugPrint('❌ Error minta permission: $e');
      return false;
    }
  }

  Future<bool> checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidInfo();
        if (androidInfo >= 33) {
          final granted =
              await _flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.areNotificationsEnabled();
          _permissionsGranted = granted ?? false;
        } else {
          _permissionsGranted = true;
        }
      }

      if (Platform.isIOS) {
        final granted =
            await _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.checkPermissions();
        _permissionsGranted = granted?.isEnabled ?? false;
      }

      return _permissionsGranted;
    } catch (e) {
      debugPrint('❌ Error cek permission: $e');
      return false;
    }
  }

  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.notifications, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Nyalain Notif Yuk!'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biar gak lupa tugas dan deadline!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Nanti Deh'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Oke Gas!'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<int> _getAndroidInfo() async {
    // Di Android, SDK 33 = Android 13, 34 = Android 14
    if (Platform.isAndroid) {
      // Kita asumsikan minimal 33 jika tidak yakin,
      // tapi idealnya memakai info akurat.
      // Kita kembalikan 34 untuk amannya agar permission logic jalan.
      return 34;
    }
    return 0;
  }

  // 🛠️ DIAGNOSIS: Buka pengaturan sistem untuk optimasi baterai dan alarm
  Future<void> openBatteryOptimizationSettings() async {
    try {
      await Permission.ignoreBatteryOptimizations.request();
      debugPrint('🔧 Meminta akses ignore battery optimization');
    } catch (e) {
      debugPrint('❌ Gagal buka setting baterai: $e');
    }
  }

  Future<void> openExactAlarmSettings() async {
    try {
      await Permission.scheduleExactAlarm.request();
      debugPrint('🔧 Meminta akses schedule exact alarm');
    } catch (e) {
      debugPrint('❌ Gagal buka setting alarm: $e');
    }
  }

  Future<void> requestOverlayPermission() async {
    try {
      if (Platform.isAndroid) {
        await Permission.systemAlertWindow.request();
        debugPrint('🔧 Meminta akses Appear on Top');
      }
    } catch (e) {
      debugPrint('❌ Gagal minta izin overlay: $e');
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('❌ Gagal buka setting app: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notif di-tap: ${response.payload}');
  }

  // 🆕 PERBAIKAN UTAMA: Schedule daily reminder
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_isInitialized) await initialize();

    if (!_permissionsGranted) {
      _permissionsGranted = await checkPermissions();
      if (!_permissionsGranted) {
        debugPrint('❌ Permission belum dikasih, gak bisa bikin daily reminder');
        return;
      }
    }

    try {
      // Cancel daily reminder yang lama dulu
      await _flutterLocalNotificationsPlugin.cancel(
        999999,
      ); // ID khusus untuk daily reminder

      final scheduledDate = _nextInstanceOfTime(time);

      // Load SharedPreferences for custom daily reminder ringtone
      final prefs = await SharedPreferences.getInstance();
      final ringtone = prefs.getString('daily_reminder_ringtone') ?? 'default';

      debugPrint('📅 SCHEDULING DAILY REMINDER:');
      debugPrint('📅 Waktu: ${time.hour}:${time.minute}');
      debugPrint('📅 Next occurrence: $scheduledDate');
      debugPrint('📅 Ringtone: $ringtone');

      final channelId = 'daily_v20_$ringtone';

      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (plugin != null) {
        try {
          await plugin.createNotificationChannel(
            AndroidNotificationChannel(
              channelId,
              'Pengingat Harian',
              description: 'Pengingat harian untuk cek tugas',
              importance: Importance.max,
              playSound: true,
              sound: ringtone == 'default'
                  ? null
                  : RawResourceAndroidNotificationSound(ringtone),
              enableVibration: true,
              enableLights: true,
              audioAttributesUsage: AudioAttributesUsage.notification,
            ),
          );
        } catch (e) {
          debugPrint('❌ Gagal membuat channel daily reminder: $e');
        }
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // ID khusus untuk daily reminder
        '🔔 Pengingat Harian',
        'Jangan lupa cek tugas kamu hari ini! Ada yang perlu dikerjakan?',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Pengingat Harian',
            channelDescription: 'Pengingat harian untuk cek tugas',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
            sound:
                ringtone == 'default'
                    ? null
                    : RawResourceAndroidNotificationSound(ringtone),
            icon: '@mipmap/ic_launcher',
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
            audioAttributesUsage: AudioAttributesUsage.notification,
            autoCancel: false,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
        '✅ Daily reminder berhasil dijadwalkan untuk ${time.hour}:${time.minute} dengan sound $ringtone',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling daily reminder: $e');
    }
  }

  // Helper untuk menghitung waktu berikutnya
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // 🆕 Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(
        999999,
      ); // ID khusus untuk daily reminder
      debugPrint('🗑️ Daily reminder sudah dibatalkan');
    } catch (e) {
      debugPrint('❌ Error cancel daily reminder: $e');
    }
  }

  // 🎯 PERBAIKAN UTAMA: Schedule notifications dengan debugging
  Future<void> scheduleTaskNotifications(Task task) async {
    if (!_isInitialized) await initialize();

    if (!_permissionsGranted) {
      _permissionsGranted = await checkPermissions();
      if (!_permissionsGranted) {
        debugPrint('❌ Permission belum dikasih, gak bisa bikin notif');
        return;
      }
    }

    try {
      final now = DateTime.now();
      final deadline = task.deadline;

      debugPrint('📅 SCHEDULING UNTUK TUGAS: ${task.title}');
      debugPrint('📅 Task ID: ${task.id}');
      debugPrint('📅 Deadline: $deadline');
      debugPrint('📅 Sekarang: $now');

      // Calculate notification times
      final threeDaysBefore = deadline.subtract(const Duration(days: 3));
      final oneDayBefore = deadline.subtract(const Duration(days: 1));
      final oneHourBefore = deadline.subtract(const Duration(hours: 1));
      final thirtyMinsBefore = deadline.subtract(const Duration(minutes: 30));
      final fifteenMinsBefore = deadline.subtract(const Duration(minutes: 15));
      final fiveMinsBefore = deadline.subtract(const Duration(minutes: 5));

      int scheduledCount = 0;
      List<String> scheduledNotifications = [];

      final sound = task.notificationSchedule;

      // Schedule 3 days before
      if (threeDaysBefore.isAfter(now)) {
        final notifId = '${task.id}_3d'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '📅 H-3 Deadline Tugas',
          body: 'Tiga hari lagi batas pengumpulan tugas "${task.title}"!',
          scheduledTime: threeDaysBefore,
          channelId: 'task_reminders',
          priority: 'medium',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('3d (ID: $notifId)');
      }

      // Schedule 1 day before
      if (oneDayBefore.isAfter(now)) {
        final notifId = '${task.id}_1d'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '⏳ H-1 Deadline Tugas',
          body: 'Besok deadline nih! Udah beres belum bro?',
          scheduledTime: oneDayBefore,
          channelId: 'task_reminders',
          priority: 'high',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('1d (ID: $notifId)');
      }

      // Schedule 1 hour before
      if (oneHourBefore.isAfter(now)) {
        final notifId = '${task.id}_1h'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '⏰ Oy Deadline Nih!',
          body: 'Tinggal sejam lagi nih bro!',
          scheduledTime: oneHourBefore,
          channelId: 'task_reminders',
          priority: 'high',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('1h (ID: $notifId)');
      }

      // Schedule 30 minutes before
      if (thirtyMinsBefore.isAfter(now)) {
        final notifId = '${task.id}_30m'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '🚨 WADUH! 30 Menit Lagi!',
          body: 'Buru-buru selesaiin bro! 30 menit lagi nih!',
          scheduledTime: thirtyMinsBefore,
          channelId: 'urgent_reminders_v3',
          priority: 'critical',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('30m (ID: $notifId)');
      }

      // Schedule 15 minutes before
      if (fifteenMinsBefore.isAfter(now)) {
        final notifId = '${task.id}_15m'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '🔥 ALAMAK! 15 Menit Lagi!',
          body: 'Gas pol! 15 menit lagi nih bro!',
          scheduledTime: fifteenMinsBefore,
          channelId: 'urgent_reminders_v3',
          priority: 'critical',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('15m (ID: $notifId)');
      }

      // Schedule 5 minutes before
      if (fiveMinsBefore.isAfter(now)) {
        final notifId = '${task.id}_5m'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '🆘 AMPUUUN! 5 MENIT LAGI!',
          body: '5 menit lagi nih bro!',
          scheduledTime: fiveMinsBefore,
          channelId: 'urgent_reminders_v3',
          priority: 'critical',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('5m (ID: $notifId)');
      }

      // Schedule exact deadline for overdue notification
      if (deadline.isAfter(now)) {
        final notifId = '${task.id}_overdue'.hashCode;
        await _scheduleNotificationFixed(
          id: notifId,
          title: '❌ WAKTU HABIS: Terlambat!',
          body: 'Deadline udah lewat bro! Tetap semangat nyelesaiin!',
          scheduledTime: deadline,
          channelId: 'urgent_reminders_v3',
          priority: 'critical',
          ringtone: sound,
        );
        scheduledCount++;
        scheduledNotifications.add('overdue (ID: $notifId)');
      }

      debugPrint(
        '🎯 TOTAL DIJADWALIN: $scheduledCount notifikasi untuk ${task.title}',
      );
      debugPrint(
        '📋 Notifikasi yang dijadwalkan: ${scheduledNotifications.join(', ')}',
      );

      // NEW: Tambahkan juga notifikasi jangka panjang dari RuleEngine
      await scheduleRuleBasedNotifications(task);
    } catch (e) {
      debugPrint('❌ Error jadwalin notif tugas: $e');
    }
  }

  // 🔧 PERBAIKAN: Schedule notification dengan error handling yang lebih baik
  Future<void> _scheduleNotificationFixed({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    required String priority,
    String ringtone = 'default',
  }) async {
    try {
      // Pastikan waktu lebih dari sekarang
      final now = DateTime.now();
      if (!scheduledTime.isAfter(now)) {
        debugPrint('❌ Waktu jadwal sudah lewat: $scheduledTime');
        return;
      }

      // Convert ke TZDateTime dengan handling yang lebih robust
      tz.TZDateTime scheduledDate;
      try {
        scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
      } catch (e) {
        // Fallback: buat manual jika conversion gagal
        scheduledDate = tz.TZDateTime(
          tz.local,
          scheduledTime.year,
          scheduledTime.month,
          scheduledTime.day,
          scheduledTime.hour,
          scheduledTime.minute,
          scheduledTime.second,
          scheduledTime.millisecond,
          scheduledTime.microsecond,
        );
        debugPrint('⚠️ TZDateTime conversion fallback used');
      }

      // Double check waktu
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('❌ Scheduled date in the past, skipping');
        return;
      }

      debugPrint('📅 Scheduling notification:');
      debugPrint('   ID: $id');
      debugPrint('   Title: $title');
      debugPrint('   Time: $scheduledDate');
      debugPrint(
        '   Minutes from now: ${scheduledDate.difference(tz.TZDateTime.now(tz.local)).inMinutes}',
      );

      // Gunakan exactAllowWhileIdle secara konsisten agar notifikasi berjalan handal saat aplikasi ditutup
      const scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

      final dynamicChannelId = 'task_v20_$ringtone';

      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (plugin != null) {
        try {
          await plugin.createNotificationChannel(
            AndroidNotificationChannel(
              dynamicChannelId,
              'Pengingat Tugas',
              description: 'Channel pengingat tugas dengan nada dering $ringtone',
              importance: Importance.max,
              playSound: true,
              sound: ringtone == 'default'
                  ? null
                  : RawResourceAndroidNotificationSound(ringtone),
              enableVibration: true,
              enableLights: true,
              audioAttributesUsage: AudioAttributesUsage.notification,
            ),
          );
        } catch (e) {
          debugPrint('❌ Gagal membuat channel custom: $e');
        }
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            dynamicChannelId,
            'Pengingat Tugas',
            channelDescription: 'Notif deadline tugas',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            color: Colors.red,
            enableVibration: true,
            playSound: true,
            sound:
                ringtone == 'default'
                    ? null
                    : RawResourceAndroidNotificationSound(ringtone),
            audioAttributesUsage: AudioAttributesUsage.notification,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body),
            autoCancel: false,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            ticker: title, // Penting buat accessibility
            ongoing: false,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: null,
      );

      debugPrint('✅ Berhasil jadwalkan notif: $title (ID: $id)');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
      debugPrint('   Error type: ${e.runtimeType}');

      // Fallback: coba kirim notif immediate untuk testing
      if (e.toString().contains('Invalid argument') ||
          e.toString().contains('PlatformException')) {
        debugPrint('🔄 Trying immediate notification as fallback');
        await showNotification(
          id: id,
          title: '[FALLBACK] $title',
          body: 'Scheduled notification failed, sent immediately: $body',
          priority: priority,
          channelId: channelId,
          ringtone: ringtone,
        );
      }
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String priority = 'medium',
    String channelId = 'task_reminders',
    String ringtone = 'default',
  }) async {
    if (!_isInitialized) await initialize();
    if (!_permissionsGranted) {
      debugPrint('❌ Notif belum diizinin, skip deh');
      return;
    }

    try {
      final dynamicChannelId = 'task_v20_$ringtone';

      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (plugin != null) {
        try {
          await plugin.createNotificationChannel(
            AndroidNotificationChannel(
              dynamicChannelId,
              'Pengingat Tugas',
              description: 'Notif deadline tugas dengan suara $ringtone',
              importance: Importance.max,
              playSound: true,
              sound: ringtone == 'default'
                  ? null
                  : RawResourceAndroidNotificationSound(ringtone),
              enableVibration: true,
              ledColor: _getNotificationColor(priority) ?? Colors.blue,
              audioAttributesUsage: AudioAttributesUsage.notification,
            ),
          );
        } catch (e) {
          debugPrint('❌ Gagal membuat channel custom audio: $e');
        }
      }

      final androidDetails = AndroidNotificationDetails(
        dynamicChannelId,
        'Pengingat Tugas',
        channelDescription: 'Notif pengingat tugas',
        importance: Importance.max, // Dipaksa Max untuk Samsung
        priority: Priority.max, // Dipaksa Max untuk Samsung
        color: _getNotificationColor(priority),
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.call,
        visibility: NotificationVisibility.public,
        sound:
            ringtone == 'default'
                ? null
                : RawResourceAndroidNotificationSound(ringtone),
        audioAttributesUsage: AudioAttributesUsage.notification,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
        autoCancel: false,
        ticker: title,
      );

      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint('✅ Notif udah muncul: $title');
    } catch (e) {
      debugPrint('❌ Error munculin notif: $e');
    }
  }

  // Cancel all notifications for a task
  Future<void> cancelTaskNotifications(int taskId) async {
    try {
      final notificationIds = [
        '${taskId}_3d'.hashCode,
        '${taskId}_1d'.hashCode,
        '${taskId}_1h'.hashCode,
        '${taskId}_30m'.hashCode,
        '${taskId}_15m'.hashCode,
        '${taskId}_5m'.hashCode,
        '${taskId}_overdue'.hashCode,
        // Tambahkan ID untuk notifikasi berbasis rule
        'rule_day_$taskId'.hashCode,
        'rule_hour_$taskId'.hashCode,
      ];

      for (int id in notificationIds) {
        await _flutterLocalNotificationsPlugin.cancel(id);
        debugPrint('🗑️ Cancelled notification ID: $id for task $taskId');
      }

      debugPrint('🗑️ Notif udah dibatalin buat tugas ID: $taskId');
    } catch (e) {
      debugPrint('❌ Error batalin notif: $e');
    }
  }

  // Test notification
  Future<void> sendTestNotification() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '🔥 MANTAP! Sistem Notifikasi Aktif!',
      body:
          'Bel Darurat kamu sudah siap siaga buat ngingetin tugas. Jangan sampai telat ya! 🚀',
      priority: 'high',
      ringtone: 'default',
    );
  }

  // 🧪 Tes Notifikasi dengan Delay (Berguna buat ngetes pas aplikasi ditutup)
  Future<void> sendTestNotificationDelayed() async {
    if (!_isInitialized) await initialize();

    final scheduledTime = DateTime.now().add(const Duration(seconds: 15));
    debugPrint(
      '🧪 Menjadwalkan tes notif dalam 15 detik ke depan: $scheduledTime',
    );

    await _scheduleNotificationFixed(
      id: 888888,
      title: '🧪 Tes Background BERHASIL!',
      body:
          'Mantap! Notif ini muncul pake suara DARURAT pas aplikasi ditutup. 🔔',
      scheduledTime: scheduledTime,
      channelId: 'task_reminders_v16_urgent',
      priority: 'critical',
      ringtone: 'bel_darurat',
    );
  }

  // AI Recommendation notification
  Future<void> sendAIRecommendation(String message) async {
    await showNotification(
      id: 'ai_rec_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title: '🤖 Tips AI Keren',
      body: message,
      priority: 'medium',
      channelId: 'ai_recommendations',
    );
  }

  Color? _getNotificationColor(String priority) {
    switch (priority) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF59E0B);
      case 'medium':
        return const Color(0xFF6366F1);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6366F1);
    }
  }

  // Daily summary
  Future<void> sendDailySummary(List<Task> tasks) async {
    final pendingTasks = tasks.where((t) => t.status == 'pending').length;
    final todayTasks =
        tasks
            .where(
              (t) =>
                  t.deadline.day == DateTime.now().day &&
                  t.deadline.month == DateTime.now().month &&
                  t.deadline.year == DateTime.now().year &&
                  t.status == 'pending',
            )
            .length;

    await showNotification(
      id: 'daily_summary_${DateTime.now().day}'.hashCode,
      title:
          '📊 Laporan Harian - ${DateTime.now().day}/${DateTime.now().month}',
      body:
          'Kamu punya $pendingTasks tugas aktif. $todayTasks deadline hari ini. Semangat!',
      priority: 'medium',
      channelId: 'task_reminders',
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('🗑️ Semua notif udah dibatalin');
    } catch (e) {
      debugPrint('❌ Error batalin semua notif: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('📋 Total pending notifications: ${pending.length}');

      // Debug: Log semua pending notifications
      for (var notif in pending) {
        debugPrint('   📎 Notification ID: ${notif.id}, Title: ${notif.title}');
      }

      return pending;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  // Send motivational notification
  Future<void> sendMotivationalNotification(String message) async {
    await showNotification(
      id: 'motivation_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title: '💪 Semangat!',
      body: message,
      priority: 'low',
      channelId: 'ai_recommendations',
    );
  }

  // Process notification rules
  Future<void> processNotificationRules(List<dynamic> rules) async {
    for (var rule in rules) {
      try {
        await showNotification(
          id: rule.toString().hashCode,
          title: rule.toString(),
          body: 'Notif pengingat otomatis',
          priority: 'medium',
        );
      } catch (e) {
        debugPrint('❌ Error process notification rule: $e');
      }
    }
  }

  // Sync notifikasi dengan database
  Future<void> syncNotificationsWithDatabase() async {
    try {
      final db = DatabaseHelper();

      // Get all pending notifications
      final pendingNotifications = await getPendingNotifications();

      // Get all active tasks from database
      final activeTasks = await db.getTasksByStatus('pending');

      // Hitung semua ID notifikasi yang valid untuk tugas-tugas aktif
      final Set<int> validNotificationIds = {};
      for (var task in activeTasks) {
        if (task.id != null) {
          final taskId = task.id!;
          validNotificationIds.addAll([
            '${taskId}_3d'.hashCode,
            '${taskId}_1d'.hashCode,
            '${taskId}_1h'.hashCode,
            '${taskId}_30m'.hashCode,
            '${taskId}_15m'.hashCode,
            '${taskId}_5m'.hashCode,
            '${taskId}_overdue'.hashCode,
            'rule_day_$taskId'.hashCode,
            'rule_hour_$taskId'.hashCode,
          ]);
        }
      }

      debugPrint('🔄 Syncing notifications...');
      debugPrint('📱 Pending notifications: ${pendingNotifications.length}');
      debugPrint('📋 Active tasks: ${activeTasks.length}');

      int cancelledCount = 0;

      // Cancel notifications for tasks that no longer exist or are completed
      for (var notification in pendingNotifications) {
        // Skip daily reminder (ID 999999)
        if (notification.id == 999999) {
          debugPrint('   ✅ Daily reminder found (ID: 999999) - keeping');
          continue;
        }

        // Skip recurring reminders
        if (notification.id == 'recurring_morning'.hashCode ||
            notification.id == 'recurring_evening'.hashCode ||
            notification.id == 'recurring_weekly'.hashCode ||
            notification.id.toString().contains('recurring_')) {
          debugPrint(
            '   ✅ Recurring reminder found (ID: ${notification.id}) - keeping',
          );
          continue;
        }

        if (validNotificationIds.contains(notification.id)) {
          debugPrint('   ✅ Valid notification ID ${notification.id} - keeping');
        } else {
          await _flutterLocalNotificationsPlugin.cancel(notification.id);
          cancelledCount++;
          debugPrint(
            '   🗑️ Cancelled orphaned/invalid notification: ${notification.id} (${notification.title})',
          );
        }
      }

      debugPrint(
        '✅ Notification sync completed. Cancelled $cancelledCount orphaned notifications',
      );
    } catch (e) {
      debugPrint('❌ Error syncing notifications: $e');
    }
  }

  // 🚀 PERBAIKAN UTAMA: Get jumlah notifikasi yang valid dengan debug lebih detail
  Future<int> getValidPendingNotificationCount() async {
    try {
      debugPrint('📊 === STARTING NOTIFICATION COUNT DEBUG ===');

      final db = DatabaseHelper();
      final pendingNotifications = await getPendingNotifications();
      final activeTasks = await db.getTasksByStatus('pending');

      final Map<int, Task> idToTaskMap = {};
      final Map<int, String> idToTypeMap = {};

      for (var task in activeTasks) {
        if (task.id != null) {
          final taskId = task.id!;
          final Map<int, String> taskNotifs = {
            '${taskId}_3d'.hashCode: '3d before',
            '${taskId}_1d'.hashCode: '1d before',
            '${taskId}_1h'.hashCode: '1h before',
            '${taskId}_30m'.hashCode: '30m before',
            '${taskId}_15m'.hashCode: '15m before',
            '${taskId}_5m'.hashCode: '5m before',
            '${taskId}_overdue'.hashCode: 'overdue',
            'rule_day_$taskId'.hashCode: 'rule_day',
            'rule_hour_$taskId'.hashCode: 'rule_hour',
          };

          taskNotifs.forEach((id, type) {
            idToTaskMap[id] = task;
            idToTypeMap[id] = type;
          });
        }
      }

      debugPrint(
        '📱 Total pending notifications: ${pendingNotifications.length}',
      );
      debugPrint('📋 Active tasks: ${activeTasks.length}');

      int validCount = 0;
      List<String> validNotifications = [];
      List<String> invalidNotifications = [];

      for (var notification in pendingNotifications) {
        // Daily reminder selalu valid
        if (notification.id == 999999) {
          validCount++;
          validNotifications.add('Daily Reminder (ID: 999999)');
          debugPrint('   ✅ Daily reminder is valid');
          continue;
        }

        // Recurring reminders selalu valid
        if (notification.id == 'recurring_morning'.hashCode ||
            notification.id == 'recurring_evening'.hashCode ||
            notification.id == 'recurring_weekly'.hashCode ||
            notification.id.toString().contains('recurring_')) {
          validCount++;
          validNotifications.add('Recurring Reminder (ID: ${notification.id})');
          debugPrint('   ✅ Recurring reminder is valid');
          continue;
        }

        // Check if notification belongs to active task
        if (idToTaskMap.containsKey(notification.id)) {
          validCount++;
          final task = idToTaskMap[notification.id]!;
          final notifType = idToTypeMap[notification.id]!;
          validNotifications.add(
            'Task ${task.id} (${task.title}) - $notifType (ID: ${notification.id})',
          );
          debugPrint(
            '   ✅ Valid notification for task ${task.id}: $notifType (ID: ${notification.id})',
          );
        } else {
          invalidNotifications.add(
            'ID: ${notification.id} - ${notification.title}',
          );
          debugPrint(
            '   ❌ Invalid notification: ID ${notification.id} - ${notification.title}',
          );
        }
      }

      debugPrint('📊 === NOTIFICATION COUNT SUMMARY ===');
      debugPrint('✅ Valid notifications: $validCount');
      debugPrint('   ${validNotifications.join('\n   ')}');
      debugPrint('❌ Invalid notifications: ${invalidNotifications.length}');
      if (invalidNotifications.isNotEmpty) {
        debugPrint('   ${invalidNotifications.join('\n   ')}');
      }
      debugPrint('📊 === END NOTIFICATION COUNT DEBUG ===');

      return validCount;
    } catch (e) {
      debugPrint('❌ Error getting valid notification count: $e');
      return 0;
    }
  }

  // Debug info untuk notifikasi
  Future<Map<String, dynamic>> getNotificationDebugInfo() async {
    try {
      final db = DatabaseHelper();
      final pendingNotifications = await getPendingNotifications();
      final activeTasks = await db.getTasksByStatus('pending');

      final Map<int, Task> idToTaskMap = {};
      final Map<int, String> idToTypeMap = {};

      for (var task in activeTasks) {
        if (task.id != null) {
          final taskId = task.id!;
          final Map<int, String> taskNotifs = {
            '${taskId}_3d'.hashCode: '3d before',
            '${taskId}_1d'.hashCode: '1d before',
            '${taskId}_1h'.hashCode: '1h before',
            '${taskId}_30m'.hashCode: '30m before',
            '${taskId}_15m'.hashCode: '15m before',
            '${taskId}_5m'.hashCode: '5m before',
            '${taskId}_overdue'.hashCode: 'overdue',
            'rule_day_$taskId'.hashCode: 'rule_day',
            'rule_hour_$taskId'.hashCode: 'rule_hour',
          };

          taskNotifs.forEach((id, type) {
            idToTaskMap[id] = task;
            idToTypeMap[id] = type;
          });
        }
      }

      // Group notifications by task
      Map<String, List<int>> notificationsByTask = {};
      List<int> orphanedNotifications = [];
      bool hasDailyReminder = false;
      int ruleBasedCount = 0;

      for (var notification in pendingNotifications) {
        // Check for daily reminder
        if (notification.id == 999999) {
          hasDailyReminder = true;
          continue;
        }

        // Check for recurring reminders
        if (notification.id == 'recurring_morning'.hashCode ||
            notification.id == 'recurring_evening'.hashCode ||
            notification.id == 'recurring_weekly'.hashCode) {
          continue;
        }

        if (idToTaskMap.containsKey(notification.id)) {
          final task = idToTaskMap[notification.id]!;
          final type = idToTypeMap[notification.id]!;
          notificationsByTask.putIfAbsent(task.title, () => []);
          notificationsByTask[task.title]!.add(notification.id);
          if (type.contains('rule_')) {
            ruleBasedCount++;
          }
        } else {
          orphanedNotifications.add(notification.id);
        }
      }

      return {
        'totalPending': pendingNotifications.length,
        'activeTasks': activeTasks.length,
        'validNotifications':
            pendingNotifications.length - orphanedNotifications.length,
        'orphanedNotifications': orphanedNotifications.length,
        'hasDailyReminder': hasDailyReminder,
        'ruleBasedCount': ruleBasedCount,
        'notificationsByTask': notificationsByTask,
        'orphanedIds': orphanedNotifications,
      };
    } catch (e) {
      debugPrint('❌ Error getting debug info: $e');
      return {};
    }
  }

  // ====== FUNGSI BARU UNTUK INTEGRASI DENGAN RULE ENGINE ======

  // Jadwalkan notifikasi kustom dengan parameter yang fleksibel
  Future<void> scheduleCustomNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String priority = 'medium',
    String channelId = 'task_reminders',
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (!_isInitialized) await initialize();

    if (!_permissionsGranted) {
      debugPrint('❌ Permission belum dikasih, gak bisa bikin notifikasi');
      return;
    }

    try {
      final now = DateTime.now();

      // Skip jika waktu sudah lewat
      if (scheduledTime.isBefore(now)) {
        debugPrint(
          '⏭️ Waktu notifikasi sudah lewat: $scheduledTime untuk "$title"',
        );
        return;
      }

      debugPrint('📅 SCHEDULING CUSTOM NOTIFICATION:');
      debugPrint('📅 ID: $id');
      debugPrint('📅 Title: $title');
      debugPrint('📅 Waktu: $scheduledTime');
      debugPrint('📅 Priority: $priority');
      debugPrint(
        '📅 Repeat: ${matchDateTimeComponents != null ? "Yes" : "No"}',
      );

      await _scheduleNotificationFixed(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        channelId: channelId,
        priority: priority,
      );

      debugPrint('✅ Custom notification berhasil dijadwalkan untuk: $title');
    } catch (e) {
      debugPrint('❌ Error jadwalin notif kustom: $e');
    }
  }

  // Jadwalkan notifikasi berdasarkan rule dari RuleEngine
  Future<void> scheduleRuleNotification(NotificationRule rule) async {
    final now = DateTime.now();

    // Tentukan channelId berdasarkan tipe rule
    String channelId;
    if (rule.type == 'urgent' || rule.priority == 'critical') {
      channelId = 'urgent_reminders_v3';
    } else if (rule.type == 'motivational') {
      channelId = 'ai_recommendations';
    } else {
      channelId = 'rule_reminders';
    }

    // Tentukan priority
    String priority;
    switch (rule.priority) {
      case 'critical':
        priority = 'critical';
        break;
      case 'high':
        priority = 'high';
        break;
      case 'medium':
        priority = 'medium';
        break;
      case 'low':
        priority = 'low';
        break;
      default:
        priority = 'medium';
    }

    // Tentukan ID unik berdasarkan rule ID
    final notifId = 'rule_${rule.id}'.hashCode;

    // Jadwalkan notifikasi
    if (rule.triggerTime.isAfter(now)) {
      // Jika untuk masa depan, jadwalkan
      await scheduleCustomNotification(
        id: notifId,
        title: rule.name,
        body: rule.message,
        scheduledTime: rule.triggerTime,
        priority: priority,
        channelId: channelId,
      );
    } else {
      // Jika untuk sekarang, kirim langsung
      await showNotification(
        id: notifId,
        title: rule.name,
        body: rule.message,
        priority: priority,
        channelId: channelId,
      );
    }
  }

  // Jadwalkan notifikasi berdasarkan rule engine untuk satu tugas
  Future<void> scheduleRuleBasedNotifications(Task task) async {
    if (!_isInitialized) await initialize();

    if (!_permissionsGranted) {
      debugPrint('❌ Permission belum dikasih, gak bisa bikin notif rule');
      return;
    }

    try {
      final ruleEngine = RuleEngine();
      final rules = ruleEngine.generateScheduledReminders([task]);

      debugPrint(
        '🔄 Scheduling rule-based notifications for task: ${task.title}',
      );
      debugPrint('📋 Found ${rules.length} applicable rules');

      int scheduledCount = 0;

      for (var rule in rules) {
        final now = DateTime.now();

        // Skip if trigger time is in the past
        if (rule.triggerTime.isBefore(now)) {
          debugPrint('⏭️ Rule ${rule.name} has past trigger time, skipping');
          continue;
        }

        // Jadwalkan notifikasi untuk rule ini
        await scheduleRuleNotification(rule);
        scheduledCount++;
      }

      debugPrint(
        '✅ Scheduled $scheduledCount rule-based notifications for task ${task.title}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling rule-based notifications: $e');
    }
  }

  // Helper untuk mendapatkan periode waktu berikutnya (pagi, siang, sore)
  DateTime getNextTimeOfDay(int targetHour, int targetMinute) {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  // Jadwalkan pengingat harian, mingguan, dll
  Future<void> scheduleRecurringReminders() async {
    try {
      final now = DateTime.now();

      // 1. Jadwalkan pengingat pagi (08:00)
      final morningTime = getNextTimeOfDay(8, 0);
      await scheduleCustomNotification(
        id: 'recurring_morning'.hashCode,
        title: '🌅 Selamat Pagi!',
        body:
            'Siapkan harimu dengan baik. Cek tugas yang perlu dikerjakan hari ini.',
        scheduledTime: morningTime,
        priority: 'medium',
        channelId: 'daily_reminders_v3',
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Jadwalkan pengingat malam (21:00)
      final eveningTime = getNextTimeOfDay(21, 0);
      await scheduleCustomNotification(
        id: 'recurring_evening'.hashCode,
        title: '🌙 Review Harian',
        body:
            'Waktu untuk mereview apa yang sudah dikerjakan hari ini dan siapkan rencana besok.',
        scheduledTime: eveningTime,
        priority: 'medium',
        channelId: 'daily_reminders_v3',
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 3. Jadwalkan pengingat mingguan (Minggu jam 18:00)
      DateTime nextSunday = now;
      while (nextSunday.weekday != DateTime.sunday) {
        nextSunday = nextSunday.add(const Duration(days: 1));
      }
      final weeklyTime = DateTime(
        nextSunday.year,
        nextSunday.month,
        nextSunday.day,
        18,
        0,
      );

      if (weeklyTime.isAfter(now)) {
        await scheduleCustomNotification(
          id: 'recurring_weekly'.hashCode,
          title: '📊 Review Mingguan',
          body:
              'Saatnya mereview progres minggu ini dan merencanakan minggu depan!',
          scheduledTime: weeklyTime,
          priority: 'medium',
          channelId: 'task_reminders',
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      debugPrint('✅ Recurring reminders berhasil dijadwalkan');
    } catch (e) {
      debugPrint('❌ Error jadwalin recurring reminders: $e');
    }
  }

  // Proses semua rule untuk daftar tugas dan jadwalkan notifikasi
  Future<void> processRuleEngineForAllTasks(List<Task> tasks) async {
    if (!_isInitialized) await initialize();

    if (!_permissionsGranted) {
      debugPrint('❌ Permission belum dikasih, gak bisa proses rule engine');
      return;
    }

    try {
      final ruleEngine = RuleEngine();

      // Dapatkan semua rules untuk tasks
      final activeRules = ruleEngine.evaluateAllTasks(tasks);

      debugPrint('🔄 Processing rule engine for ${tasks.length} tasks');
      debugPrint('📋 Found ${activeRules.length} active rules');

      // Batasi ke 3 notifikasi teratas berdasarkan prioritas
      final topRules = activeRules.take(3).toList();

      for (var rule in topRules) {
        await scheduleRuleNotification(rule);
      }

      // Juga jadwalkan rules untuk masa depan
      final futureRules = ruleEngine.generateScheduledReminders(tasks);
      int scheduledCount = 0;

      for (var rule in futureRules) {
        final now = DateTime.now();

        if (rule.triggerTime.isAfter(now)) {
          await scheduleRuleNotification(rule);
          scheduledCount++;
        }
      }

      debugPrint(
        '✅ Processed ${topRules.length} immediate rules and scheduled $scheduledCount future rules',
      );
    } catch (e) {
      debugPrint('❌ Error processing rule engine: $e');
    }
  }

  // 🆕 PERBAIKAN: Jadwalkan ulang semua notifikasi tugas yang aktif
  Future<int> reScheduleAllNotifications() async {
    if (!_isInitialized) await initialize();
    if (!_permissionsGranted) await requestPermissions();

    try {
      final db = DatabaseHelper();
      final tasks = await db.getTasksByStatus('pending');

      debugPrint(
        '🔄 RE-SCHEDULING ALL NOTIFICATIONS for ${tasks.length} tasks',
      );

      // Batalkan semua notifikasi lama dulu agar tidak duplikat
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('🗑️ All old notifications cancelled');

      int totalScheduled = 0;
      for (var task in tasks) {
        await scheduleTaskNotifications(task);
        totalScheduled++;
      }

      // Jadwalkan ulang recurring reminders (System)
      await scheduleRecurringReminders();

      // 🆕 PERBAIKAN: Jadwalkan ulang Daily Reminder milik USER
      final prefs = await SharedPreferences.getInstance();
      final isDailyEnabled = prefs.getBool('daily_reminder_enabled') ?? true;
      if (isDailyEnabled) {
        int hour = prefs.getInt('daily_reminder_hour') ?? 12;
        int minute = prefs.getInt('daily_reminder_minute') ?? 0;
        final timeString = prefs.getString('reminder_time');
        if (timeString != null && timeString.contains(':')) {
          final parts = timeString.split(':');
          if (parts.length == 2) {
            hour = int.tryParse(parts[0]) ?? hour;
            minute = int.tryParse(parts[1]) ?? minute;
          }
        }
        await scheduleDailyReminder(TimeOfDay(hour: hour, minute: minute));
        debugPrint('⏰ User Daily Reminder restored for $hour:$minute');
      }

      debugPrint(
        '✅ Re-scheduling complete! Scheduled for $totalScheduled tasks.',
      );
      return totalScheduled;
    } catch (e) {
      debugPrint('❌ Error during re-scheduling: $e');
      return 0;
    }
  }
}
