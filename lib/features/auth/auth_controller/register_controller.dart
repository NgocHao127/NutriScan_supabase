import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/api_provider.dart';

class RegisterController extends AutoDisposeNotifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  bool _validate(String name, String email, String password, String confirm) {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmError;

    if (name.trim().isEmpty) nameError = 'Vui lòng nhập họ tên';

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

    if (confirm.isEmpty) {
      confirmError = 'Vui lòng xác nhận mật khẩu';
    } else if (confirm != password) {
      confirmError = 'Mật khẩu không khớp';
    }

    state = state.copyWith(
      nameError:     nameError,
      emailError:    emailError,
      passwordError: passwordError,
      confirmError:  confirmError,
    );

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmError == null;
  }

  Future<bool> register(
      String name, String email, String password, String confirm) async {
    if (!_validate(name, email, password, confirm)) return false;

    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(authNotifierProvider.notifier)
          .signUpWithEmail(email.trim(), password, name.trim());

      // Đợi session
      final supabase = Supabase.instance.client;
      int attempts = 0;
      while (supabase.auth.currentSession == null && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      }
      if (supabase.auth.currentSession == null) {
        throw Exception('Không thể xác thực, vui lòng thử lại');
      }

      // Tạo profile
      await ref.read(userServiceProvider).getProfile();

      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('already registered')) msg = 'Email đã được sử dụng';
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: 'Lỗi: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> registerWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: 'Lỗi đăng ký Google: ${e.toString()}',
      );
      return false;
    }
  }
}

final registerControllerProvider =
    AutoDisposeNotifierProvider<RegisterController, RegisterState>(
  RegisterController.new,
);