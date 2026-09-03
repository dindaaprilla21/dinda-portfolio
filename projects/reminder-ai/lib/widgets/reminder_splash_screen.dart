import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../utils/app_responsive.dart';
import '../screens/home_screen.dart';
import '../database/database_helper.dart';

class ReminderSplashScreen extends StatefulWidget {
  const ReminderSplashScreen({super.key});

  @override
  State<ReminderSplashScreen> createState() => _ReminderSplashScreenState();
}

class _ReminderSplashScreenState extends State<ReminderSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Preload database immediately
    DatabaseHelper().getAllTasks();

    // Smooth splash animation duration (650ms) with elegant fade transition into HomeScreen
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fast, crisp scale & fade animation
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 75,
                height: 75,
                fit: BoxFit.contain,
              ),
            )
                .animate()
                .scale(duration: 250.ms, curve: Curves.easeOutBack)
                .fade(duration: 200.ms),
            const SizedBox(height: 20),
            Text(
              'REMINDER AI',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppTheme.primaryColor,
              ),
            )
                .animate(delay: 50.ms)
                .fade(duration: 200.ms)
                .slideY(begin: 0.2, end: 0.0, duration: 200.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
