import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:nutriscan_be/providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/home/home_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/AI_Scan/scan_screen.dart';
import '../features/profile/profile_screen.dart';
import '../global.dart';

import '../features/theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    navigatorKey: navigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);
      final isLoading = authState is AsyncLoading;
      final isLoggedIn = authState is AsyncData && authState.value != null;

      // final userProfileAsync = ref.read(userProfileProvider);
      // final hasCompletedOnboarding =
      //     userProfileAsync is AsyncData &&
      //     userProfileAsync.value?.name != null &&
      //     userProfileAsync.value?.age != null;

      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = [
        '/login',
        '/register',
        '/forgot-password',
      ].contains(state.matchedLocation);
      // final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // if (isLoading) return isSplash ? null : '/splash';
      // if (!isLoggedIn) return isAuthRoute || isSplash ? null : '/login';
      if (isLoading) return null; // Bỏ kẹt splash, để stream tự resolve
      if (!isLoggedIn) return isAuthRoute ? null : '/login';
      // if (!hasCompletedOnboarding && !isOnboardingRoute) return '/onboarding';
      // Đã đăng nhập, không cho vào splash/auth
      // if (isSplash || isAuthRoute || isOnboardingRoute) return '/home';
      if (isSplash || isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Thêm ShellRoute bọc 4 màn hình có bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(
              path: '/scan', builder: (context, state) => const ScanScreen()),
          GoRoute(
              path: '/diary', builder: (context, state) => const DiaryScreen()),
          GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Không tìm thấy trang'))),
  );
});

// Widget Shell chứa BottomNavigationBar
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/home':
        return 0;
      case '/scan':
        return 1;
      case '/diary':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/scan');
              break;
            case 2:
              context.go('/diary');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'AI Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Nhật ký',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  final Ref _ref;

  _AuthChangeNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) => notifyListeners());
  }
}
