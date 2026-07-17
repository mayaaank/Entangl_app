import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool   _isOnline  = true;
  bool   _checked   = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    }
  }

  Future<void> _checkConnectivity() async {
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
    final showBanner = _checked && !_isOnline;
    // Reserve space so floating bottom nav is not covered by the banner.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bannerReserve = showBanner ? 36.0 + bottomInset + 8 : 0.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(bottom: bannerReserve > 0 ? 36 : 0),
            child: widget.child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            offset: showBanner ? Offset.zero : const Offset(0, 1),
            child: Material(
              color: AppColors.dislike,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
