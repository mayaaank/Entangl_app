import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/push_notification_service.dart';
import '../theme/app_colors.dart';

class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const AppLifecycleWrapper({super.key, required this.child});

  @override
  State<AppLifecycleWrapper> createState() =>
      _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  bool   _isOnline  = true;  // assume online until proven otherwise
  bool   _checked   = false; // don't show banner before first check
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay first check so app starts up without false banner
    Future.delayed(const Duration(seconds: 3), () {
      _checkConnectivity();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _checkConnectivity(),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivity();
      _refreshSessionSilently();
      // Keep device_tokens fresh when returning to the app.
      unawaited(PushNotificationService.instance.syncWithPreferences());
    }
  }

  Future<void> _checkConnectivity() async {
    // Try multiple hosts — if any responds, we're online
    final hosts = ['8.8.8.8', '1.1.1.1', '208.67.222.222'];
    bool online = false;

    for (final host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 5));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          online = true;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (mounted && (online != _isOnline || !_checked)) {
      setState(() {
        _isOnline = online;
        _checked  = true;
      });
    }
  }

  Future<void> _refreshSessionSilently() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final expiry =
            DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        if (expiry.isBefore(
            DateTime.now().add(const Duration(minutes: 5)))) {
          await Supabase.instance.client.auth.refreshSession();
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Don't show banner until we've done at least one check
    final showBanner = _checked && !_isOnline;

    return Column(
      children: [
        Expanded(child: widget.child),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: showBanner ? 36 : 0,
          child: showBanner
              ? Container(
                  color: AppColors.errorContainer,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'No internet connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
