class DateHelper {
  static String getRomanMonth(int month) {
    const romanMonths = [
      '', 'I', 'II', 'III', 'IV', 'V', 'VI', 
      'VII', 'VIII', 'IX', 'X', 'XI', 'XII'
    ];
    return romanMonths[month];
  }

  static String formatCurrentTimestamp() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";
  }
}
