import 'dart:math' as math;

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _longMonths = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String formatDisplayDate(DateTime date) {
  return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
}

String formatLongDate(DateTime date) {
  return '${date.day} ${_longMonths[date.month - 1]} ${date.year}';
}

String formatTimestamp(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${formatDisplayDate(date)} $hour:$minute';
}

String compactNumber(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

String formatWeightKg(double value) => '${compactNumber(value)} kg';

String formatBilirubinValue(double? value) {
  if (value == null) {
    return '—';
  }
  return '${compactNumber(value)} mg/dL';
}

String formatAgeHours(double? ageHours) {
  if (ageHours == null) {
    return '—';
  }
  return '${compactNumber(ageHours)} h of life';
}

String formatAgeShort(Duration age) {
  final safeAge = age.isNegative ? Duration.zero : age;
  final days = safeAge.inDays;
  final hours = safeAge.inHours.remainder(24);
  if (days == 0) {
    return '${hours}h';
  }
  return '${days}d ${hours}h';
}

String formatAgeVerbose(Duration age) {
  final safeAge = age.isNegative ? Duration.zero : age;
  final days = safeAge.inDays;
  final hours = safeAge.inHours.remainder(24);
  return '$days days $hours hours';
}

String sanitizeBabyName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

double? parseSafeDouble(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}

String? validateBabyName(String? value) {
  final candidate = sanitizeBabyName(value ?? '');
  if (candidate.isEmpty) {
    return 'Enter a baby name.';
  }
  if (candidate.length > 48) {
    return 'Keep the name under 48 characters.';
  }
  if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(candidate)) {
    return 'Remove unsupported characters.';
  }
  return null;
}

String? validateWeightKg(String? value) {
  final parsed = parseSafeDouble(value ?? '');
  if (parsed == null) {
    return 'Enter a valid weight in kilograms.';
  }
  if (parsed < 0.4 || parsed > 8.0) {
    return 'Use a reasonable neonatal weight.';
  }
  return null;
}

String? validateDateOfBirth(DateTime? value) {
  if (value == null) {
    return 'Select a date of birth.';
  }
  if (value.isAfter(DateTime.now())) {
    return 'Date of birth cannot be in the future.';
  }
  return null;
}

double nextNiceTickAbove(double value) {
  if (value <= 23) {
    return 23;
  }
  return (math.max(25, (value / 5).ceil() * 5)).toDouble();
}

extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T item) predicate) {
    for (final item in this) {
      if (predicate(item)) {
        return item;
      }
    }
    return null;
  }
}
