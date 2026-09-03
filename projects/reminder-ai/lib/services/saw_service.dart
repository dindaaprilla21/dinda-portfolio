import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

/// Model hasil perhitungan SAW per tugas
class SAWResult {
  final Task task;
  final double rawDeadlineScore; // C1: Sisa waktu (jam)
  final double rawDifficultyScore; // C2: Tingkat kesulitan (1-5)
  final double rawEstimationScore; // C3: Estimasi waktu (jam)
  final double normDeadlineScore; // C1 setelah normalisasi
  final double normDifficultyScore; // C2 setelah normalisasi
  final double normEstimationScore; // C3 setelah normalisasi
  final double sawScore; // Skor akhir SAW (0.0 - 1.0)
  final int ranking; // Peringkat

  SAWResult({
    required this.task,
    required this.rawDeadlineScore,
    required this.rawDifficultyScore,
    required this.rawEstimationScore,
    required this.normDeadlineScore,
    required this.normDifficultyScore,
    required this.normEstimationScore,
    required this.sawScore,
    required this.ranking,
  });

  /// Label prioritas berdasarkan skor SAW
  String get priorityLabel {
    if (sawScore >= 0.65) return 'Tinggi';
    if (sawScore >= 0.35) return 'Sedang';
    return 'Rendah';
  }

  /// Emoji prioritas
  String get priorityEmoji {
    if (sawScore >= 0.65) return '🔴';
    if (sawScore >= 0.35) return '🟠';
    return '🟢';
  }
}

/// Konfigurasi bobot kriteria SAW
class SAWWeights {
  final double deadlineWeight; // C1: Bobot deadline
  final double difficultyWeight; // C2: Bobot kesulitan
  final double estimationWeight; // C3: Bobot estimasi waktu

  const SAWWeights({
    this.deadlineWeight = 0.40,
    this.difficultyWeight = 0.35,
    this.estimationWeight = 0.25,
  });

  /// Validasi total bobot = 1.0
  bool get isValid {
    final total = deadlineWeight + difficultyWeight + estimationWeight;
    return (total - 1.0).abs() < 0.001;
  }

  List<double> get asList => [
    deadlineWeight,
    difficultyWeight,
    estimationWeight,
  ];

  static const List<String> criteriaNames = [
    'Deadline',
    'Kesulitan',
    'Estimasi Waktu',
  ];
  static const List<String> criteriaTypes = ['Cost', 'Benefit', 'Benefit'];
}

/// Service utama untuk menghitung prioritas menggunakan metode SAW
class SAWService {
  static final SAWService _instance = SAWService._internal();
  factory SAWService() => _instance;
  SAWService._internal();

  SAWWeights _weights = const SAWWeights();

  SAWWeights get weights => _weights;

  void updateWeights(SAWWeights newWeights) {
    if (newWeights.isValid) {
      _weights = newWeights;
      debugPrint('⚖️ Bobot SAW diperbarui: ${newWeights.asList}');
    } else {
      debugPrint('❌ Bobot SAW tidak valid! Total harus = 1.0');
    }
  }

  /// Menghitung prioritas SAW untuk semua tugas pending
  List<SAWResult> calculatePriority(List<Task> tasks) {
    // Filter hanya tugas pending
    final pendingTasks = tasks.where((t) => t.status == 'pending').toList();

    if (pendingTasks.isEmpty) {
      debugPrint('ℹ️ Tidak ada tugas pending untuk dihitung SAW');
      return [];
    }

    debugPrint(
      '📊 Memulai perhitungan SAW untuk ${pendingTasks.length} tugas...',
    );

    // ==========================================
    // LANGKAH 1: Hitung nilai mentah (raw scores)
    // ==========================================
    final now = DateTime.now();
    final List<Map<String, double>> rawMatrix = [];

    for (final task in pendingTasks) {
      final rawScores = _calculateRawScores(task, now);
      rawMatrix.add(rawScores);
    }

    debugPrint('📋 Matriks keputusan (raw):');
    for (int i = 0; i < pendingTasks.length; i++) {
      debugPrint('   ${pendingTasks[i].title}: ${rawMatrix[i]}');
    }

    // ==========================================
    // LANGKAH 2: Normalisasi (min-max)
    // ==========================================
    final normalizedMatrix = _normalizeMatrix(rawMatrix);

    debugPrint('📋 Matriks ternormalisasi:');
    for (int i = 0; i < pendingTasks.length; i++) {
      debugPrint('   ${pendingTasks[i].title}: ${normalizedMatrix[i]}');
    }

    // ==========================================
    // LANGKAH 3: Hitung skor SAW (bobot × normalisasi)
    // ==========================================
    final List<double> sawScores = [];
    for (final normScores in normalizedMatrix) {
      final score = _calculateWeightedScore(normScores);
      sawScores.add(score);
    }

    debugPrint('📊 Skor SAW:');
    for (int i = 0; i < pendingTasks.length; i++) {
      debugPrint(
        '   ${pendingTasks[i].title}: ${sawScores[i].toStringAsFixed(4)}',
      );
    }

    // ==========================================
    // LANGKAH 4: Ranking
    // ==========================================
    // Buat index-score pairs dan sort descending
    final indexedScores = List.generate(
      pendingTasks.length,
      (i) => MapEntry(i, sawScores[i]),
    );
    indexedScores.sort((a, b) => b.value.compareTo(a.value));

    // Assign ranking
    final rankings = List<int>.filled(pendingTasks.length, 0);
    for (int rank = 0; rank < indexedScores.length; rank++) {
      rankings[indexedScores[rank].key] = rank + 1;
    }

    // ==========================================
    // LANGKAH 5: Buat SAWResult untuk setiap tugas
    // ==========================================
    final List<SAWResult> results = [];
    for (int i = 0; i < pendingTasks.length; i++) {
      results.add(
        SAWResult(
          task: pendingTasks[i],
          rawDeadlineScore: rawMatrix[i]['deadline']!,
          rawDifficultyScore: rawMatrix[i]['difficulty']!,
          rawEstimationScore: rawMatrix[i]['estimation']!,
          normDeadlineScore: normalizedMatrix[i]['deadline']!,
          normDifficultyScore: normalizedMatrix[i]['difficulty']!,
          normEstimationScore: normalizedMatrix[i]['estimation']!,
          sawScore: sawScores[i],
          ranking: rankings[i],
        ),
      );
    }

    // Sort by ranking
    results.sort((a, b) => a.ranking.compareTo(b.ranking));

    debugPrint('🏆 Ranking SAW:');
    for (final result in results) {
      debugPrint(
        '   #${result.ranking} ${result.task.title} '
        '(skor: ${result.sawScore.toStringAsFixed(4)}, '
        'prioritas: ${result.priorityLabel})',
      );
    }

    return results;
  }

  /// Hitung nilai mentah per kriteria untuk satu tugas
  /// Semua kriteria dihitung OTOMATIS dari data tugas yang ada
  Map<String, double> _calculateRawScores(Task task, DateTime now) {
    // C1: Deadline (sisa waktu dalam jam) - COST: semakin kecil semakin urgent
    final hoursUntilDeadline = task.deadline.difference(now).inMinutes / 60.0;
    // Clamp ke minimal 0.1 agar tidak negatif (overdue = sangat urgent)
    final deadlineScore = max(0.1, hoursUntilDeadline);

    // C2: Tingkat Kesulitan (1-5) - BENEFIT: langsung dari input user
    final difficultyScore = task.difficultyLevel.toDouble();

    // C3: Estimasi Waktu Pengerjaan (jam) - BENEFIT: langsung dari input user
    final estimationScore = task.estimatedHours;

    return {
      'deadline': deadlineScore,
      'difficulty': difficultyScore,
      'estimation': estimationScore,
    };
  }

  /// Normalisasi matriks menggunakan metode SAW
  /// - Benefit: r_ij = x_ij / max(x_j)
  /// - Cost: r_ij = min(x_j) / x_ij
  List<Map<String, double>> _normalizeMatrix(
    List<Map<String, double>> rawMatrix,
  ) {
    if (rawMatrix.isEmpty) return [];

    // Cari min dan max per kriteria
    double minDeadline = double.infinity, maxDeadline = 0;
    double maxDifficulty = 0;
    double maxEstimation = 0;

    for (final scores in rawMatrix) {
      minDeadline = min(minDeadline, scores['deadline']!);
      maxDeadline = max(maxDeadline, scores['deadline']!);
      maxDifficulty = max(maxDifficulty, scores['difficulty']!);
      maxEstimation = max(maxEstimation, scores['estimation']!);
    }

    // Hindari pembagian nol
    if (maxDeadline == 0) maxDeadline = 1;
    if (maxDifficulty == 0) maxDifficulty = 1;
    if (maxEstimation == 0) maxEstimation = 1;

    // Normalisasi
    final List<Map<String, double>> normalized = [];
    for (final scores in rawMatrix) {
      normalized.add({
        // C1 COST: min / x_ij (deadline kecil = prioritas tinggi)
        'deadline': minDeadline / scores['deadline']!,
        // C2 BENEFIT: x_ij / max (kesulitan tinggi = prioritas tinggi)
        'difficulty': scores['difficulty']! / maxDifficulty,
        // C3 BENEFIT: x_ij / max (estimasi lama = prioritas tinggi)
        'estimation': scores['estimation']! / maxEstimation,
      });
    }

    return normalized;
  }

  /// Hitung skor terbobot: sum(w_j * r_ij)
  double _calculateWeightedScore(Map<String, double> normalizedScores) {
    return (_weights.deadlineWeight * normalizedScores['deadline']!) +
        (_weights.difficultyWeight * normalizedScores['difficulty']!) +
        (_weights.estimationWeight * normalizedScores['estimation']!);
  }
}
