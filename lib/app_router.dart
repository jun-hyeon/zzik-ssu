import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/features/settings/settings_screen.dart';
import 'package:zzik_ssu/features/splash/splash_screen.dart';
import 'package:zzik_ssu/features/stats/stats_screen.dart';
import 'package:zzik_ssu/features/transaction/data/model/transaction_model.dart';
import 'package:zzik_ssu/features/transaction/presentation/add_transaction_screen.dart';
import 'package:zzik_ssu/features/transaction/presentation/home_screen.dart';
import 'package:zzik_ssu/features/transaction/presentation/transaction_detail_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
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
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
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
        path: '/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final transaction = state.extra as Transaction;
          return TransactionDetailScreen(transaction: transaction);
        },
      ),
    ],
  );
}

class ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        // Map logical branch index to visual tab index
        selectedIndex: _getSelectedIndex(navigationShell.currentIndex),
        onDestinationSelected: (index) {
          _onItemTapped(context, index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: '촬영',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(int currentIndex) {
    // Branch 0 (Home)     -> Tab 0
    // Branch 1 (Stats)    -> Tab 2 (Visual Index)
    // Branch 2 (Settings) -> Tab 3 (Visual Index)
    if (currentIndex == 1) {
      return 2;
    }
    if (currentIndex == 2) {
      return 3;
    }
    return currentIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        navigationShell.goBranch(
          0,
          initialLocation: 0 == navigationShell.currentIndex,
        );
        break;
      case 1: // Scan (Action)
        context.push('/add');
        break;
      case 2: // Stats
        navigationShell.goBranch(
          1,
          initialLocation: 1 == navigationShell.currentIndex,
        );
        break;
      case 3: // Settings
        navigationShell.goBranch(
          2,
          initialLocation: 2 == navigationShell.currentIndex,
        );
        break;
    }
  }
}
