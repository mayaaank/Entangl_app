import 'package:entangl_app/core/theme/app_theme.dart';
import 'package:entangl_app/features/settings/screens/privacy_settings_screen.dart';
import 'package:entangl_app/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings lists appearance, notifications, and account actions',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Privacy Settings'), findsOneWidget);
    expect(find.text('Change Email'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
  });

  testWidgets('change password opens a working sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Change Password'));
    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    expect(find.text('Update password'), findsOneWidget);
    expect(find.text('Current password'), findsOneWidget);
    expect(find.text('New password'), findsOneWidget);
  });

  testWidgets('privacy screen explains visibility and sessions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PrivacySettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Sign out other devices'), findsOneWidget);
    expect(
      find.textContaining('Profiles, scraps, and follows are public'),
      findsOneWidget,
    );
  });
}
