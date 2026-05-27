import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'providers/sync_provider.dart';

class NutriScanApp extends ConsumerWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kích hoạt SyncService ngầm (lắng nghe mạng & đồng bộ)
    ref.watch(syncServiceProvider);
    
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'NutriScan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFEEF4EA),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
