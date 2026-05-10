/// Converts raw exceptions into short, user-readable messages.
///
/// Supabase throws [FunctionException], [PostgrestException], and plain
/// [Exception]s with verbose internal details. This strips them to a single
/// sentence the user can act on.
String friendlyError(Object e) {
  final raw = e.toString();

  // Supabase FunctionException: "FunctionException(status: 400, details: ...)"
  if (raw.contains('FunctionException')) {
    final details = _extract(raw, 'details: ', ')');
    if (details != null) return _cleanJson(details);
  }

  // Supabase PostgrestException: "PostgrestException(message: ..., ...)"
  if (raw.contains('PostgrestException')) {
    final msg = _extract(raw, 'message: ', ',') ??
        _extract(raw, 'message: ', ')');
    if (msg != null) return msg.trim();
  }

  // AuthException / generic: strip class prefix "ExceptionType: message"
  final colonIdx = raw.indexOf(': ');
  if (colonIdx != -1 && colonIdx < 40) {
    final after = raw.substring(colonIdx + 2).trim();
    if (after.isNotEmpty) return _truncate(after);
  }

  return _truncate(raw);
}

String? _extract(String src, String start, String end) {
  final s = src.indexOf(start);
  if (s == -1) return null;
  final from = s + start.length;
  final e = src.indexOf(end, from);
  if (e == -1) return src.substring(from);
  return src.substring(from, e).trim();
}

String _cleanJson(String s) {
  // If the details string looks like {"error":"…"} or {"message":"…"}, extract value.
  final match = RegExp(r'"(?:error|message)"\s*:\s*"([^"]+)"').firstMatch(s);
  if (match != null) return match.group(1)!;
  return _truncate(s);
}

String _truncate(String s, [int max = 120]) =>
    s.length > max ? '${s.substring(0, max)}…' : s;
