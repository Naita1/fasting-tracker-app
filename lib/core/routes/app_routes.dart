import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/fasting/screens/fasting_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/meals/screens/meals_screen.dart';
import '../../features/shell/screens/main_shell_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String fasting = '/fasting';
  static const String meals = '/meals';
  static const String history = '/history';
  static const String dashboard = '/dashboard';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: fasting,
                pageBuilder: (context, state) => const NoTransitionPage(child: FastingScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: meals,
                pageBuilder: (context, state) => const NoTransitionPage(child: MealsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: history,
                pageBuilder: (context, state) => const NoTransitionPage(child: HistoryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}