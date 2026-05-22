import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/features/admin/admin_screen.dart';
import 'package:bilirubin/features/admin/audit_events_screen.dart';
import 'package:bilirubin/features/admin/parent_linking_screen.dart';
import 'package:bilirubin/features/admin/user_management_screen.dart';
import 'package:bilirubin/features/admin/transfer_screen.dart';
import 'package:bilirubin/features/auth/login_screen.dart';
import 'package:bilirubin/features/dashboard/dashboard_screen.dart';
import 'package:bilirubin/features/parent/parent_dashboard_screen.dart';
import 'package:bilirubin/features/settings/settings_screen.dart';
import 'package:bilirubin/features/shared/pin_lock_screen.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/providers/sync_providers.dart';
import 'package:bilirubin/security/app_lock_service.dart';

/// A [ChangeNotifier] that fires whenever auth session or user profile change,
/// so GoRouter can re-run its redirect without recreating the entire router.
/// Also triggers pullChanges when the session transitions from null → non-null.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(supabaseSessionProvider, (prev, next) {
      final hadSession = prev?.valueOrNull != null;
      final hasSession = next.valueOrNull != null;
      if (!hadSession && hasSession) {
        // New login — pull cloud data so a fresh device isn't empty.
        ref.read(syncServiceProvider).pullChanges().catchError((_) {});
      }
      notifyListeners();
    });
    ref.listen(userProfileProvider, (_, __) => notifyListeners());
  }
}

final _appLockService = AppLockService();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: notifier,
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final session = ref.read(supabaseSessionProvider).valueOrNull;
      final isLoggedIn = session != null;

      // --- Not logged in ---
      if (!isLoggedIn) {
        return loc == '/login' ? null : '/login';
      }

      // --- Logged in on login page → go to role home ---
      if (loc == '/login') {
        final profile = ref.read(userProfileProvider).valueOrNull;
        return profile?.isParent == true ? '/parent' : '/dashboard';
      }

      final profile = ref.read(userProfileProvider).valueOrNull;

      // --- Deactivated account guard ---
      if (profile != null && !profile.isActive) {
        final client = ref.read(supabaseClientProvider);
        await client?.auth.signOut();
        return '/login?deactivated=1';
      }

      // --- Role guards ---
      if (profile != null) {
        // Parents cannot access dashboard or admin
        if (profile.isParent &&
            (loc == '/dashboard' || loc.startsWith('/admin'))) {
          return '/parent';
        }
        // Non-admins cannot access admin panel
        if (!profile.isAdmin && loc.startsWith('/admin')) {
          return '/dashboard';
        }
      }

      // --- PIN lock (staff/admin only) ---
      if (loc != '/lock' && profile?.isStaffOrAdmin == true) {
        final lockEnabled = ref.read(appLockEnabledProvider);
        if (lockEnabled) {
          final enabled = await _appLockService.isLockEnabled();
          if (enabled) return '/lock';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          deactivated:
              state.uri.queryParameters['deactivated'] == '1',
        ),
      ),
      GoRoute(
        path: '/lock',
        builder: (_, __) => const PinLockScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/parent',
        builder: (_, __) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminScreen(),
        routes: [
          GoRoute(
            path: 'accounts',
            builder: (_, __) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'parents',
            builder: (_, __) => const ParentLinkingScreen(),
          ),
          GoRoute(
            path: 'transfers',
            builder: (_, __) => const TransferScreen(),
          ),
          GoRoute(
            path: 'audit',
            builder: (_, __) => const AuditEventsScreen(),
          ),
        ],
      ),
    ],
  );
});
