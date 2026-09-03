import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/task_model.dart';
import '../services/notification_service.dart';
import '../services/saw_service.dart';
import '../themes/app_theme.dart';
import '../utils/datetime_helper.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance =
      AIRecommendationService._internal();
  factory AIRecommendationService({required List<Task> tasks}) => _instance;
  AIRecommendationService._internal();

  // Cache fields to synchronize data
  List<Task>? _lastTasks;
  List<String>? _lastStudiedTaskIds;
  StudyRecommendation? _cachedRecommendation;
  DateTime? _lastGeneratedTime;

  bool _isSameTasksList(List<Task> a, List<Task>? b) {
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
      if (a[i].status != b[i].status) return false;
      if (a[i].deadline != b[i].deadline) return false;
      if (a[i].priority != b[i].priority) return false;
      if (a[i].difficultyLevel != b[i].difficultyLevel) return false;
      if (a[i].estimatedHours != b[i].estimatedHours) return false;
    }
    return true;
  }

  bool _isSameStudiedIds(List<String> a, List<String>? b) {
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Fungsi untuk generate tips produktivitas
  List<ProductivityTip> generateProductivityTips(List<Task> tasks) {
    List<ProductivityTip> tips = [];

    // Tip berdasarkan pola deadline
    final upcomingDeadlines =
        tasks
            .where(
              (t) =>
                  t.status == 'pending' &&
                  !DateTimeHelper.isOverdue(t.deadline, DateTime.now()) &&
                  t.deadline.difference(DateTime.now()).inDays <= 3,
            )
            .length;

    if (upcomingDeadlines >= 3) {
      tips.add(
        ProductivityTip(
          title: '⏰ Time Management',
          description: 'Gunakan teknik Eisenhower Matrix untuk prioritas tugas',
          actionable:
              'Bagi tugas menjadi: Urgent-Important, Important-Not Urgent, dll.',
        ),
      );
    }

    final subjectTasks =
        tasks.where((t) => t.category.toLowerCase() == 'akademik').toList();
    if (subjectTasks.isNotEmpty) {
      final sub = subjectTasks.first.title;
      tips.add(
        ProductivityTip(
          title: '📚 Subject Focus',
          description: 'Fokus mendalam pada "$sub"',
          actionable: 'Selesaikan konsep tersulit dari "$sub" hari ini.',
        ),
      );
    }

    // Default tips
    tips.addAll([
      ProductivityTip(
        title: '🍅 Pomodoro Technique',
        description: '25 menit fokus + 5 menit istirahat',
        actionable: 'Download timer Pomodoro atau gunakan stopwatch',
      ),
      ProductivityTip(
        title: '🎯 Single Tasking',
        description: 'Fokus pada satu tugas hingga selesai',
        actionable: 'Matikan notifikasi yang tidak penting',
      ),
    ]);

    return tips;
  }

  // Fungsi untuk menghasilkan rekomendasi belajar dengan SAW
  Future<StudyRecommendation> generateStudyRecommendation(
    List<Task> tasks,
  ) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // Get list of tasks marked as studied today from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final studiedTaskIds = prefs.getStringList('studied_tasks_$todayStr') ?? [];

    // Cache hit check (valid for 15 seconds to prevent skew during same navigation)
    if (_cachedRecommendation != null &&
        _lastGeneratedTime != null &&
        now.difference(_lastGeneratedTime!).inSeconds < 15 &&
        _isSameTasksList(tasks, _lastTasks) &&
        _isSameStudiedIds(studiedTaskIds, _lastStudiedTaskIds)) {
      debugPrint('⚡ AIRecommendationService: Returning cached recommendation');
      return _cachedRecommendation!;
    }

    final urgentTasks = <Task>[];
    final mediumTasks = <Task>[];
    final lowTasks = <Task>[];

    // Filter out studied tasks
    final filteredTasks =
        tasks.where((t) {
          if (t.id != null && studiedTaskIds.contains(t.id.toString())) {
            return false; // Skip if already studied today
          }
          return true;
        }).toList();

    // Gunakan SAW untuk kategorisasi
    final pendingTasks =
        filteredTasks.where((t) => t.status == 'pending').toList();

    if (pendingTasks.isNotEmpty) {
      // Gunakan metode SAW
      final sawService = SAWService();
      final sawResults = sawService.calculatePriority(filteredTasks);

      for (final result in sawResults) {
        if (result.sawScore >= 0.65) {
          urgentTasks.add(result.task);
        } else if (result.sawScore >= 0.35) {
          mediumTasks.add(result.task);
        } else {
          lowTasks.add(result.task);
        }
      }

      debugPrint(
        '📊 SAW Kategorisasi: Urgent=${urgentTasks.length}, '
        'Medium=${mediumTasks.length}, Low=${lowTasks.length}',
      );
    }

    // Generate rekomendasi berdasarkan rules
    final recommendation = _generateRecommendationBasedOnRules(
      urgentTasks,
      mediumTasks,
      lowTasks,
    );

    // Update cache
    _lastTasks = List.from(tasks);
    _lastStudiedTaskIds = List.from(studiedTaskIds);
    _cachedRecommendation = recommendation;
    _lastGeneratedTime = now;

    return recommendation;
  }

  List<StudySlot> _getAvailableSlots(
    DateTime now,
    DateTime deadline, {
    bool limitToUrgent = false,
  }) {
    List<StudySlot> available = [];

    // Check up to 14 days ahead (2 weeks)
    for (int day = 0; day < 14; day++) {
      final date = now.add(Duration(days: day));

      final slotsToday = [
        StudySlot(
          start: DateTime(date.year, date.month, date.day, 8, 0),
          end: DateTime(date.year, date.month, date.day, 10, 0),
          label: 'Pagi',
        ),
        StudySlot(
          start: DateTime(date.year, date.month, date.day, 13, 0),
          end: DateTime(date.year, date.month, date.day, 15, 0),
          label: 'Siang',
        ),
        StudySlot(
          start: DateTime(date.year, date.month, date.day, 16, 0),
          end: DateTime(date.year, date.month, date.day, 18, 0),
          label: 'Sore',
        ),
        StudySlot(
          start: DateTime(date.year, date.month, date.day, 19, 0),
          end: DateTime(date.year, date.month, date.day, 21, 0),
          label: 'Malam',
        ),
      ];

      for (var slot in slotsToday) {
        // 1. start must be at least 1 hour after now
        if (slot.start.difference(now).inMinutes < 60) {
          continue;
        }

        // 2. start must be before deadline
        if (!slot.start.isBefore(deadline)) {
          continue;
        }

        // 3. check end time
        if (limitToUrgent) {
          // For urgent, if deadline is inside the slot, we truncate the slot to end at deadline
          if (slot.end.isAfter(deadline)) {
            available.add(
              StudySlot(start: slot.start, end: deadline, label: slot.label),
            );
          } else {
            available.add(slot);
          }
        } else {
          // For medium/low, the whole session (which is 1 hour long) must end before or at the deadline.
          // Since the default slot duration is 2 hours, if we only need 1 hour, then the 1-hour session
          // starts at slot.start and ends at slot.start + 1 hour.
          // So slot.start + 1 hour must be before or equal to deadline.
          final sessionEnd = slot.start.add(const Duration(hours: 1));
          if (!sessionEnd.isAfter(deadline)) {
            available.add(slot);
          }
        }
      }
    }

    return available;
  }

  Map<String, dynamic> _generateDynamicSchedule(
    Task task,
    String priorityGroup,
  ) {
    final now = DateTime.now();

    // 3 & 4. Pengecekan deadline & jangan membuat jadwal setelah deadline
    if (now.isAfter(task.deadline)) {
      return {'schedule': 'Deadline tugas sudah berakhir.', 'hours': 0.0};
    }

    double recommendedHours = 1.0;
    String schedule = '';
    final random = Random();

    if (priorityGroup == 'urgent') {
      recommendedHours = 4.0;
      // Get slots for urgent (can truncate at deadline)
      final slots = _getAvailableSlots(now, task.deadline, limitToUrgent: true);

      if (slots.isEmpty) {
        return {
          'schedule':
              'Deadline tugas sudah berakhir atau terlalu dekat untuk dijadwalkan.',
          'hours': 0.0,
        };
      }

      if (slots.length >= 2) {
        final s1 = slots[0];
        final s2 = slots[1];

        final double h1 = s1.end.difference(s1.start).inMinutes / 60.0;
        final double h2 = s2.end.difference(s2.start).inMinutes / 60.0;
        recommendedHours = h1 + h2;

        final range1 = _formatDateTimeRange(s1.start, s1.end);
        final range2 = _formatDateTimeRange(s2.start, s2.end);

        final variations = [
          '🔥 Tugas "${task.title}" sangat krusial saat ini. Yuk, langsung kerjakan secara bertahap pada jadwal berikut:\n• Sesi 1: $range1\n• Sesi 2: $range2',
          '⏳ Batas pengumpulan "${task.title}" sudah dekat. Mari selesaikan lewat dua sesi belajar berikut:\n• Sesi 1: $range1\n• Sesi 2: $range2',
          '🎯 Agar tugas "${task.title}" selesai tepat waktu dengan hasil terbaik, luangkan waktu pada:\n• Sesi 1: $range1\n• Sesi 2: $range2',
        ];
        schedule = variations[random.nextInt(variations.length)];
      } else {
        // Only 1 slot available before deadline
        final s1 = slots[0];
        recommendedHours = s1.end.difference(s1.start).inMinutes / 60.0;
        final range1 = _formatDateTimeRange(s1.start, s1.end);

        schedule =
            '🔥 Tugas "${task.title}" butuh perhatian ekstra karena batas pengumpulan sudah sangat dekat. Luangkan waktumu pada $range1 untuk fokus menyelesaikannya.';
      }
    } else if (priorityGroup == 'medium') {
      recommendedHours = 2.0;
      final slots = _getAvailableSlots(
        now,
        task.deadline,
        limitToUrgent: false,
      );

      if (slots.length >= 2) {
        final s1 = slots[0];
        final s2 = slots[1];

        // Medium uses 1 hour per session
        final s1End = s1.start.add(const Duration(hours: 1));
        final s2End = s2.start.add(const Duration(hours: 1));

        final range1 = _formatDateTimeRange(s1.start, s1End);
        final range2 = _formatDateTimeRange(s2.start, s2End);

        final variations = [
          '📅 Karena tugas "${task.title}" cukup mendesak, mari membaginya menjadi beberapa sesi pengerjaan secara bertahap:\n• Sesi 1: $range1\n• Sesi 2: $range2\nLangkah ini dipilih agar kamu tidak kewalahan mendekati deadline.',
          '💡 Untuk menjaga kualitas hasil tugas "${task.title}", sebaiknya kerjakan secara bertahap pada jadwal berikut:\n• Sesi 1: $range1\n• Sesi 2: $range2\nDengan mencicil lebih awal, pengerjaan akan terasa jauh lebih santai.',
          '⚡ Progres pengerjaan tugas "${task.title}" sebaiknya dibagi menjadi sesi-sesi berikut agar tetap konsisten:\n• Sesi 1: $range1\n• Sesi 2: $range2\nBeban tugasmu akan terasa jauh lebih ringan!',
        ];
        schedule = variations[random.nextInt(variations.length)];
      } else if (slots.isNotEmpty) {
        final s1 = slots[0];
        final s1End = s1.start.add(const Duration(hours: 1));
        recommendedHours = 1.0;
        final range1 = _formatDateTimeRange(s1.start, s1End);
        schedule =
            '📅 Tugas "${task.title}" cukup mendesak. Sesi belajar dijadwalkan pada $range1.';
      } else {
        return {
          'schedule':
              'Deadline tugas sudah berakhir atau terlalu dekat untuk dijadwalkan.',
          'hours': 0.0,
        };
      }
    } else {
      // low priority
      recommendedHours = 1.0;
      final slots = _getAvailableSlots(
        now,
        task.deadline,
        limitToUrgent: false,
      );

      if (slots.isNotEmpty) {
        final s1 = slots[0];
        final s1End = s1.start.add(const Duration(hours: 1));
        final range1 = _formatDateTimeRange(s1.start, s1End);

        final variations = [
          '✨ Karena tugas "${task.title}" masih memiliki tenggat waktu yang cukup lama, kamu bisa mengerjakannya secara santai pada jadwal berikut:\n• Sesi 1: $range1\nSelamat belajar!',
          '🍃 Santai saja, tapi tetap terarah. Mari cicil materi untuk "${task.title}" sedikit demi sedikit pada slot waktu berikut:\n• Sesi 1: $range1\nCara ini efektif menjaga konsentrasi tanpa bikin lelah.',
          '📚 Untuk menghemat energi, mari jadwalkan pengerjaan "${task.title}" secara berkala pada jadwal berikut:\n• Sesi 1: $range1\nProgres yang konsisten adalah kunci utama!',
        ];
        schedule = variations[random.nextInt(variations.length)];
      } else {
        return {
          'schedule':
              'Deadline tugas sudah berakhir atau terlalu dekat untuk dijadwalkan.',
          'hours': 0.0,
        };
      }
    }

    return {'schedule': schedule, 'hours': recommendedHours};
  }

  String _formatDateTimeRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final daysDiff = startDay.difference(today).inDays;

    String dayLabel;
    if (daysDiff == 0) {
      dayLabel = 'Hari ini';
    } else if (daysDiff == 1) {
      dayLabel = 'Besok';
    } else {
      dayLabel = DateFormat('dd MMM').format(start);
    }

    final startStr = DateFormat('HH.mm').format(start);
    final endStr = DateFormat('HH.mm').format(end);
    return '$dayLabel pukul $startStr–$endStr';
  }

  StudyRecommendation _generateRecommendationBasedOnRules(
    List<Task> urgentTasks,
    List<Task> mediumTasks,
    List<Task> lowTasks,
  ) {
    String mainMessage = '';
    String studySchedule = '';
    List<String> actionItems = [];
    String motivationalMessage = '';
    double recommendedStudyHours = 0.0;
    int? recommendedTaskId;

    Task? recommendedTask;
    String priorityGroup = '';

    if (urgentTasks.isNotEmpty) {
      recommendedTask = urgentTasks.first;
    } else if (mediumTasks.isNotEmpty) {
      recommendedTask = mediumTasks.first;
    } else if (lowTasks.isNotEmpty) {
      recommendedTask = lowTasks.first;
    }

    if (recommendedTask != null) {
      recommendedTaskId = recommendedTask.id;
      final now = DateTime.now();

      // Hitung perbedaan hari berdasarkan tanggal kalender (midnight)
      final today = DateTime(now.year, now.month, now.day);
      final deadlineDay = DateTime(
        recommendedTask.deadline.year,
        recommendedTask.deadline.month,
        recommendedTask.deadline.day,
      );
      final daysDiff = deadlineDay.difference(today).inDays;

      if (daysDiff <= 1) {
        priorityGroup = 'urgent';
      } else if (daysDiff <= 3) {
        priorityGroup = 'medium';
      } else {
        priorityGroup = 'low';
      }

      // 3. Pengecekan deadline sebelum Rule-Based
      if (now.isAfter(recommendedTask.deadline)) {
        mainMessage = 'Tugas telah melewati batas pengumpulan.';
        studySchedule = 'Deadline tugas sudah berakhir.';
        recommendedStudyHours = 0.0;
        actionItems = ['Tugas telah melewati batas pengumpulan.'];
      } else {
        // Normal recommendation
        mainMessage =
            priorityGroup == 'urgent'
                ? '⏰ Prioritas Utama: Selesaikan "${recommendedTask.title}"!'
                : priorityGroup == 'medium'
                ? '📚 Waktunya Fokus: "${recommendedTask.title}"'
                : '✨ Belajar Santai: "${recommendedTask.title}"';

        final dynamicRec = _generateDynamicSchedule(
          recommendedTask,
          priorityGroup,
        );
        studySchedule = dynamicRec['schedule'];
        recommendedStudyHours = dynamicRec['hours'];
        actionItems = _generateActionItemsForTask(
          recommendedTask,
          priorityGroup,
        );
      }
    } else {
      mainMessage = '🎉 Semua tugas selesai! Kerja bagus!';
      studySchedule = 'Tidak ada jadwal belajar. Santai sejenak hari ini!';
      recommendedStudyHours = 0.0;
      actionItems = [
        'Istirahat yang cukup untuk menyegarkan pikiran.',
        'Buat list tugas baru jika ada perkuliahan/materi baru.',
      ];
    }

    // Dynamic motivation based on task completion
    motivationalMessage = _generateMotivationMessage(
      urgentTasks.length + mediumTasks.length + lowTasks.length,
    );

    return StudyRecommendation(
      mainMessage: mainMessage,
      studySchedule: studySchedule,
      recommendedStudyHours: recommendedStudyHours,
      actionItems: actionItems,
      motivationalMessage: motivationalMessage,
      urgentTaskCount: urgentTasks.length,
      mediumTaskCount: mediumTasks.length,
      lowTaskCount: lowTasks.length,
      recommendedTaskId: recommendedTaskId,
      urgentTasksList: urgentTasks,
      mediumTasksList: mediumTasks,
      lowTasksList: lowTasks,
    );
  }

  List<String> _generateActionItemsForTask(Task task, String priorityGroup) {
    List<String> actions = [];
    final categoryLower = task.category.toLowerCase();
    final random = Random();

    // Helper to get random item from list
    String getRandom(List<String> list) => list[random.nextInt(list.length)];

    // 1. Actions based on Category
    if (categoryLower == 'ujian' || categoryLower == 'quiz') {
      final opt1 = [
        'Tinjau kembali catatan utama dan kisi-kisi.',
        'Baca ulang ringkasan materi dan rumus penting.',
        'Fokus pelajari bab yang belum sepenuhnya dikuasai.',
        'Review poin-poin penting dari tugas-tugas sebelumnya.',
      ];
      final opt2 = [
        'Kerjakan minimal 3-5 latihan soal (mock test).',
        'Coba selesaikan soal ujian tahun lalu jika ada.',
        'Buat kartu flashcard (kartu pengingat) untuk istilah penting.',
        'Simulasikan suasana ujian dengan stopwatch.',
      ];
      actions.add(getRandom(opt1));
      actions.add(getRandom(opt2));
    } else if (categoryLower == 'presentasi') {
      final opt1 = [
        'Latih pelafalan materi presentasi di depan cermin.',
        'Coba rekam suara saat latihan presentasi untuk evaluasi.',
        'Pahami outline presentasi daripada menghafal kata per kata.',
        'Latih transisi antar slide agar penyampaian mengalir.',
      ];
      final opt2 = [
        'Periksa kompatibilitas slide presentasi.',
        'Pastikan format file slide aman dan siap ditayangkan.',
        'Siapkan catatan poin kecil sebagai contekan darurat.',
        'Coba presentasikan materi di depan teman atau keluarga.',
      ];
      actions.add(getRandom(opt1));
      actions.add(getRandom(opt2));
    } else if (categoryLower == 'membaca') {
      final opt1 = [
        'Tulis rangkuman paragraf/poin penting.',
        'Gunakan teknik scanning untuk menemukan ide pokok.',
        'Stabilo kalimat kunci atau catat di buku kecil.',
        'Jelaskan kembali isi bacaan dengan bahasa sendiri.',
      ];
      final opt2 = [
        'Buat mind map atau peta konsep materi.',
        'Gunakan visualisasi (gambar/diagram) untuk materi rumit.',
        'Tulis 3 pertanyaan penting dari hasil bacaan hari ini.',
        'Diskusikan inti bacaan di forum belajar atau chat.',
      ];
      actions.add(getRandom(opt1));
      actions.add(getRandom(opt2));
    } else {
      // Default / Tugas / Lainnya
      final opt1 = [
        'Bagi tugas "${task.title}" menjadi 3 sub-tugas kecil.',
        'Tulis langkah-langkah pengerjaan tugas secara terurut.',
        'Mulai dari bagian tugas yang paling cepat diselesaikan.',
        'Selesaikan draft awal terlebih dahulu tanpa perlu langsung sempurna.',
      ];
      final opt2 = [
        'Fokus selesaikan 1 sub-tugas sebelum lanjut ke sub-tugas berikutnya.',
        'Kerjakan langkah demi langkah secara bertahap dan konsisten.',
        'Centang sub-tugas yang selesai agar motivasi terjaga.',
        'Jangan tunda pengerjaan bagian tersulit jika energi masih penuh.',
      ];
      actions.add(getRandom(opt1));
      actions.add(getRandom(opt2));
    }

    // 2. Actions based on Difficulty
    if (task.difficultyLevel >= 4) {
      final opt1 = [
        'Tugas sulit (${task.difficultyLabel}): Cari referensi tambahan atau tanya teman jika buntu.',
        'Tugas cukup menantang (${task.difficultyLabel}): Tonton video penjelasan di YouTube jika bingung.',
        'Tugas level ${task.difficultyLabel}: Jangan ragu mencari contoh pengerjaan di internet.',
        'Karena tugas ini ${task.difficultyLabel}, mulailah dengan riset materi dasar dahulu.',
      ];
      final opt2 = [
        'Istirahat 5 menit setiap 25 menit agar konsentrasi tetap tajam.',
        'Gunakan teknik Pomodoro: 25 menit fokus, 5 menit istirahat.',
        'Pecah fokus menjadi sesi 30 menitan agar tidak merasa kewalahan.',
        'Ambil jeda peregangan singkat jika pikiran mulai lelah.',
      ];
      actions.add(getRandom(opt1));
      actions.add(getRandom(opt2));
    } else {
      final opt = [
        'Jauhkan ponsel dan tab media sosial saat mulai belajar.',
        'Matikan notifikasi chat selama sesi belajar berlangsung.',
        'Cari tempat belajar yang tenang dan bebas gangguan.',
        'Siapkan air minum di dekat meja belajar agar tetap fokus.',
      ];
      actions.add(getRandom(opt));
    }

    // 3. Actions based on Urgency group
    if (priorityGroup == 'urgent') {
      final opt = [
        'Hindari multitasking! Jangan membuka materi pelajaran lain sebelum ini selesai.',
        'Prioritaskan tugas ini secara mutlak hari ini sebelum mengerjakan hal lain.',
        'Blokir semua gangguan eksternal karena deadline tugas ini sudah dekat.',
        'Singkirkan semua distraksi, saatnya fokus penuh 100% pada tugas ini.',
      ];
      actions.add(getRandom(opt));
    }

    return actions;
  }

  String _generateMotivationMessage(int activeTasksCount) {
    if (activeTasksCount == 0) {
      return '✨ Semua target tercapai! Nikmati waktu luang Anda!';
    }
    if (activeTasksCount >= 5) {
      return '🔥 Beban belajar cukup padat. Ambil nafas dalam-dalam, mari selesaikan satu per satu!';
    }
    return '🎯 Setiap langkah kecil sangat berharga. Semangat menyelesaikan target hari ini!';
  }

  // Mengirim notifikasi motivasi berdasarkan performa
  Future<void> sendMotivationalNotification(List<Task> tasks) async {
    final completedToday =
        tasks
            .where(
              (t) =>
                  t.status == 'completed' &&
                  t.completedAt != null &&
                  _isToday(t.completedAt!),
            )
            .length;

    String message = '';

    if (completedToday >= 3) {
      message =
          '🎉 Amazing! Kamu sudah menyelesaikan $completedToday tugas hari ini!';
    } else if (completedToday >= 1) {
      message = '👏 Good job! $completedToday tugas selesai. Keep going!';
    } else {
      message = '💪 Ayo semangat! Mulai dengan tugas yang paling mudah dulu.';
    }

    await NotificationService().showNotification(
      id: 'motivation'.hashCode,
      title: '💡 Daily Motivation',
      body: message,
      priority: 'low',
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }
}

// Model untuk rekomendasi belajar
class StudyRecommendation {
  final String mainMessage;
  final String studySchedule;
  final double recommendedStudyHours;
  final List<String> actionItems;
  final String motivationalMessage;
  final int urgentTaskCount;
  final int mediumTaskCount;
  final int lowTaskCount;
  final int? recommendedTaskId;
  final List<Task> urgentTasksList;
  final List<Task> mediumTasksList;
  final List<Task> lowTasksList;

  StudyRecommendation({
    required this.mainMessage,
    required this.studySchedule,
    required this.recommendedStudyHours,
    required this.actionItems,
    required this.motivationalMessage,
    required this.urgentTaskCount,
    required this.mediumTaskCount,
    required this.lowTaskCount,
    this.recommendedTaskId,
    required this.urgentTasksList,
    required this.mediumTasksList,
    required this.lowTasksList,
  });
}

// Model untuk tips produktivitas
class ProductivityTip {
  final String title;
  final String description;
  final String actionable;

  ProductivityTip({
    required this.title,
    required this.description,
    required this.actionable,
  });
}

class StudySlot {
  final DateTime start;
  final DateTime end;
  final String label;

  StudySlot({required this.start, required this.end, required this.label});
}
