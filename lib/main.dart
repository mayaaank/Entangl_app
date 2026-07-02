import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_lifecycle.dart';
import 'core/secrets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:   Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ConnectApp()));
}

class ConnectApp extends ConsumerWidget {
  const ConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title:            'Connect',
      debugShowCheckedModeBanner: false,
      theme:            AppTheme.dark,
      routerConfig:     router,
      // Wrap the entire navigator in the lifecycle wrapper so
      // the offline banner and session refresh cover all screens.
      builder: (context, child) => AppLifecycleWrapper(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
