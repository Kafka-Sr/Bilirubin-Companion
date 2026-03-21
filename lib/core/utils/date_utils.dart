String formatShortDateTime(DateTime value) {
  final date = '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year}';
  final time = '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
  return '$date • $time';
}

String formatLongDate(DateTime value) {
  const months = [
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
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String formatAgeFromDob(DateTime dob) {
  final age = DateTime.now().difference(dob);
  final days = age.inDays;
  final hours = age.inHours.remainder(24);
  if (days <= 0) {
    return '$hours hours';
  }
  return '$days days $hours hours';
}

String formatAgeCompact(int ageHours) {
  final days = ageHours ~/ 24;
  final hours = ageHours % 24;
  return '${days}D ${_twoDigits(hours)}:${_twoDigits(0)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
