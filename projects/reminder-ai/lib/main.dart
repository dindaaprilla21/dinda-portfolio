import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/home_screen.dart';
import 'widgets/reminder_splash_screen.dart';
import 'themes/app_theme.dart';
import 'models/app_settings.dart';
import 'services/notification_service.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Global notifier agar perubahan tema bisa di-listen di mana pun
final ValueNotifier<bool> appDarkModeNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.remove();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize settings
  AppSettings().init();

  // Baca tema secepat mungkin dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  appDarkModeNotifier.value = isDark;
  AppTheme.updateThemeColors(isDark);

  // Start UI immediately
  runApp(const MyApp());

  // Background initialization of notification service after UI launch
  Future.microtask(() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.reScheduleAllNotifications();
    } catch (e) {
      debugPrint('Background notification init error: $e');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen ke notifier, langsung setState tanpa delay
    appDarkModeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    // setState secara synchronous agar transisi tema instan
    setState(() {});
  }

  @override
  void dispose() {
    appDarkModeNotifier.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed');
        break;
      case AppLifecycleState.paused:
        debugPrint('📱 App paused');
        break;
      case AppLifecycleState.detached:
        debugPrint('📱 App detached');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appDarkModeNotifier.value ? ThemeMode.dark : ThemeMode.light,
      home: const ReminderSplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}