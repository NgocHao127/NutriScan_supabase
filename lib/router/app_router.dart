import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriscan/features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/add_meal_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/AI_Scan/scan_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
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
      final onboardingDone = ref.watch(onboardingDoneProvider);
      final isLoading = authState is AsyncLoading;
      final isLoggedIn = authState.value != null;

      print('=== REDIRECT: isLoggedIn=$isLoggedIn, '
          'onboarding=$onboardingDone, '
          'location=${state.matchedLocation} ===');

      // Đang load — đứng yên
      if (isLoading) return null;

      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isOnboarding = loc == '/onboarding';
      final isAuthRoute = [
        '/login',
        '/register',
        '/forgot-password',
      ].contains(loc);

      // Splash đang xử lý — không redirect
      if (isSplash) return null;

      // Đã đăng nhập → bỏ qua check onboarding
      if (isLoggedIn) {
        if (isAuthRoute || isOnboarding) return '/home';
        return null;
      }

      // Chưa xem onboarding → vào onboarding
      if (!onboardingDone && !isOnboarding) return '/onboarding';

      // Đã xem onboarding, chưa đăng nhập → login
      if (onboardingDone && !isLoggedIn && !isAuthRoute) {
        return '/login';
      }

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
          builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/add-meal',
        builder: (context, state) => AddMealScreen(
          initialMealType: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ShellRoute bọc 4 màn hình có bottom nav
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
    errorBuilder: (context, state) {
      print('=== ROUTER ERROR: ${state.matchedLocation} — ${state.error} ===');
      return Scaffold(
        body: Center(
          child: Text('Lỗi: ${state.matchedLocation}\n${state.error}'),
        ),
      );
    },
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
        selectedItemColor: AppColors
            .primary, // Đảm bảo AppColors đã được định nghĩa trong app_theme.dart
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
    _ref.listen(authStateProvider, (previous, next) {
      // Chỉ notify khi state thực sự thay đổi (không phải loading)
      if (next is! AsyncLoading) {
        notifyListeners();
      }
    });

    // Lắng nghe onboarding thay đổi để trigger redirect
    _ref.listen(onboardingDoneProvider, (previous, next) {
      if (previous != next) notifyListeners();
    });
  }
}
