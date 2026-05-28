import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

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
      // Tạo local server lắng nghe callback
      final server = await HttpServer.bind('localhost', 8888);

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:8888', // cho Windows desktop
      );

      // Đợi request từ browser
      await for (final request in server) {
        final uri = request.requestedUri;
        print('=== CALLBACK: $uri ===');

        // Trả về trang thành công cho browser
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write(
              '<html><body><h2>Đăng nhập thành công! Quay lại app.</h2></body></html>');
        await request.response.close();

        // Exchange code lấy session
        if (uri.queryParameters.containsKey('code')) {
          await _supabase.auth.exchangeCodeForSession(
            uri.queryParameters['code']!,
          );
        }

        await server.close();
        break;
      }
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
