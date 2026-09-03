import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/ai_recommendation_service.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';

class AIRecommendationScreen extends StatefulWidget {
  final List<Task> tasks;

  const AIRecommendationScreen({super.key, required this.tasks});

  @override
  State<AIRecommendationScreen> createState() => _AIRecommendationScreenState();
}

class _AIRecommendationScreenState extends State<AIRecommendationScreen> {
  final AIRecommendationService _aiService = AIRecommendationService(tasks: []);
  StudyRecommendation? _recommendation;
  List<ProductivityTip>? _productivityTips;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate AI recommendations
      final recommendation = await _aiService.generateStudyRecommendation(
        widget.tasks,
      );
      final tips = _aiService.generateProductivityTips(widget.tasks);

      setState(() {
        _recommendation = recommendation;
        _productivityTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _markAsStudied(int taskId) async {
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      final prefs = await SharedPreferences.getInstance();
      final studiedTaskIds =
          prefs.getStringList('studied_tasks_$todayStr') ?? [];

      if (!studiedTaskIds.contains(taskId.toString())) {
        studiedTaskIds.add(taskId.toString());
        await prefs.setStringList('studied_tasks_$todayStr', studiedTaskIds);
      }

      // Show a premium snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mantap! Target belajar hari ini diperbarui.',
                    style: GoogleFonts.outfit(
                      fontSize: AppResponsive.fontBase,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            ),
            margin: AppResponsive.all(16),
          ),
        );
      }

      // Reload recommendations to get the next priority task
      await _loadRecommendations();
    } catch (e) {
      debugPrint('Error marking task as studied: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Asisten Belajar AI',
          style: GoogleFonts.outfit(
            fontSize: AppResponsive.fontXl,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_recommendation == null) {
      return const Center(child: Text('Tidak ada rekomendasi tersedia'));
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      child: SingleChildScrollView(
        padding: AppResponsive.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: _getCardGradient(),
                borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: AppResponsive.w(16),
                    offset: Offset(0, AppResponsive.h(8)),
                  ),
                ],
              ),
              padding: AppResponsive.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Text(
                    _recommendation!.mainMessage,
                    style: TextStyle(
                      fontSize: AppResponsive.fontXl,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.gapLg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          'Urgent',
                          _recommendation!.urgentTaskCount,
                          const Color(0xFFFF6B6B),
                        ),
                      ),
                      SizedBox(width: AppResponsive.w(8)),
                      Expanded(
                        child: _buildStatChip(
                          'Medium',
                          _recommendation!.mediumTaskCount,
                          const Color(0xFFFFB347),
                        ),
                      ),
                      SizedBox(width: AppResponsive.w(8)),
                      Expanded(
                        child: _buildStatChip(
                          'Low',
                          _recommendation!.lowTaskCount,
                          const Color(0xFF51CF66),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppResponsive.gapXl),

            // Study Schedule Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
              ),
              child: Padding(
                padding: AppResponsive.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppTheme.primaryColor,
                          size: AppResponsive.iconMd,
                        ),
                        SizedBox(width: AppResponsive.w(8)),
                        Expanded(
                          child: Text(
                            ' Rekomendasi Jadwal Belajar ',
                            style: TextStyle(
                              fontSize: AppResponsive.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppResponsive.gapLg),
                    Text(
                      _recommendation!.studySchedule,
                      style: TextStyle(fontSize: AppResponsive.fontBase),
                    ),
                    SizedBox(height: AppResponsive.gapLg),
                    Container(
                      padding: AppResponsive.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radiusSm,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.blue,
                            size: AppResponsive.iconMd,
                          ),
                          SizedBox(width: AppResponsive.w(8)),
                          Expanded(
                            child: Text(
                              'Rekomendasi belajar: ${_recommendation!.recommendedStudyHours.toStringAsFixed(1).replaceAll('.0', '')} jam',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                                fontSize: AppResponsive.fontBase,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_recommendation!.recommendedTaskId != null) ...[
                      SizedBox(height: AppResponsive.h(14)),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _markAsStudied(
                                _recommendation!.recommendedTaskId!,
                              ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              width: 1.2,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppResponsive.h(14),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusMd,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: Text(
                            'Sudah Belajar Tugas Ini',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: AppResponsive.fontBase,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: AppResponsive.gapXl),

            // Action Items Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
              ),
              child: Padding(
                padding: AppResponsive.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          color: AppTheme.primaryColor,
                          size: AppResponsive.iconMd,
                        ),
                        SizedBox(width: AppResponsive.w(8)),
                        Expanded(
                          child: Text(
                            'Yang Harus Dilakukan',
                            style: TextStyle(
                              fontSize: AppResponsive.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppResponsive.gapLg),
                    ..._recommendation!.actionItems.map(
                      (item) => Padding(
                        padding: AppResponsive.vertical(4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: AppResponsive.iconMd,
                              color: Colors.green,
                            ),
                            SizedBox(width: AppResponsive.w(8)),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: AppResponsive.fontBase,
                                ),
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
            SizedBox(height: AppResponsive.gapXl),

            // Motivational Message
            Container(
              width: double.infinity,
              padding: AppResponsive.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF384256), Color(0xFF5E6D8C)],
                ),
                borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
              ),
              child: Text(
                _recommendation!.motivationalMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppResponsive.fontLg,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppResponsive.gapHuge),

            // Productivity Tips Section
            Text(
              'Tips Produktivitas',
              style: TextStyle(
                fontSize: AppResponsive.font2xl,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppResponsive.gapLg),

            ..._productivityTips
                    ?.map(
                      (tip) => Card(
                        margin: EdgeInsets.only(bottom: AppResponsive.h(12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusMd,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: AppResponsive.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            radius: AppResponsive.w(18),
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.1,
                            ),
                            child: Text(
                              tip.title.substring(0, 2),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: AppResponsive.fontSm,
                              ),
                            ),
                          ),
                          title: Text(
                            _translateTipTitle(tip.title),
                            style: TextStyle(fontSize: AppResponsive.fontBase),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _translateTipDescription(tip.description),
                                style: TextStyle(
                                  fontSize: AppResponsive.fontMd,
                                ),
                              ),
                              SizedBox(height: AppResponsive.h(4)),
                              Text(
                                '💡 ${_translateTipActionable(tip.actionable)}',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppResponsive.fontMd,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    )
                    .toList() ??
                [],
          ],
        ),
      ),
    );
  }

  // Helper methods untuk translate tips
  String _translateTipTitle(String title) {
    if (title.contains('Time Management')) {
      return '⏰ Manajemen Waktu';
    } else if (title.contains('Subject Rotation')) {
      return '📚 Rotasi Mata Pelajaran';
    } else if (title.contains('Pomodoro')) {
      return '🍅 Teknik Pomodoro';
    } else if (title.contains('Single Tasking')) {
      return '🎯 Fokus Satu Tugas';
    }
    return title;
  }

  String _translateTipDescription(String desc) {
    if (desc.contains('Eisenhower Matrix')) {
      return 'Gunakan teknik Eisenhower Matrix untuk prioritas tugas';
    } else if (desc.contains('mental fatigue')) {
      return 'Rotasi mata pelajaran untuk menghindari kelelahan mental';
    } else if (desc.contains('25 menit fokus')) {
      return '25 menit fokus + 5 menit istirahat';
    } else if (desc.contains('Fokus pada satu tugas')) {
      return 'Fokus pada satu tugas hingga selesai';
    }
    return desc;
  }

  String _translateTipActionable(String action) {
    if (action.contains('Urgent-Important')) {
      return 'Bagi tugas: Mendesak-Penting, Penting-Tidak Mendesak, dll.';
    } else if (action.contains('Berganti topik')) {
      return 'Berganti topik setiap 45-60 menit';
    } else if (action.contains('Download timer')) {
      return 'Gunakan timer Pomodoro atau stopwatch';
    } else if (action.contains('Matikan notifikasi')) {
      return 'Matikan notifikasi yang tidak penting';
    }
    return action;
  }

  Widget _buildStatChip(String label, int count, Color indicatorColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(8),
        vertical: AppResponsive.h(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppResponsive.r(12)),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppResponsive.w(8),
            height: AppResponsive.h(8),
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: AppResponsive.h(4)),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppResponsive.fontLg,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: AppResponsive.fontXs,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Gradient _getCardGradient() {
    if (_recommendation!.urgentTaskCount >= 3) {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (_recommendation!.urgentTaskCount > 0) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF384256), Color(0xFF5E6D8C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
}
