import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/entangl_colors.dart';

class ConnectNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ConnectNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        28,
        0,
        28,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: context.palette.navDock,
          borderRadius: BorderRadius.circular(999),
          boxShadow: context.palette.shadowFloat,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DockItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _DockItem(
              icon: Icons.notes_outlined,
              activeIcon: Icons.notes_rounded,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _DockItem(
              icon: Icons.favorite_border_rounded,
              activeIcon: Icons.favorite_rounded,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _DockItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 64,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? context.palette.navActive : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? context.palette.onSurface
                  : context.palette.navInactive,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
