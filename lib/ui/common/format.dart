const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String monthName(int month) => _months[(month - 1).clamp(0, 11)];

/// "Nov 10" (adds the year when it differs from now).
/// Dates are calendar days stored at UTC midnight; format them in UTC so
/// a negative local offset never shows the previous day.
String shortDate(DateTime d, {DateTime? now}) {
  final u = d.toUtc();
  final n = (now ?? DateTime.now()).toUtc();
  final base = '${_months[u.month - 1]} ${u.day}';
  return u.year == n.year ? base : '$base, ${u.year}';
}

/// "Nov 10 → Dec 1", "From Nov 10", "Due Dec 1" or "" when undated.
String dateRange(DateTime? start, DateTime? end, {DateTime? now}) {
  if (start == null && end == null) return '';
  if (start == null) return 'Due ${shortDate(end!, now: now)}';
  if (end == null) return 'From ${shortDate(start, now: now)}';
  return '${shortDate(start, now: now)} → ${shortDate(end, now: now)}';
}
