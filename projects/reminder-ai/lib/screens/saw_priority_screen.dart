import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/saw_service.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';
import '../utils/datetime_helper.dart';

class SAWPriorityScreen extends StatefulWidget {
  final List<Task> tasks;

  const SAWPriorityScreen({super.key, required this.tasks});

  @override
  State<SAWPriorityScreen> createState() => _SAWPriorityScreenState();
}

class _SAWPriorityScreenState extends State<SAWPriorityScreen> {
  final SAWService _sawService = SAWService();
  List<SAWResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateSAW();
  }

  void _calculateSAW() {
    setState(() => _isLoading = true);

    try {
      final results = _sawService.calculatePriority(widget.tasks);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Prioritas Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppResponsive.fontXl,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _buildEmptyState()
              : _buildRankingView(),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: AppResponsive.iconXl * 2, color: AppTheme.textSecondary),
          SizedBox(height: AppResponsive.gapXl),
          Text(
            'Belum ada tugas pending',
            style: TextStyle(
              fontSize: AppResponsive.fontXl,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppResponsive.gapMd),
          Text(
            'Tambah tugas dulu untuk melihat prioritas',
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

  // ==========================================
  // RANKING VIEW (clean, no tabs)
  // ==========================================
  Widget _buildRankingView() {
    return SingleChildScrollView(
      padding: AppResponsive.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          SizedBox(height: AppResponsive.gapXl),
          _buildBarChart(),
          SizedBox(height: AppResponsive.gapXl),
          Text(
            'Urutan Prioritas',
            style: TextStyle(
              fontSize: AppResponsive.fontLg,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppResponsive.gapLg),
          ...List.generate(_results.length, (index) {
            return _buildRankingCard(_results[index], index);
          }),
          SizedBox(height: AppResponsive.gapXl),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final highPriority = _results.where((r) => r.sawScore >= 0.65).length;
    final mediumPriority =
        _results.where((r) => r.sawScore >= 0.35 && r.sawScore < 0.65).length;
    final lowPriority = _results.where((r) => r.sawScore < 0.35).length;

    return Container(
      width: double.infinity,
      padding: AppResponsive.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF384256), Color(0xFF5E6D8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF384256).withOpacity(0.3),
            blurRadius: AppResponsive.w(12),
            offset: Offset(0, AppResponsive.h(4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: AppResponsive.iconLg),
              SizedBox(width: AppResponsive.w(8)),
              Expanded(
                child: Text(
                  'Analisis Prioritas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppResponsive.font2xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.gapXl),
          Text(
            '${_results.length} tugas dianalisis',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppResponsive.fontMd,
            ),
          ),
          SizedBox(height: AppResponsive.gapLg),
          Row(
            children: [
              _buildMiniStat('🔴 Tinggi', highPriority),
              SizedBox(width: AppResponsive.w(10)),
              _buildMiniStat('🟠 Sedang', mediumPriority),
              SizedBox(width: AppResponsive.w(10)),
              _buildMiniStat('🟢 Rendah', lowPriority),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int count) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppResponsive.h(7),
          horizontal: AppResponsive.w(6),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppResponsive.fontXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppResponsive.h(2)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppResponsive.fontXs,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_results.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: AppResponsive.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppResponsive.w(10),
            offset: Offset(0, AppResponsive.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Skor Prioritas',
            style: TextStyle(
              fontSize: AppResponsive.fontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppResponsive.gapXl),
          ...List.generate(_results.length, (index) {
            final result = _results[index];
            final barWidth = result.sawScore;
            return Padding(
              padding: AppResponsive.onlyBottom(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: AppResponsive.w(22),
                        child: Text(
                          '#${result.ranking}',
                          style: TextStyle(
                            fontSize: AppResponsive.fontXs,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: AppResponsive.w(4)),
                      Expanded(
                        child: Text(
                          result.task.title,
                          style: TextStyle(fontSize: AppResponsive.fontSm),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        result.sawScore.toStringAsFixed(4),
                        style: TextStyle(
                          fontSize: AppResponsive.fontXs,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(result.sawScore),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(4)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppResponsive.r(4)),
                    child: LinearProgressIndicator(
                      value: barWidth,
                      backgroundColor:
                          AppTheme.textSecondary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(result.sawScore),
                      ),
                      minHeight: AppResponsive.h(7),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRankingCard(SAWResult result, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppResponsive.h(8)),
      elevation: index == 0 ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
        side: index == 0
            ? BorderSide(color: _getScoreColor(result.sawScore), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: AppResponsive.all(12),
        child: Row(
          children: [
            Container(
              width: AppResponsive.w(40),
              height: AppResponsive.h(40),
              decoration: BoxDecoration(
                color: _getScoreColor(result.sawScore).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${result.ranking}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(result.sawScore),
                    fontSize: AppResponsive.fontMd,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppResponsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppResponsive.fontBase,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppResponsive.h(4)),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.w(7),
                          vertical: AppResponsive.h(2),
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(result.sawScore)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppResponsive.r(10)),
                        ),
                        child: Text(
                          '${result.priorityEmoji} ${result.priorityLabel}',
                          style: TextStyle(
                            color: _getScoreColor(result.sawScore),
                            fontWeight: FontWeight.w500,
                            fontSize: AppResponsive.fontXs,
                          ),
                        ),
                      ),
                      SizedBox(width: AppResponsive.w(6)),
                      Icon(Icons.schedule,
                          size: AppResponsive.fontSm,
                          color: AppTheme.textSecondary),
                      SizedBox(width: AppResponsive.w(3)),
                      Expanded(
                        child: Text(
                          _formatDeadline(result.task.deadline),
                          style: TextStyle(
                            fontSize: AppResponsive.fontXs,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  result.sawScore.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: AppResponsive.fontLg,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(result.sawScore),
                  ),
                ),
                Text(
                  'skor',
                  style: TextStyle(
                    fontSize: AppResponsive.fontXs,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  Color _getScoreColor(double score) {
    if (score >= 0.75) return Colors.red.shade600;
    if (score >= 0.50) return Colors.orange.shade700;
    if (score >= 0.25) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  String _formatDeadline(DateTime deadline) {
    return DateTimeHelper.formatRemainingTime(deadline, DateTime.now());
  }
}
