import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
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
      final isLoading = authState is AsyncLoading;

      // KIỂM TRA ĐĂNG NHẬP KIỂU SUPABASE:
      final isLoggedIn = authState.value != null;

      print(
          '=== REDIRECT: isLoggedIn=$isLoggedIn, location=${state.matchedLocation} ===');

      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = [
        '/login',
        '/register',
        '/forgot-password',
      ].contains(state.matchedLocation);

      // Đang tải thì đứng im chờ stream resolve
      if (isLoading) return null;

      // Chưa đăng nhập mà vào màn hình khác auth/splash -> Đẩy về login
      if (!isLoggedIn) return isAuthRoute ? null : '/login';

      // Đã đăng nhập mà cố vào auth/splash -> Đẩy vào trang chủ
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
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Không tìm thấy trang')),
    ),
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
    // Phải listen authStateProvider, không phải authNotifierProvider
    _ref.listen(authStateProvider, (previous, next) {
      print('=== AUTH CHANGED: ${next.value} ===');
      notifyListeners();
    });
  }
}
