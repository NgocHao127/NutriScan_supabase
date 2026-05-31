// Dùng chung cho cả 3 màn hình auth
enum AuthStatus { idle, loading, success, error }

class LoginState {
  final AuthStatus status;
  final String? errorMessage;

  const LoginState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  LoginState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterState {
  final AuthStatus status;
  final String? errorMessage;

  const RegisterState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  RegisterState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ForgotPasswordState {
  final AuthStatus status;
  final bool emailSent;
  final String? errorMessage;

  const ForgotPasswordState({
    this.status = AuthStatus.idle,
    this.emailSent = false,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  ForgotPasswordState copyWith({
    AuthStatus? status,
    bool? emailSent,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      emailSent: emailSent ?? this.emailSent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
