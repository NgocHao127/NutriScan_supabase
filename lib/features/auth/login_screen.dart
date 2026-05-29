import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/responsive_layout.dart';

import 'auth_controller/auth_state.dart';
import 'auth_controller/login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    // Lắng nghe kết quả
    ref.listen(loginControllerProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        context.go('/home');
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Theme(
      // Ép light mode cho toàn màn hình auth — tránh lỗi dark mode
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        resizeToAvoidBottomInset: true,
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(context, state, controller),
          tablet: _buildTabletLayout(context, state, controller),
          desktop: _buildDesktopLayout(context, state, controller),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, LoginState state, LoginController controller) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            const AuthHeader(
              icon: AuthHeaderIcon(icon: Icons.person_outline_rounded),
              title: 'Chào mừng trở lại',
              subtitle: 'Đăng nhập để tiếp tục',
            ),
            const SizedBox(height: 10),
            _buildForm(context, state, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
      BuildContext context, LoginState state, LoginController controller) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              const AuthHeader(
                icon: AuthHeaderIcon(icon: Icons.person_outline_rounded),
                title: 'Chào mừng trở lại',
                subtitle: 'Đăng nhập để tiếp tục',
              ),
              _buildForm(context, state, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, LoginState state, LoginController controller) {
    return Row(
      children: [
        Expanded(child: _buildDesktopBanner()),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsetsGeometry.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      icon: AuthHeaderIcon(icon: Icons.person_outline_rounded),
                      title: 'Chào mừng trở lại',
                      subtitle: 'Đăng nhập để tiếp tục hành trình',
                    ),
                    const SizedBox(height: 20),
                    _buildForm(context, state, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryMid, AppColors.primaryAccent],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'NutriScan',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Theo dõi dinh dưỡng thông minh\nchỉ với một lần quét.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
      BuildContext context, LoginState state, LoginController controller) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(context.hPad, 10, context.hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthInput(
            label: 'Email',
            placeholder: 'minhkhoa@gmail.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            errorText: state.emailError,
          ),
          const SizedBox(height: 14),
          AuthInput(
            label: 'Mật khẩu',
            placeholder: '••••••••',
            controller: _passwordCtrl,
            isPassword: true,
            errorText: state.passwordError,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/forgot-password'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: context.fs(13),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          AuthButton(
            label: 'Đăng nhập',
            onPressed: () => controller.login(
              _emailCtrl.text,
              _passwordCtrl.text,
            ),
            isLoading: state.isLoading,
          ),
          const SizedBox(height: 16),
          const OrDivider(),
          const SizedBox(height: 20),
          GoogleButton(
            label: 'Tiếp tục với Google',
            onPressed: controller.loginWithGoogle,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chưa có tài khoản? ',
                style: TextStyle(
                  fontSize: context.fs(13),
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/register'),
                child: Text(
                  'Đăng ký ngay',
                  style: TextStyle(
                    fontSize: context.fs(13),
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
