import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/api_service.dart';
import 'api_provider.dart';

// Provider FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Stream auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// AuthNotifier để thực hiện signIn/signOut
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth;
  final ApiService _api;

  AuthNotifier(this._auth, this._api) : super(const AsyncLoading()) {
    // Lắng nghe auth state
    _auth.authStateChanges().listen((user) {
      state = AsyncData(user);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AsyncData(null);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final idToken = await user.getIdToken();
        // Gọi API backend để tạo/sync user trong Supabase
        await _api.login(idToken!);
      }
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final apiService = ref.watch(apiServiceProvider); // cần định nghĩa apiServiceProvider
  return AuthNotifier(auth, apiService);
});