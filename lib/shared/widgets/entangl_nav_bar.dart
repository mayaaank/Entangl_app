import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Floating pill nav matching Stitch home feed:
/// Home · Search · Create(+) · Notifications · Profile
class EntanglNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCreateLongPress;

  /// Index map: 0=home, 1=search, 2=create, 3=notifications, 4=profile
  const EntanglNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreateLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 16,
        right: 16,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.inkMid,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderCard, width: 2),
          boxShadow: AppColors.shadowFloat,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavIcon(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavIcon(
              icon: Icons.search_rounded,
              activeIcon: Icons.search_rounded,
              label: 'Search',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _CreateButton(
              onTap: () => onTap(2),
              onLongPress: onCreateLongPress,
            ),
            _NavIcon(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications_rounded,
              label: 'Notifications',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavIcon(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _CreateButton({required this.onTap, this.onLongPress});

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTapDown: (_) =>
            _controller.animateTo(0.92, curve: Curves.easeOutQuad),
        onTapUp: (_) {
          _controller.animateTo(1.0, curve: Curves.elasticOut);
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onTapCancel: () =>
            _controller.animateTo(1.0, curve: Curves.easeOutQuad),
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: Semantics(
          button: true,
          label: 'Create post',
          child: Tooltip(
            message: 'Create',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cream100,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderCard, width: 2),
                boxShadow: AppColors.shadowDoodle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.textOnCream,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
