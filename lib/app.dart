import 'package:bilirubin_companion/core/theme.dart';
import 'package:bilirubin_companion/features/dashboard/dashboard_page.dart';
import 'package:bilirubin_companion/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BilirubinApp extends ConsumerWidget {
  const BilirubinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Bilirubin Companion',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: mode,
      home: const DashboardPage(),
    );
  }
}
