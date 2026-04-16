import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/features/dashboard/dashboard_screen.dart';
import 'package:bilirubin/features/settings/settings_screen.dart';
import 'package:bilirubin/features/shared/pin_lock_screen.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/security/app_lock_service.dart';

final _appLockService = AppLockService();

final routerProvider = Provider<GoRouter>((ref) {
  final lockEnabled = ref.watch(appLockEnabledProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      // If lock is not enabled, never redirect to /lock.
      if (!lockEnabled) return null;
      // Allow the lock screen itself through.
      if (state.matchedLocation == '/lock') return null;
      // Check if lock is enabled in secure storage (authoritative source).
      final enabled = await _appLockService.isLockEnabled();
      if (enabled) return '/lock';
      return null;
    },
    routes: [
      GoRoute(
        path: '/lock',
        builder: (_, __) => const PinLockScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
});
