import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange.map((data) {
    print(
        '=== AUTH STREAM: ${data.event} user=${data.session?.user?.email} ===');
    return data.session?.user;
  });
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AsyncLoading()) {
    state = AsyncData(_supabase.auth.currentUser);
    _supabase.auth.onAuthStateChange.listen((data) {
      state = AsyncData(data.session?.user);
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // lưu name vào metadata
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(supabaseClientProvider));
});
