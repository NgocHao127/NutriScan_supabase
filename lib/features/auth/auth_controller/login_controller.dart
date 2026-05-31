import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import '../../../providers/auth_provider.dart';

class LoginController extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  // ── Đăng nhập email ──────────────────────────────────────
  Future<bool> login(String email, String password) async {
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
