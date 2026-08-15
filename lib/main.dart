import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';
import 'core/utils/app_lifecycle.dart';
import 'core/secrets.dart';
import 'data/services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background FCM isolate (Android). Must be registered before runApp.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  // FCM permission + token → device_tokens (Android only; no-op elsewhere).
  await PushNotificationService.instance.initialize();

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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Entangl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,

      // Wrap the entire navigator in the lifecycle wrapper so
      // the offline banner and session refresh cover all screens.
      builder: (context, child) => AppLifecycleWrapper(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}