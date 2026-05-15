import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../chat/chat_screen.dart';
import '../home/home_screen.dart';
import '../results/results_screen.dart';
import '../history/history_screen.dart';
import '../history/reading_detail_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../settings/settings_screen.dart';
import '../trends/trends_screen.dart';
import 'app_shell.dart';

/// FlutterSecureStorage key: set to `'true'` when onboarding is finished.
const kOnboardingCompleteKey = 'onboarding_complete';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    _sub = ref.read(authServiceProvider).authStateStream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  final auth = ref.read(authServiceProvider);
  const storage = FlutterSecureStorage();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) async {
      final loc = state.uri.path;
      final user = auth.currentUser;

      Future<bool> onboardingDone() async {
        try {
          final v = await storage.read(key: kOnboardingCompleteKey);
          return v == 'true';
        } catch (_) {
          // On platforms where secure storage isn't available, don't block.
          return true;
        }
      }

      bool isPublicWhileLoggedOut(String path) {
        return path == '/auth/login' ||
            path == '/auth/register' ||
            path == '/auth/forgot';
      }

      bool isAuthRoute(String path) {
        return path.startsWith('/auth/');
      }

      if (user == null) {
        // Splash shows branding then navigates to login itself (~2s).
        if (loc == '/splash') return null;
        if (isPublicWhileLoggedOut(loc)) return null;
        return '/auth/login';
      }

      final done = await onboardingDone();
      if (!done) {
        if (loc == '/onboarding') return null;
        return '/onboarding';
      }

      if (loc == '/splash' || isAuthRoute(loc)) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ReadingDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trends',
                builder: (context, state) => const TrendsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/results/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            ResultsScreen(readingId: state.pathParameters['id']!),
      ),
    ],
  );
});
