import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../home/home_screen.dart' as home;
import '../results/results_screen.dart';

/// Central app router configuration (go_router).
///
/// Notes:
/// - Auth is provided by [AppAuthController]. This avoids assuming Firebase (or
///   any backend) is wired up yet.
/// - Onboarding completion is stored in FlutterSecureStorage under
///   key [onboardingCompleteKey].
/// - This file currently includes minimal placeholder screens so the app
///   compiles even if your feature UIs haven’t been implemented yet.
class AppRouter {
  factory AppRouter({
    AppAuthController? authController,
    FlutterSecureStorage? secureStorage,
  }) {
    final auth = authController ?? AppAuthController();
    final storage = secureStorage ?? const FlutterSecureStorage();
    return AppRouter._(auth: auth, storage: storage);
  }

  AppRouter._({required AppAuthController auth, required FlutterSecureStorage storage})
      : _auth = auth,
        _storage = storage,
        _refresh = _RouterRefreshNotifier(auth);

  static const onboardingCompleteKey = 'onboarding_complete';

  final AppAuthController _auth;
  final FlutterSecureStorage _storage;
  final _RouterRefreshNotifier _refresh;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _refresh,
    redirect: (context, state) async {
      final location = state.matchedLocation;

      final isSplash = location == '/splash';
      final isAuthRoute = location.startsWith('/auth/');
      final isOnboarding = location == '/onboarding';

      final isAuthenticated = _auth.isAuthenticated;
      final onboardingComplete = await _isOnboardingComplete();

      // Allow splash to always render (useful while Firebase initializes).
      if (isSplash) return null;

      // Not authenticated + non-auth route -> /auth/login
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      if (isAuthenticated) {
        // Authenticated + onboarding not done -> /onboarding
        if (!onboardingComplete && !isOnboarding) {
          return '/onboarding';
        }

        // If onboarding done, don't let user stay on onboarding.
        if (onboardingComplete && isOnboarding) {
          return '/';
        }

        // Authenticated + auth route -> /
        if (isAuthRoute) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => LoginScreen(auth: _auth),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => RegisterScreen(auth: _auth),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          onComplete: () async {
            await _setOnboardingComplete(true);
            _refresh.notify();
            if (context.mounted) context.go('/');
          },
        ),
      ),

      /// App shell (bottom tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const home.HomeScreen(),
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
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Non-tab, non-auth routes
      GoRoute(
        path: '/results/:id',
        builder: (context, state) => ResultsScreen(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );

  Future<bool> _isOnboardingComplete() async {
    final v = await _storage.read(key: onboardingCompleteKey);
    return v == 'true';
  }

  Future<void> _setOnboardingComplete(bool value) async {
    await _storage.write(
      key: onboardingCompleteKey,
      value: value ? 'true' : 'false',
    );
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._auth) {
    _auth.addListener(notifyListeners);
  }

  final AppAuthController _auth;

  void notify() => notifyListeners();

  @override
  void dispose() {
    _auth.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Temporary auth controller until real auth is implemented.
///
/// Replace this with your actual auth state (Riverpod/Firebase/your backend)
/// and keep the [Listenable] behavior so routing can refresh.
class AppAuthController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (_isAuthenticated == value) return;
    _isAuthenticated = value;
    notifyListeners();
  }
}

/// Bottom-tab shell used for the main authenticated area.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_TabSpec>[
    _TabSpec(label: 'Home', icon: Icons.home),
    _TabSpec(label: 'History', icon: Icons.history),
    _TabSpec(label: 'Trends', icon: Icons.show_chart),
    _TabSpec(label: 'Settings', icon: Icons.settings),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: [
          for (final t in _tabs)
            BottomNavigationBarItem(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// Placeholder screens (replace with your real UIs as you build them).
// ---------------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off routing immediately. Redirects will send the user to the correct
    // place (login/onboarding/home).
    scheduleMicrotask(() {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.auth});

  final AppAuthController auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => auth.setAuthenticated(true),
          child: const Text('Mock sign in'),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.auth});

  final AppAuthController auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => auth.setAuthenticated(true),
          child: const Text('Mock register + sign in'),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Forgot Password');
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: ElevatedButton(
          onPressed: onComplete,
          child: const Text('Complete onboarding'),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'History');
  }
}

class ReadingDetailScreen extends StatelessWidget {
  const ReadingDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return _SimpleScaffold(title: 'Reading Detail: $id');
  }
}

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Trends');
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Settings');
  }
}

class _SimpleScaffold extends StatelessWidget {
  const _SimpleScaffold({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

