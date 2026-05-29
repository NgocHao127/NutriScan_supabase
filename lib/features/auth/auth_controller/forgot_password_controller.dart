import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart';

class ForgotPasswordController
    extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  bool _validate(String email) {
    if (email.trim().isEmpty) {
      state = state.copyWith(emailError: 'Vui lòng nhập email');
      return false;
    }
    if (!email.contains('@')) {
      state = state.copyWith(emailError: 'Email không hợp lệ');
      return false;
    }
    state = state.copyWith(emailError: null);
    return true;
  }

  Future<bool> sendResetEmail(String email) async {
    if (!_validate(email)) return false;

    state = state.copyWith(status: AuthStatus.loading);
    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(email.trim());
      state = state.copyWith(
        status:    AuthStatus.success,
        emailSent: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status:     AuthStatus.error,
        emailError: 'Không thể gửi email. Vui lòng thử lại.',
      );
      return false;
    }
  }
}

final forgotPasswordControllerProvider = AutoDisposeNotifierProvider
    <ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);