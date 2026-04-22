import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/features/auth/login_screen.dart';
import 'package:bilirubin/features/dashboard/dashboard_screen.dart';
import 'package:bilirubin/features/parent/parent_dashboard_screen.dart';
import 'package:bilirubin/features/admin/admin_screen.dart';
import 'package:bilirubin/features/admin/staff_management_screen.dart';
import 'package:bilirubin/features/admin/parent_linking_screen.dart';
import 'package:bilirubin/features/admin/transfer_screen.dart';
import 'package:bilirubin/features/settings/settings_screen.dart';
import 'package:bilirubin/features/shared/pin_lock_screen.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/providers/user_profile_provider.dart';
import 'package:bilirubin/security/app_lock_service.dart';

final _appLockService = AppLockService();

const _authRoutes = {'/login'};

final routerProvider = Provider<GoRouter>((ref) {
  final lockEnabled = ref.watch(appLockEnabledProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      if (!isLoggedIn && !_authRoutes.contains(location)) return '/login';
      if (isLoggedIn && _authRoutes.contains(location)) {
        return await _homeForCurrentUser(ref);
      }

      // Role-based guard: parents cannot access staff routes.
      if (isLoggedIn && location == '/dashboard') {
        final profile = await ref.read(userProfileProvider.future);
        if (profile != null && profile.isParent) return '/parent';
      }

      // App lock check (staff only — parents don't have PIN lock).
      if (!lockEnabled) return null;
      if (location == '/lock') return null;
      final enabled = await _appLockService.isLockEnabled();
      if (enabled) return '/lock';

      return null;
    },
    routes: [
      GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/lock',   builder: (_, __) => const PinLockScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/parent',    builder: (_, __) => const ParentDashboardScreen()),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminScreen(),
        routes: [
          GoRoute(path: 'staff',     builder: (_, __) => const StaffManagementScreen()),
          GoRoute(path: 'parents',   builder: (_, __) => const ParentLinkingScreen()),
          GoRoute(path: 'transfers', builder: (_, __) => const TransferScreen()),
        ],
      ),
      GoRoute(path: '/settings',  builder: (_, __) => const SettingsScreen()),
    ],
  );
});

Future<String> _homeForCurrentUser(Ref ref) async {
  final profile = await ref.read(userProfileProvider.future);
  if (profile == null) return '/dashboard';
  if (profile.isParent) return '/parent';
  return '/dashboard';
}
