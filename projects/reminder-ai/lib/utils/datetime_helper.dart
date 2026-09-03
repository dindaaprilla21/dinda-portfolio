class DateTimeHelper {
  /// Mengembalikan representasi teks sisa waktu menuju deadline secara konsisten.
  static String formatRemainingTime(DateTime deadline, DateTime now) {
    if (now.isAfter(deadline)) {
      final diff = now.difference(deadline);
      if (diff.inDays > 0) {
        return '${diff.inDays} hari terlambat';
      }
      return 'Terlambat';
    }

    // Hitung perbedaan hari berdasarkan tanggal kalender (midnight)
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    final daysDiff = deadlineDay.difference(today).inDays;

    if (daysDiff > 1) {
      return '$daysDiff hari lagi';
    } else if (daysDiff == 1) {
      return 'Besok';
    } else {
      final diff = deadline.difference(now);
      if (diff.inHours > 0) {
        return '${diff.inHours} jam lagi';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit lagi';
      } else {
        return 'sekarang';
      }
    }
  }

  /// Mengecek apakah deadline sudah lewat.
  static bool isOverdue(DateTime deadline, DateTime now) {
    return now.isAfter(deadline);
  }
}
