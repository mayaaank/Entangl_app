import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_lifecycle.dart';
import 'core/secrets.dart';
import 'data/services/notification_service.dart';
import 'features/notifications/providers/push_bootstrap_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background isolate handler must be registered before runApp.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Supabase before any code path that may touch SupabaseService.client
  // (e.g. DeviceTokensRepository via NotificationService).
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  await NotificationService.instance.initializeLocalNotifications();

  runApp(
    const ProviderScope(
      child: EntanglApp(),
    ),
  );
}

class EntanglApp extends ConsumerWidget {
  const EntanglApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Entangl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) => PushNotificationBinder(
        child: AppLifecycleWrapper(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}