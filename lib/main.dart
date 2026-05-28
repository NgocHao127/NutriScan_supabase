import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://weuomrbfzfbiisncqtnz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndldW9tcmJmemZiaWlzbmNxdG56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNzk3NDAsImV4cCI6MjA5NDk1NTc0MH0.g2DQHeM-8J4HezQ5sRSdre_M-eeqOlWfHDhWFCARqQg',
  );

  runApp(
    const ProviderScope(
      child: NutriScanApp(),
    ),
  );
}