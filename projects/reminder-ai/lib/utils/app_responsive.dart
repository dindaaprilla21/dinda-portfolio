import 'package:flutter/material.dart';

/// Helper class responsif terpusat untuk Reminder AI.
/// Baseline desain: lebar 390px (iPhone 14 / Galaxy S22).
/// Semua ukuran di-scale secara proporsional dari baseline tersebut.
class AppResponsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _scaleWidth;
  static late double _scaleHeight;
  static late double _scaleFont;
  static late double safeAreaTop;
  static late double safeAreaBottom;

  /// Referensi baseline desain (iPhone 14 / Galaxy S22)
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  /// Inisialisasi dari context. Panggil di awal setiap build method.
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    // Avoid shrinking height when keyboard opens, which causes massive layout recalculations and lag
    screenHeight = _mediaQueryData.size.height + _mediaQueryData.viewInsets.bottom;
    safeAreaTop = _mediaQueryData.padding.top;
    safeAreaBottom = _mediaQueryData.padding.bottom;
    _scaleWidth = screenWidth / _designWidth;
    _scaleHeight = screenHeight / _designHeight;
    _scaleFont = _scaleWidth.clamp(0.75, 1.25);
  }

  /// Font size responsif (diclamp agar tidak terlalu kecil/besar)
  static double sp(double size) => (size * _scaleFont).clamp(size * 0.75, size * 1.3);

  /// Lebar responsif
  static double w(double size) => size * _scaleWidth;

  /// Tinggi responsif
  static double h(double size) => size * _scaleHeight;

  /// Radius responsif (menggunakan scale rata-rata)
  static double r(double size) => size * ((_scaleWidth + _scaleHeight) / 2).clamp(0.8, 1.2);

  /// Padding responsif semua sisi
  static EdgeInsets all(double size) => EdgeInsets.all(w(size));

  /// Padding responsif simetris
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: w(horizontal),
      vertical: h(vertical),
    );
  }

  /// Padding responsif dari LTRB
  static EdgeInsets fromLTRB(double l, double t, double r, double b) {
    return EdgeInsets.fromLTRB(w(l), h(t), w(r), h(b));
  }

  /// Padding hanya horizontal
  static EdgeInsets horizontal(double size) =>
      EdgeInsets.symmetric(horizontal: w(size));

  /// Padding hanya vertical
  static EdgeInsets vertical(double size) =>
      EdgeInsets.symmetric(vertical: h(size));

  /// Hanya padding kiri
  static EdgeInsets onlyLeft(double size) => EdgeInsets.only(left: w(size));

  /// Hanya padding kanan
  static EdgeInsets onlyRight(double size) => EdgeInsets.only(right: w(size));

  /// Hanya padding atas
  static EdgeInsets onlyTop(double size) => EdgeInsets.only(top: h(size));

  /// Hanya padding bawah
  static EdgeInsets onlyBottom(double size) => EdgeInsets.only(bottom: h(size));

  // ==========================================
  // Breakpoints
  // ==========================================

  /// Layar kecil: lebar < 360px
  static bool get isSmall => screenWidth < 360;

  /// Layar medium: 360 ≤ lebar < 480px (kebanyakan Android/iOS)
  static bool get isMedium => screenWidth >= 360 && screenWidth < 480;

  /// Layar besar/tablet: lebar ≥ 480px
  static bool get isLarge => screenWidth >= 480;

  // ==========================================
  // Shortcut ukuran umum
  // ==========================================

  /// Horizontal padding standar halaman
  static double get pagePaddingH => w(isSmall ? 14 : 16);

  /// Vertical padding standar halaman
  static double get pagePaddingV => h(isSmall ? 16 : 20);

  /// Ukuran icon standar
  static double get iconSm => w(isSmall ? 16 : 18);
  static double get iconMd => w(isSmall ? 20 : 22);
  static double get iconLg => w(isSmall ? 24 : 28);
  static double get iconXl => w(isSmall ? 32 : 36);

  /// Font size preset
  static double get fontXs => sp(isSmall ? 9 : 10);
  static double get fontSm => sp(isSmall ? 11 : 12);
  static double get fontMd => sp(isSmall ? 13 : 14);
  static double get fontBase => sp(isSmall ? 14 : 15);
  static double get fontLg => sp(isSmall ? 15 : 16);
  static double get fontXl => sp(isSmall ? 16 : 18);
  static double get font2xl => sp(isSmall ? 18 : 20);
  static double get font3xl => sp(isSmall ? 20 : 22);
  static double get font4xl => sp(isSmall ? 22 : 24);

  /// Radius preset
  static double get radiusSm => r(8);
  static double get radiusMd => r(12);
  static double get radiusLg => r(16);
  static double get radiusXl => r(20);
  static double get radius2xl => r(24);
  static double get radius3xl => r(32);

  /// Jarak / gap
  static double get gapXs => h(4);
  static double get gapSm => h(6);
  static double get gapMd => h(8);
  static double get gapLg => h(12);
  static double get gapXl => h(16);
  static double get gapXxl => h(20);
  static double get gapHuge => h(24);

  /// Grid childAspectRatio untuk 2-column stats (berdasarkan lebar aktual)
  static double get statCardAspectRatio {
    // Lebar tiap cell: (layar - padding kiri/kanan - gap antar kolom) / 2
    final cellWidth = (screenWidth - pagePaddingH * 2 - w(12)) / 2;
    // Tinggi ideal compact stat card (absolute untuk menghindari overflow pada layar pendek)
    final cellHeight = isSmall ? 54.0 : (isMedium ? 58.0 : 64.0);
    return cellWidth / cellHeight;
  }
}
