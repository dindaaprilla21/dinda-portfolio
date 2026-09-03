import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../models/task_model.dart';
import '../utils/app_responsive.dart';
import 'package:audioplayers/audioplayers.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // Untuk edit mode
  final Function(Task)? onTaskAdded;

  const AddTaskScreen({super.key, this.task, this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedDifficulty = 3; // 1-5: Sangat Mudah - Sangat Sulit
  double _estimatedHours = 1.0; // Estimasi jam
  String _selectedSchedule = 'default';

  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Notification Options
  final List<Map<String, String>> _notificationOptions = [
    {'value': 'default', 'title': 'Sistem Default', 'desc': 'Nada dering bawaan HP', 'ext': 'wav'},
    {'value': 'alarm_classic', 'title': '⏰ Alarm Klasik', 'desc': 'Suara kencang klasik', 'ext': 'wav'},
    {'value': 'bel_sekolah', 'title': '🔔 Bel Sekolah', 'desc': 'Suara bel sekolah kencang', 'ext': 'wav'},
    {'value': 'bel_telepon', 'title': '☎️ Bel Telepon', 'desc': 'Suara telepon klasik nyaring', 'ext': 'wav'},
    {'value': 'bel_kebakaran', 'title': '🔥 Bel Kebakaran', 'desc': 'Sirine darurat kebakaran', 'ext': 'wav'},
    {'value': 'bel_chime', 'title': '🎵 Bel Chime', 'desc': 'Nada chime volume tinggi', 'ext': 'wav'},
    {'value': 'bel_darurat', 'title': '🆘 Bel Darurat', 'desc': 'Peringatan bahaya kencang', 'ext': 'wav'},
  ];

  // Difficulty labels
  final List<Map<String, dynamic>> _difficultyLevels = [
    {'value': 1, 'label': 'Sangat Mudah', 'color': Colors.green},
    {'value': 2, 'label': 'Mudah', 'color': Colors.lightGreen},
    {'value': 3, 'label': 'Sedang', 'color': Colors.orange},
    {'value': 4, 'label': 'Sulit', 'color': Colors.deepOrange},
    {'value': 5, 'label': 'Sangat Sulit', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final task = widget.task!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedDate = task.deadline;
    _selectedTime = TimeOfDay.fromDateTime(task.deadline);
    _selectedDifficulty = task.difficultyLevel;
    _estimatedHours = task.estimatedHours;

    final dbSchedule = task.notificationSchedule;
    if (_notificationOptions.any((opt) => opt['value'] == dbSchedule)) {
      _selectedSchedule = dbSchedule;
    } else {
      final voiceFormat = 'voice_$dbSchedule';
      if (_notificationOptions.any((opt) => opt['value'] == voiceFormat)) {
        _selectedSchedule = voiceFormat;
      } else {
        _selectedSchedule = 'default';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.task != null ? 'Edit Tugas' : 'Tambah Tugas',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppResponsive.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    SizedBox(height: AppResponsive.h(24)),
                    _buildDescriptionSection(),
                    SizedBox(height: AppResponsive.h(24)),
                    _buildDateTimeSection(),
                    SizedBox(height: AppResponsive.h(24)),
                    _buildDifficultySection(),
                    SizedBox(height: AppResponsive.h(24)),
                    _buildEstimationSection(),
                    SizedBox(height: AppResponsive.h(24)),
                    _buildNotificationScheduleSection(),
                    SizedBox(height: AppResponsive.h(32)),
                    _buildActionButtons(),
                    SizedBox(height: AppResponsive.h(32)),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: AppResponsive.onlyBottom(12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppResponsive.w(9)),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: AppResponsive.iconMd,
            ),
          ),
          SizedBox(width: AppResponsive.w(12)),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: AppResponsive.fontLg,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Judul Tugas', Icons.title_rounded),
        TextFormField(
          controller: _titleController,
          style: TextStyle(
            fontSize: AppResponsive.fontBase,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Apa yang ingin Anda kerjakan?',
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.6),
              fontSize: AppResponsive.fontBase,
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              borderSide: BorderSide(
                  color: AppTheme.textSecondary.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              borderSide:
                  BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            prefixIcon: Icon(Icons.assignment_rounded,
                size: AppResponsive.iconMd),
            contentPadding: AppResponsive.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Judul tugas tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Deskripsi', Icons.notes_rounded),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          style: TextStyle(fontSize: AppResponsive.fontBase),
          decoration: InputDecoration(
            hintText: 'Tambahkan detail atau catatan khusus...',
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.6),
              fontSize: AppResponsive.fontBase,
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              borderSide: BorderSide(
                  color: AppTheme.textSecondary.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              borderSide:
                  BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: AppResponsive.h(60)),
              child: Icon(Icons.description_rounded,
                  size: AppResponsive.iconMd),
            ),
            contentPadding: AppResponsive.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    final isSmallScreen = AppResponsive.isSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Deadline', Icons.calendar_today_rounded),
        isSmallScreen
            ? Column(
                children: [
                  _buildDatePicker(),
                  SizedBox(height: AppResponsive.h(10)),
                  _buildTimePicker(),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: _buildDatePicker()),
                  SizedBox(width: AppResponsive.w(12)),
                  Expanded(flex: 2, child: _buildTimePicker()),
                ],
              ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      child: Container(
        padding: AppResponsive.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          border:
              Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded,
                color: AppTheme.primaryColor, size: AppResponsive.iconMd),
            SizedBox(width: AppResponsive.w(10)),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(_selectedDate),
                style: TextStyle(
                  fontSize: AppResponsive.fontBase,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary, size: AppResponsive.iconSm),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      child: Container(
        padding: AppResponsive.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          border:
              Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded,
                color: AppTheme.primaryColor, size: AppResponsive.iconMd),
            SizedBox(width: AppResponsive.w(10)),
            Expanded(
              child: Text(
                _selectedTime.format(context),
                style: TextStyle(
                  fontSize: AppResponsive.fontBase,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary, size: AppResponsive.iconSm),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    final currentDifficulty = _difficultyLevels[_selectedDifficulty - 1];
    final diffColor = currentDifficulty['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tingkat Kesulitan', Icons.speed_rounded),
        Container(
          padding: AppResponsive.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
            border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: AppResponsive.w(16),
                offset: Offset(0, AppResponsive.h(8)),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sangat Mudah',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSm,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Sangat Sulit',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSm,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.gapXl),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppResponsive.h(8),
                  activeTrackColor: diffColor,
                  inactiveTrackColor: diffColor.withOpacity(0.15),
                  thumbColor: Colors.white,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: AppResponsive.w(12),
                    elevation: 6,
                    pressedElevation: 8,
                  ),
                  overlayColor: diffColor.withOpacity(0.1),
                ),
                child: Slider(
                  value: _selectedDifficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) =>
                      setState(() => _selectedDifficulty = value.round()),
                ),
              ),
              SizedBox(height: AppResponsive.gapXl),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.w(24),
                  vertical: AppResponsive.h(10),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [diffColor.withOpacity(0.85), diffColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppResponsive.r(30)),
                  boxShadow: [
                    BoxShadow(
                      color: diffColor.withOpacity(0.4),
                      blurRadius: AppResponsive.w(12),
                      offset: Offset(0, AppResponsive.h(6)),
                    ),
                  ],
                ),
                child: Text(
                  currentDifficulty['label'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppResponsive.fontLg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstimationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Estimasi Pengerjaan', Icons.av_timer_rounded),
        Container(
          padding: AppResponsive.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
            border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: AppResponsive.w(16),
                offset: Offset(0, AppResponsive.h(8)),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '30 menit',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSm,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '8 jam',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSm,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.gapXl),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppResponsive.h(8),
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor:
                      AppTheme.primaryColor.withOpacity(0.15),
                  thumbColor: Colors.white,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: AppResponsive.w(12),
                    elevation: 6,
                    pressedElevation: 8,
                  ),
                ),
                child: Slider(
                  value: _estimatedHours,
                  min: 0.5,
                  max: 8.0,
                  divisions: 15,
                  onChanged: (value) =>
                      setState(() => _estimatedHours = value),
                ),
              ),
              SizedBox(height: AppResponsive.gapXl),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.w(24),
                  vertical: AppResponsive.h(10),
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppResponsive.r(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.35),
                      blurRadius: AppResponsive.w(12),
                      offset: Offset(0, AppResponsive.h(6)),
                    ),
                  ],
                ),
                child: Text(
                  _formatEstimation(_estimatedHours),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppResponsive.fontLg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatEstimation(double hours) {
    if (hours < 1) return '${(hours * 60).round()} menit';
    if (hours == hours.roundToDouble()) return '${hours.round()} jam';
    final fullHours = hours.floor();
    final minutes = ((hours - fullHours) * 60).round();
    return '$fullHours jam $minutes menit';
  }

  Widget _buildNotificationScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Suara Notifikasi', Icons.library_music_rounded),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(16),
            vertical: AppResponsive.h(8),
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius:
                BorderRadius.circular(AppResponsive.radiusLg),
            border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSchedule,
              isExpanded: true,
              itemHeight: AppResponsive.h(64).clamp(60.0, 80.0),
              icon: Icon(
                Icons.arrow_drop_down_circle_rounded,
                color: AppTheme.primaryColor,
                size: AppResponsive.iconMd,
              ),
              items: _notificationOptions.map((option) {
                final isSelected = _selectedSchedule == option['value'];
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option['title']!,
                        style: TextStyle(
                          fontSize: AppResponsive.fontBase,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option['desc']!,
                        style: TextStyle(
                          fontSize: AppResponsive.fontSm,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _selectedSchedule = value);
                  final selectedOpt = _notificationOptions
                      .firstWhere((o) => o['value'] == value);
                  final ext = selectedOpt['ext']!;
                  if (value != 'default') {
                    try {
                      await _audioPlayer.stop();
                      await _audioPlayer
                          .play(AssetSource('sounds/$value.$ext'));
                    } catch (e) {
                      debugPrint('Error playing preview: $e');
                    }
                  } else {
                    await _audioPlayer.stop();
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppResponsive.h(16)),
              side: BorderSide(
                  color: AppTheme.textSecondary.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppResponsive.radiusLg)),
            ),
            child: Text(
              'BATAL',
              style: GoogleFonts.outfit(
                fontSize: AppResponsive.fontLg,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(width: AppResponsive.w(16)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius:
                  BorderRadius.circular(AppResponsive.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: AppResponsive.w(12),
                  offset: Offset(0, AppResponsive.h(6)),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: AppResponsive.h(16)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppResponsive.radiusLg)),
              ),
              child: Text(
                'SIMPAN',
                style: GoogleFonts.outfit(
                  fontSize: AppResponsive.fontLg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => child!,
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    // Unfocus any active text inputs to dismiss the keyboard
    FocusScope.of(context).unfocus();
    TimeOfDay tempPickedTime = _selectedTime;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false, // Prevents keyboard from shrinking Scaffold and causing layout overflow
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Minimalist Header
                  Padding(
                    padding: EdgeInsets.only(top: AppResponsive.h(40)),
                    child: Text(
                      'Pilih Waktu',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // The flat wheel picker (lurus, tidak melengkung)
                  Center(
                    child: FlatTimePicker(
                      initialTime: tempPickedTime,
                      onTimeChanged: (TimeOfDay newTime) {
                        tempPickedTime = newTime;
                      },
                    ),
                  ),
                  
                  // Bottom action buttons (floating directly on black background)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppResponsive.w(24),
                      0,
                      AppResponsive.w(24),
                      AppResponsive.h(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.08),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: AppResponsive.h(16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: AppResponsive.fontLg,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppResponsive.w(16)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTime = tempPickedTime;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: AppResponsive.h(16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Simpan',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: AppResponsive.fontLg,
                              ),
                            ),
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
      },
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final deadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    int calculatedPriority = 2;
    if (_selectedDifficulty >= 4) {
      calculatedPriority = 3;
    } else if (_selectedDifficulty <= 2) {
      calculatedPriority = 1;
    }

    final newTask = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: deadline,
      category: widget.task?.category ?? 'lainnya',
      priority: calculatedPriority,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      difficultyLevel: _selectedDifficulty,
      estimatedHours: _estimatedHours,
      notificationSchedule: _selectedSchedule,
    );

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (widget.onTaskAdded != null) {
        await widget.onTaskAdded!(newTask);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.task != null
                ? '✅ Tugas berhasil diperbarui!'
                : '✅ Tugas baru berhasil ditambahkan!',
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd)),
        ),
      );
      Navigator.pop(context, newTask);
    });
  }
}

class FlatTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const FlatTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<FlatTimePicker> createState() => _FlatTimePickerState();
}

class _FlatTimePickerState extends State<FlatTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onChanged() {
    widget.onTimeChanged(TimeOfDay(hour: _selectedHour, minute: _selectedMinute));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour Wheel (Flat)
        SizedBox(
          width: AppResponsive.w(120),
          height: AppResponsive.h(330),
          child: CupertinoPicker(
            scrollController: _hourController,
            itemExtent: 140,
            looping: true, // Looping endlessly (00 -> 23 -> 00)
            diameterRatio: 15.0, // Large diameter ratio makes it completely flat (lurus)
            backgroundColor: Colors.black,
            offAxisFraction: 0.0,
            selectionOverlay: const SizedBox.shrink(),
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedHour = index;
              });
              _onChanged();
            },
            children: List.generate(24, (index) {
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
        
        // Spacing between Hour Wheel and Dot
        SizedBox(width: AppResponsive.w(32)),

        // Separator Dot (Perfect Circle Container matching the screenshot)
        Container(
          width: AppResponsive.w(10),
          height: AppResponsive.w(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),

        // Spacing between Dot and Minute Wheel
        SizedBox(width: AppResponsive.w(32)),

        // Minute Wheel (Flat)
        SizedBox(
          width: AppResponsive.w(120),
          height: AppResponsive.h(330),
          child: CupertinoPicker(
            scrollController: _minuteController,
            itemExtent: 140,
            looping: true, // Looping endlessly (00 -> 59 -> 00)
            diameterRatio: 15.0, // Large diameter ratio makes it completely flat (lurus)
            backgroundColor: Colors.black,
            offAxisFraction: 0.0,
            selectionOverlay: const SizedBox.shrink(),
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedMinute = index;
              });
              _onChanged();
            },
            children: List.generate(60, (index) {
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
