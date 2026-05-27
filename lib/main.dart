import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/isar_service.dart';
import 'providers/isar_provider.dart';
import 'global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb || !kIsWeb) {
    // Dùng options trực tiếp cho Windows/Web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDvy6XyT4PrII7J_Wy3ATjSDdGnOnXs09o",           // client/api_key/current_key
        appId: "1:74598604410:android:520c15d2eeaf31318ae5c3",            // client/client_info/mobilesdk_app_id  
        messagingSenderId: "74598604410", // project_info/project_number
        projectId: "nutriscan-db111",    // project_info/project_id
      ),
    );
  }
  // await Firebase.initializeApp();

  // Thêm dòng này để test
  FirebaseAuth.instance.authStateChanges().listen((user) {
    print('AUTH STATE: $user');
  });

  final isar = await IsarService.init();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const NutriScanApp(),
    ),
  );
}
