import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/core/app_router.dart';
import 'package:bilirubin/core/app_theme.dart';
import 'package:bilirubin/core/supabase_config.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    if (kDebugMode) {
      debugPrint('No .env file found. Create one at the project root.');
    }
  }

  final supabaseConfig = SupabaseConfig.fromDotEnv();

  if (supabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: supabaseConfig.url,
      anonKey: supabaseConfig.anonKey,
    );
  } else if (kDebugMode) {
    debugPrint(
        'Supabase not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in .env.');
  }

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
