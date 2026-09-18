/// تبدیل دقیق تاریخ میلادی به شمسی (جلالی) و برعکس
/// پیاده‌سازی بر پایه الگوریتم معروف jalaali (بدون وابستگی به پکیج خارجی)
library jalali_helper;

int _div(int a, int b) => a ~/ b;
int _mod(int a, int b) => a - _div(a, b) * b;

const List<int> _breaks = [
  -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210,
  1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
];

class _JalCalResult {
  final int leap;
  final int gy;
  final int march;
  _JalCalResult(this.leap, this.gy, this.march);
}

_JalCalResult _jalCal(int jy) {
  final bl = _breaks.length;
  final gy = jy + 621;
  int leapJ = -14;
  int jp = _breaks[0];
  int jump = 0;
  int i = 1;
  for (; i < bl; i++) {
    final jm = _breaks[i];
    jump = jm - jp;
    if (jy < jm) break;
    leapJ += _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
    jp = jm;
  }
  int n = jy - jp;
  leapJ += _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
  if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
  final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
  final march = 20 + leapJ - leapG;
  if (jump - n < 6) n = n - jump + _div(jump, 33) * 33;
  int leap = _mod(_mod(n + 1, 33) - 1, 4);
  if (leap == -1) leap = 4;
  return _JalCalResult(leap, gy, march);
}

int _g2d(int gy, int gm, int gd) {
  int d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
      _div(153 * _mod(gm + 9, 12) + 2, 5) +
      gd -
      34840408;
  d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
  return d;
}

class _GDate {
  final int gy, gm, gd;
  _GDate(this.gy, this.gm, this.gd);
}

_GDate _d2g(int jdn) {
  int j = 4 * jdn + 139361631;
  j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
  final i = _div(_mod(j, 1461), 4) * 5 + 308;
  final gd = _div(_mod(i, 153), 5) + 1;
  final gm = _mod(_div(i, 153), 12) + 1;
  final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
  return _GDate(gy, gm, gd);
}

int _j2d(int jy, int jm, int jd) {
  final r = _jalCal(jy);
  return _g2d(r.gy, 3, r.march) + (jm - 1) * 31 - _div(jm, 7) * (jm - 7) + jd - 1;
}

class _JDate {
  final int jy, jm, jd;
  _JDate(this.jy, this.jm, this.jd);
}

_JDate _d2j(int jdn) {
  final gy = _d2g(jdn).gy;
  int jy = gy - 621;
  final r = _jalCal(jy);
  final jdn1f = _g2d(gy, 3, r.march);
  int jd, jm, k;
  k = jdn - jdn1f;
  if (k >= 0) {
    if (k <= 185) {
      jm = 1 + _div(k, 31);
      jd = _mod(k, 31) + 1;
      return _JDate(jy, jm, jd);
    } else {
      k -= 186;
    }
  } else {
    jy -= 1;
    k += 179;
    if (r.leap == 1) k += 1;
  }
  jm = 7 + _div(k, 30);
  jd = _mod(k, 30) + 1;
  return _JDate(jy, jm, jd);
}

const List<String> jalaliMonthNames = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
];

const List<String> jalaliWeekdayNames = [
  'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه',
];

const List<String> jalaliWeekdayShort = [
  'ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج',
];

/// نمایش یک تاریخ شمسی (سال، ماه، روز) به همراه توابع کمکی
class Jalali {
  final int year;
  final int month;
  final int day;

  Jalali(this.year, this.month, this.day);

  factory Jalali.fromDateTime(DateTime dt) {
    final jdn = _g2d(dt.year, dt.month, dt.day);
    final j = _d2j(jdn);
    return Jalali(j.jy, j.jm, j.jd);
  }

  factory Jalali.now() => Jalali.fromDateTime(DateTime.now());

  DateTime toDateTime() {
    final jdn = _j2d(year, month, day);
    final g = _d2g(jdn);
    return DateTime(g.gy, g.gm, g.gd);
  }

  bool get isLeapYear => _jalCal(year).leap == 1;

  int get monthLength {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeapYear ? 30 : 29;
  }

  /// شنبه = 0 ... جمعه = 6
  int get weekday {
    final gWeekday = toDateTime().weekday; // Mon=1 ... Sun=7
    // تبدیل: شنبه(6 میلادی? ) -> در دارت: Monday=1..Sunday=7
    // می‌خواهیم شنبه=0
    final map = {6: 0, 7: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6};
    return map[gWeekday]!;
  }

  String get monthName => jalaliMonthNames[month - 1];

  String formatDate() =>
      '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';

  String formatLong() => '$day $monthName $year';

  Jalali addMonths(int delta) {
    int m = month + delta;
    int y = year;
    while (m > 12) {
      m -= 12;
      y += 1;
    }
    while (m < 1) {
      m += 12;
      y -= 1;
    }
    final tempDay = day > 29 ? 29 : day;
    final maxDay = Jalali(y, m, 1).monthLength;
    return Jalali(y, m, tempDay > maxDay ? maxDay : tempDay);
  }

  bool isSameDate(Jalali other) =>
      year == other.year && month == other.month && day == other.day;

  @override
  String toString() => formatDate();
}

String formatGregorianAsJalali(DateTime dt) => Jalali.fromDateTime(dt).formatDate();

String formatGregorianAsJalaliLong(DateTime dt) => Jalali.fromDateTime(dt).formatLong();
