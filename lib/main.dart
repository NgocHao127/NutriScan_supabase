import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'package:app_links/app_links.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo notification service
  await NotificationService().init();

  await Supabase.initialize(
    url: 'https://weuomrbfzfbiisncqtnz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndldW9tcmJmemZiaWlzbmNxdG56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNzk3NDAsImV4cCI6MjA5NDk1NTc0MH0.g2DQHeM-8J4HezQ5sRSdre_M-eeqOlWfHDhWFCARqQg',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Lắng nghe deep link từ browser
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) async {
    if (uri.queryParameters.containsKey('code')) {
      await Supabase.instance.client.auth.exchangeCodeForSession(
        uri.queryParameters['code']!,
      );
    }
  });

  // Subscribe auth stream
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    print('=== MAIN AUTH: ${data.event} ===');
  });

  runApp(
    const ProviderScope(
      child: NutriScanApp(),
    ),
  );
}
