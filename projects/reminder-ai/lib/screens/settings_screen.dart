import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart' show appDarkModeNotifier;
import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../database/database_helper.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();
  final NotificationService _notificationService = NotificationService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _dailyReminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 12, minute: 0); // Tetap diperlukan untuk fungsi lain
  bool _autoDeleteCompleted = false;
  bool _isLoading = true;
  
  String _dailyReminderRingtone = 'default';
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _notificationOptions = [
    {'value': 'default', 'title': 'Sistem Default', 'desc': 'Nada dering bawaan HP', 'ext': 'wav'},
    {'value': 'alarm_classic', 'title': '⏰ Alarm Klasik', 'desc': 'Suara kencang klasik', 'ext': 'wav'},
    {'value': 'bel_sekolah', 'title': '🔔 Bel Sekolah', 'desc': 'Suara bel sekolah kencang', 'ext': 'wav'},
    {'value': 'bel_telepon', 'title': '☎️ Bel Telepon', 'desc': 'Suara telepon klasik nyaring', 'ext': 'wav'},
    {'value': 'bel_kebakaran', 'title': '🔥 Bel Kebakaran', 'desc': 'Sirine darurat kebakaran', 'ext': 'wav'},
    {'value': 'bel_chime', 'title': '🎵 Bel Chime', 'desc': 'Nada chime volume tinggi', 'ext': 'wav'},
    {'value': 'bel_darurat', 'title': '🆘 Bel Darurat', 'desc': 'Peringatan bahaya kencang', 'ext': 'wav'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _debugPreferences(); // Debug untuk cek nilai preferences
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Debug function untuk cek SharedPreferences
  Future<void> _debugPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('=== DEBUG PREFERENCES ===');
    debugPrint('🔍 All keys: ${prefs.getKeys()}');
    debugPrint('🔍 notifications_enabled: ${prefs.getBool('notifications_enabled')}');
    debugPrint('🔍 daily_reminder_enabled: ${prefs.getBool('daily_reminder_enabled')}');
    debugPrint('🔍 reminder_time: ${prefs.getString('reminder_time')}');
    debugPrint('========================');
  }

  Future<void> _loadSettings() async {
    try {
      await _settings.init();
      
      // Load SharedPreferences for additional settings
      final prefs = await SharedPreferences.getInstance();
      
      // Debug print sebelum load
      debugPrint('🔄 Loading settings...');
      
      setState(() {
        _isDarkMode = _settings.isDarkMode;
        
        // FIX: Hapus operator ?? yang tidak perlu
        _notificationsEnabled = _settings.notificationsEnabled;
        
        // Load daily reminder dengan default true jika null
        _dailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? true;
        _dailyReminderRingtone = prefs.getString('daily_reminder_ringtone') ?? 'default';
        
        _autoDeleteCompleted = _settings.autoDeleteCompleted;
        
        // Load reminder time dengan error handling
        final timeString = prefs.getString('reminder_time') ?? '12:00';
        try {
          final timeParts = timeString.split(':');
          if (timeParts.length == 2) {
            _reminderTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing reminder time: $e');
          _reminderTime = const TimeOfDay(hour: 12, minute: 0);
        }
        
        _isLoading = false;
      });
      
      // Debug print setelah load
      debugPrint('✅ Settings loaded:');
      debugPrint('   - Notifications: $_notificationsEnabled');
      debugPrint('   - Daily Reminder: $_dailyReminderEnabled');
      debugPrint('   - Reminder Time: ${_reminderTime.format(context)}');
      
      // Force rebuild untuk memastikan UI update
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
      }
      
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      setState(() {
        _isLoading = false;
        // Set default values jika error
        _notificationsEnabled = true;
        _dailyReminderEnabled = true;
        _reminderTime = const TimeOfDay(hour: 12, minute: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: AppResponsive.gapXl),
              Text('Lagi muat pengaturan...', style: GoogleFonts.outfit(fontSize: AppResponsive.fontBase)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppResponsive.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumAppearanceSection(),
                  SizedBox(height: AppResponsive.gapHuge),
                  _buildPremiumNotificationSection(),
                  SizedBox(height: AppResponsive.gapHuge),
                  _buildPremiumDataSection(),
                  SizedBox(height: AppResponsive.gapHuge),
                  _buildPremiumAboutSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: AppResponsive.h(AppResponsive.isSmall ? 100 : 120),
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: AppResponsive.w(20), bottom: AppResponsive.h(16)),
        title: Text(
          'Pengaturan',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: AppResponsive.font3xl,
            color: AppTheme.textPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.05),
                AppTheme.backgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppResponsive.w(8), bottom: AppResponsive.h(10)),
          child: Row(
            children: [
              Icon(icon, size: AppResponsive.iconMd, color: AppTheme.primaryColor),
              SizedBox(width: AppResponsive.w(10)),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: AppResponsive.fontSm,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: AppResponsive.w(20),
                offset: Offset(0, AppResponsive.h(8)),
              ),
            ],
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumAppearanceSection() {
    return _buildPremiumSection(
      title: 'Tampilan',
      icon: Icons.palette_outlined,
      children: [
        _buildPremiumSwitchTile(
          title: 'Mode Gelap',
          subtitle: 'Ganti ke tema gelap yang keren buat mata',
          icon: Icons.dark_mode_rounded,
          value: _isDarkMode,
          onChanged: (value) async {
            // Update notifier PERTAMA agar UI langsung berubah
            appDarkModeNotifier.value = value;
            AppTheme.updateThemeColors(value);
            // Update state lokal
            setState(() => _isDarkMode = value);
            // Simpan ke storage
            await _settings.setDarkMode(value);
            widget.onThemeChanged?.call(value);
            _showSuccessSnackBar('🎨 Tema berhasil diganti!');
          },
        ),
      ],
    );
  }

  Widget _buildPremiumNotificationSection() {
    return _buildPremiumSection(
      title: 'Notifikasi',
      icon: Icons.notifications_active_outlined,
      children: [
        _buildPremiumSwitchTile(
          title: 'Aktifkan Notifikasi',
          subtitle: 'Biar gak lupa sama tugas-tugas kamu',
          icon: Icons.doorbell_rounded,
          value: _notificationsEnabled,
          onChanged: (value) async {
            if (value) {
              final ok = await _notificationService.requestPermissions(context: context);
              if (!ok) return;
            }
            setState(() {
              _notificationsEnabled = value;
              if (!value) _dailyReminderEnabled = false;
            });
            await _settings.setNotificationsEnabled(value);
            if (!value) await _notificationService.cancelAllNotifications();
            _showSuccessSnackBar('🔔 Notifikasi ${value ? 'dinyalain' : 'dimatiin'}');
          },
        ),
        if (_notificationsEnabled) ...[
          const Divider(height: 1, indent: 60),
          _buildPremiumSwitchTile(
            title: 'Pengingat Harian',
            subtitle: 'Dapet ringkasan tugas tiap hari',
            icon: Icons.auto_graph_rounded,
            value: _dailyReminderEnabled,
            onChanged: (value) => _toggleDailyReminder(value),
          ),
          if (_dailyReminderEnabled) ...[
            _buildPremiumActionTile(
              title: 'Waktu Pengingat',
              subtitle: 'Dikirim setiap jam ${_reminderTime.format(context)}',
              icon: Icons.schedule_rounded,
              actionWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _reminderTime.format(context),
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: _updateReminderTime,
            ),
            const Divider(height: 1, indent: 60),
            _buildPremiumActionTile(
              title: 'Suara Pengingat',
              subtitle: _notificationOptions.firstWhere(
                (o) => o['value'] == _dailyReminderRingtone,
                orElse: () => _notificationOptions.first,
              )['title']!,
              icon: Icons.music_note_rounded,
              onTap: _showRingtoneSelector,
            ),
          ],
          const Divider(height: 1, indent: 60),
          _buildPremiumActionTile(
            title: 'Suara Sistem & Tes',
            subtitle: 'Sinkron ulang & tes suara buzzer',
            icon: Icons.volume_up_rounded,
            onTap: () async {
              await _notificationService.sendTestNotification();
              _showSuccessSnackBar('🧪 Suara tes dikirim!');
            },
          ),
        ],
      ],
    );
  }


  Widget _buildPremiumDataSection() {
    return _buildPremiumSection(
      title: 'Operasi & Data',
      icon: Icons.settings_applications_outlined,
      children: [
        _buildPremiumActionTile(
          title: 'Sinkron Ulang Jadwal',
          subtitle: 'Jadwalkan ulang seluruh notifikasi pengingat',
          icon: Icons.sync_problem_rounded,
          onTap: () async {
            final count = await _notificationService.reScheduleAllNotifications();
            _showSuccessSnackBar('🔄 Berhasil menyinkronkan ulang jadwal notifikasi untuk $count tugas aktif!');
          },
        ),
        const Divider(height: 1, indent: 60),
        _buildPremiumSwitchTile(
          title: 'Hapus Otomatis',
          subtitle: 'Bersihkan tugas selesai secara otomatis (30 hari)',
          icon: Icons.cleaning_services_rounded,
          value: _autoDeleteCompleted,
          onChanged: (value) async {
            setState(() => _autoDeleteCompleted = value);
            await _settings.setAutoDeleteCompleted(value);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('auto_delete_completed', value);

            if (value) {
              final count = await _databaseHelper.deleteCompletedTasksOlderThanDays(30);
              if (count > 0) {
                _showSuccessSnackBar('🧹 Hapus otomatis diaktifkan! $count tugas selesai (>30 hari) telah dibersihkan.');
              } else {
                _showSuccessSnackBar('🧹 Hapus otomatis diaktifkan! Tugas selesai (>30 hari) akan dibersihkan secara otomatis.');
              }
            } else {
              _showSuccessSnackBar('⏸️ Hapus otomatis dinonaktifkan.');
            }
          },
        ),
        const Divider(height: 1, indent: 60),
        _buildPremiumActionTile(
          title: 'Ringkasan Data',
          subtitle: 'Lihat statistik dan ringkasan data tugas',
          icon: Icons.bar_chart_rounded,
          onTap: _showDataSummary,
        ),
        const Divider(height: 1, indent: 60),
        _buildPremiumActionTile(
          title: 'Hapus Semua Data',
          subtitle: 'Reset aplikasi ke kondisi awal',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          onTap: _clearAllData,
        ),
      ],
    );
  }

  Widget _buildPremiumAboutSection() {
    return _buildPremiumSection(
      title: 'Tentang',
      icon: Icons.info_outline_rounded,
      children: [
        _buildPremiumActionTile(
          title: 'Tentang Aplikasi',
          icon: Icons.description_rounded,
          onTap: () {
            // Tampilkan dialog info aplikasi premium jika ditekan
            _showAppInfoDialog();
          },
        ),
        const Divider(height: 1, indent: 60),
        _buildPremiumActionTile(
          title: 'Pengembang',
          subtitle: 'Dinda Aprilla Dalimunthe',
          icon: Icons.person_rounded,
          onTap: () {
            _showSuccessSnackBar('👋 Halo dari Dinda Aprilla Dalimunthe!');
          },
        ),
        const Divider(height: 1, indent: 60),
        _buildPremiumActionTile(
          title: 'Versi Aplikasi',
          subtitle: 'v1.0.0 Stable',
          icon: Icons.verified_rounded,
        ),
        const Divider(height: 1, indent: 60),
        _buildPremiumActionTile(
          title: 'Kebijakan Privasi',
          subtitle: 'Semua data disimpan lokal secara aman di perangkat Anda.',
          icon: Icons.privacy_tip_rounded,
          onTap: () => _showSuccessSnackBar('🔒 Semua data disimpan lokal di HP kamu'),
        ),
      ],
    );
  }

  void _showAppInfoDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppResponsive.radius2xl),
            side: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
              SizedBox(width: AppResponsive.w(10)),
              Text(
                'Tentang Aplikasi',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder AI',
                style: GoogleFonts.outfit(
                  fontSize: AppResponsive.fontXl,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: AppResponsive.gapXs),
              Text(
                'Asisten belajar cerdas & pengingat inovatif untuk mengoptimalkan produktivitas harian Anda.',
                style: GoogleFonts.outfit(
                  fontSize: AppResponsive.fontMd,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: AppResponsive.gapLg),
              
              // Metode SAW
              _buildCompactInfoRow(
                icon: Icons.bar_chart_rounded,
                iconColor: AppTheme.secondaryColor,
                title: 'Metode SAW (Simple Additive Weighting)',
                desc: 'Sistem perankingan cerdas yang secara otomatis menghitung dan mengurutkan prioritas tugas berdasarkan deadline, tingkat kesulitan, dan estimasi waktu — membantu menentukan tugas mana yang paling utama untuk dikerjakan terlebih dahulu.',
              ),
              SizedBox(height: AppResponsive.gapLg),

              // Rule-Based System
              _buildCompactInfoRow(
                icon: Icons.rule_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'Rule-Based System (Sistem Berbasis Aturan)',
                desc: 'Sistem logika berbasis aturan yang memberikan rekomendasi belajar harian serta mengatur notifikasi pengingat secara tepat waktu.',
              ),
              SizedBox(height: AppResponsive.gapLg),
              
              Divider(color: AppTheme.borderColor),
              SizedBox(height: AppResponsive.gapMd),
              
              // Developer Name at the bottom
              Center(
                child: Column(
                  children: [
                    Text(
                      'Dikembangkan Oleh:',
                      style: GoogleFonts.outfit(
                        fontSize: AppResponsive.fontSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'Dinda Aprilla Dalimunthe',
                      style: GoogleFonts.outfit(
                        fontSize: AppResponsive.fontLg,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: AppResponsive.iconMd),
        SizedBox(width: AppResponsive.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: AppResponsive.fontBase,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: AppResponsive.h(2)),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: AppResponsive.fontSm,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: AppResponsive.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppResponsive.w(9)),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: AppResponsive.iconMd),
              ),
              SizedBox(width: AppResponsive.w(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: AppResponsive.fontLg,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: AppResponsive.fontSm,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppResponsive.w(10)),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? actionWidget,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppResponsive.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppResponsive.w(9)),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: AppResponsive.iconMd),
              ),
              SizedBox(width: AppResponsive.w(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: AppResponsive.fontLg,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      SizedBox(height: AppResponsive.h(2)),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: AppResponsive.fontSm,
                          color: AppTheme.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppResponsive.w(10)),
              actionWidget ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary) : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(fontSize: AppResponsive.fontBase)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppResponsive.radiusMd)),
        margin: AppResponsive.all(16),
      ),
    );
  }

  Future<void> _updateReminderTime() async {
    // Unfocus any active text inputs to dismiss the keyboard
    FocusScope.of(context).unfocus();
    TimeOfDay tempPickedTime = _reminderTime;

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
                              _reminderTime = tempPickedTime;
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

    // Save and re-schedule daily reminder
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
    await prefs.setString('reminder_time', timeString);
    await prefs.setInt('daily_reminder_hour', _reminderTime.hour);
    await prefs.setInt('daily_reminder_minute', _reminderTime.minute);
    
    if (_dailyReminderEnabled) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    }
    
    setState(() {});
    _showSuccessSnackBar('⏰ Pengingat harian diatur ke ${_reminderTime.format(context)}');
  }

  void _showRingtoneSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppResponsive.radius2xl),
                  topRight: Radius.circular(AppResponsive.radius2xl),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppResponsive.w(16),
                AppResponsive.h(20),
                AppResponsive.w(16),
                AppResponsive.h(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Nada Dering',
                        style: GoogleFonts.outfit(
                          fontSize: AppResponsive.font2xl,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _audioPlayer.stop();
                          if (mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(12)),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notificationOptions.length,
                      itemBuilder: (context, index) {
                        final option = _notificationOptions[index];
                        final isSelected = _dailyReminderRingtone == option['value'];
                        final color = isSelected ? AppTheme.primaryColor : Colors.transparent;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: AppResponsive.h(4)),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: AppResponsive.w(16), vertical: AppResponsive.h(2)),
                            title: Text(
                              option['title']!,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              option['desc']!,
                              style: GoogleFonts.outfit(
                                color: AppTheme.textSecondary,
                                fontSize: AppResponsive.fontSm,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                                : null,
                            onTap: () async {
                              setModalState(() {
                                _dailyReminderRingtone = option['value']!;
                              });
                              setState(() {
                                _dailyReminderRingtone = option['value']!;
                              });
                              
                              // Save to prefs
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('daily_reminder_ringtone', option['value']!);

                              // Play audio preview
                              final value = option['value']!;
                              final ext = option['ext']!;
                              if (value != 'default') {
                                try {
                                  await _audioPlayer.stop();
                                  await _audioPlayer.play(AssetSource('sounds/$value.$ext'));
                                } catch (e) {
                                  debugPrint('Error playing preview: $e');
                                }
                              } else {
                                await _audioPlayer.stop();
                              }
                              
                              // Re-schedule daily reminder to apply the sound
                              if (_dailyReminderEnabled) {
                                await _notificationService.scheduleDailyReminder(_reminderTime);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) async {
      await _audioPlayer.stop();
    });
  }

  Future<void> _toggleDailyReminder(bool enabled) async {
    setState(() => _dailyReminderEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', enabled);
    if (enabled) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      await _notificationService.cancelDailyReminder();
    }
    _showSuccessSnackBar(enabled ? '🔔 Pengingat harian aktif jam ${_reminderTime.format(context)}' : '🔕 Pengingat harian dimatikan');
  }

  Future<void> _clearAllData() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Semua Data?',
            style: GoogleFonts.outfit(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Semua tugas, riwayat, dan pengaturan akan dihapus permanen. Lanjutkan?',
            style: GoogleFonts.outfit(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: GoogleFonts.outfit(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Hapus',
                style: GoogleFonts.outfit(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    if (confirm == true) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }
      
      try {
        await _notificationService.cancelAllNotifications();
        await _databaseHelper.clearAllData();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await _settings.resetSettings();
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        _showSuccessSnackBar('❌ Gagal hapus data: $e');
      }
    }
  }

  Future<void> _showDataSummary() async {
    try {
      final stats = await _databaseHelper.getTaskStatistics();
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Icon(Icons.insights_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Ringkasan Data',
                  style: GoogleFonts.outfit(
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppResponsive.fontXl,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow('Total Tugas', '${stats['total']}', AppTheme.primaryColor, isDark),
                _buildStatRow('Belum Selesai', '${stats['pending']}', AppTheme.warningColor, isDark),
                _buildStatRow('Sudah Beres', '${stats['completed']}', AppTheme.successColor, isDark),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showSuccessSnackBar('❌ Gagal ambil data: $e');
    }
  }

  Widget _buildStatRow(String label, String value, Color color, [bool isDark = false]) {
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    return Padding(
      padding: AppResponsive.vertical(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                fontSize: AppResponsive.fontBase,
                color: textColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(12),
              vertical: AppResponsive.h(4),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppResponsive.r(20)),
            ),
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: AppResponsive.fontBase,
              ),
            ),
          ),
        ],
      ),
    );
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