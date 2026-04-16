import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bilirubin/core/constants.dart';

// ── SharedPreferences singleton ───────────────────────────────────────────────

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError(
          'sharedPreferencesProvider must be overridden in ProviderScope.',
        ));

// ── Theme mode ────────────────────────────────────────────────────────────────

class _ThemeModeNotifier extends StateNotifier<ThemeMode> {
  _ThemeModeNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences p) {
    final v = p.getString(kPrefThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == v,
      orElse: () => ThemeMode.system,
    );
  }

  void set(ThemeMode mode) {
    state = mode;
    _prefs.setString(kPrefThemeMode, mode.name);
  }
}

final appThemeModeProvider =
    StateNotifierProvider<_ThemeModeNotifier, ThemeMode>((ref) {
  return _ThemeModeNotifier(ref.watch(sharedPreferencesProvider));
});

// ── Locale ────────────────────────────────────────────────────────────────────

class _LocaleNotifier extends StateNotifier<Locale> {
  _LocaleNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static const _supported = ['en', 'id', 'de'];

  static Locale _load(SharedPreferences p) {
    final v = p.getString(kPrefLocale);
    if (v != null && _supported.contains(v)) return Locale(v);
    return const Locale('en');
  }

  void set(Locale locale) {
    state = locale;
    _prefs.setString(kPrefLocale, locale.languageCode);
  }
}

final appLocaleProvider = StateNotifierProvider<_LocaleNotifier, Locale>((ref) {
  return _LocaleNotifier(ref.watch(sharedPreferencesProvider));
});

// ── Pi LAN endpoint ──────────────────────────────────────────────────────────

class _PiBaseUrlNotifier extends StateNotifier<String> {
  _PiBaseUrlNotifier(this._prefs)
      : super(_prefs.getString(kPrefPiBaseUrl) ?? '');

  final SharedPreferences _prefs;

  String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }

  void set(String value) {
    final normalized = _normalize(value);
    state = normalized;
    _prefs.setString(kPrefPiBaseUrl, normalized);
  }

  void clear() {
    state = '';
    _prefs.remove(kPrefPiBaseUrl);
  }
}

final piBaseUrlProvider =
    StateNotifierProvider<_PiBaseUrlNotifier, String>((ref) {
  return _PiBaseUrlNotifier(ref.watch(sharedPreferencesProvider));
});

// ── App lock toggle ───────────────────────────────────────────────────────────

/// Simple in-memory flag for whether the lock screen should be shown.
/// The authoritative "lock enabled" state lives in flutter_secure_storage
/// (read by [AppLockService.isLockEnabled]); this mirrors it at runtime.
final appLockEnabledProvider = StateProvider<bool>((ref) => false);
