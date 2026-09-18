/// تبدیل اعداد لاتین به فارسی برای نمایش یکدست در کل اپ
const List<String> _faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

String faNum(Object? input) {
  if (input == null) return '';
  final s = input.toString();
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    final code = ch.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      buffer.write(_faDigits[code - 48]);
    } else {
      buffer.write(ch);
    }
  }
  return buffer.toString();
}

String faTime(int hour, int minute) =>
    '${faNum(hour.toString().padLeft(2, '0'))}:${faNum(minute.toString().padLeft(2, '0'))}';

/// سلام مناسب ساعت روز
String greetingForNow([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 5) return 'شب بخیر';
  if (h < 12) return 'صبح بخیر';
  if (h < 17) return 'ظهر بخیر';
  if (h < 20) return 'عصر بخیر';
  return 'شب بخیر';
}
