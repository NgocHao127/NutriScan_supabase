// Dùng chung cho cả 3 màn hình auth
enum AuthStatus { idle, loading, success, error }

class LoginState {
  final AuthStatus status;
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;

  const LoginState({
    this.status = AuthStatus.idle,
    this.emailError,
    this.passwordError,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  LoginState copyWith({
    AuthStatus? status,
    String? emailError,
    String? passwordError,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      emailError: emailError,
      passwordError: passwordError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterState {
  final AuthStatus status;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? errorMessage;

  const RegisterState({
    this.status = AuthStatus.idle,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmError,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  RegisterState copyWith({
    AuthStatus? status,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmError,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmError: confirmError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ForgotPasswordState {
  final AuthStatus status;
  final bool emailSent;
  final String? emailError;
  final String? errorMessage;

  const ForgotPasswordState({
    this.status = AuthStatus.idle,
    this.emailSent = false,
    this.emailError,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  ForgotPasswordState copyWith({
    AuthStatus? status,
    bool? emailSent,
    String? emailError,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      emailSent: emailSent ?? this.emailSent,
      emailError: emailError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
