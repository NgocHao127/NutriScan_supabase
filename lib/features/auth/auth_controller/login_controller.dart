import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import '../../../providers/auth_provider.dart';

class LoginController extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  // ── Validate ─────────────────────────────────────────────
  bool _validate(String email, String password) {
    String? emailError;
    String? passwordError;

    if (email.trim().isEmpty) {
      emailError = 'Vui lòng nhập email';
    } else if (!email.contains('@')) {
      emailError = 'Email không hợp lệ';
    }

    if (password.isEmpty) {
      passwordError = 'Vui lòng nhập mật khẩu';
    } else if (password.length < 6) {
      passwordError = 'Mật khẩu tối thiểu 6 ký tự';
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
    );

    return emailError == null && passwordError == null;
  }

  // ── Đăng nhập email ──────────────────────────────────────
  Future<bool> login(String email, String password) async {
    if (!_validate(email, password)) return false;

    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .signInWithEmail(email.trim(), password);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Đăng nhập Google ─────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi đăng nhập Google: ${e.toString()}',
      );
      return false;
    }
  }
}

final loginControllerProvider =
    AutoDisposeNotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
