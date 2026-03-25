import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/core/app_router.dart';
import 'package:bilirubin/core/app_theme.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BilirubinApp(),
    ),
  );
}

class BilirubinApp extends ConsumerWidget {
  const BilirubinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly activate the device→storage bridge.
    ref.watch(measurementBridgeProvider);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Bilirubin Monitor',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
