import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Đăng ký email/password
  Future<String?> signUp(String email, String password, String name) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (res.user != null) return null;
      return 'Đăng ký thất bại';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Đăng nhập email/password
  Future<String?> signIn(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) return null;
      return 'Đăng nhập thất bại';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Đăng nhập Google
  Future<String?> signInWithGoogle() async {
    try {
      final res = await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      if (res) return null;
      return 'Đăng nhập Google thất bại';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Lấy user hiện tại
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream lắng nghe thay đổi auth state
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
