import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import 'mascot_widgets.dart';

class EntanglNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EntanglNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        height: 64,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background warm ink card
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inkMid.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 0.5,
                      ),
                      boxShadow: AppColors.shadowFloat,
                    ),
                  ),
                ),
              ),
            ),
            // Navigation row
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                    activeCharacter: const GhostMascot(
                      expression: GhostExpression.dancing,
                      size: 20,
                    ),
                  ),
                  _CreateButton(onTap: () => onTap(1)),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                    activeCharacter: const FrogMascot(
                      expression: FrogExpression.sitting,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final Widget activeCharacter;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.activeCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isActive)
              Positioned(
                top: -24,
                child: activeCharacter
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    )
                    .moveY(begin: 12, end: 0, duration: 300.ms, curve: Curves.easeOutBack),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: isActive
                      ? AppColors.cream100
                      : AppColors.textTertiary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  width: isActive ? 6 : 0,
                  height: isActive ? 6 : 0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cream60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton> with SingleTickerProviderStateMixin {
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

  void _handleTapDown(TapDownDetails details) {
    _controller.animateTo(0.92, curve: Curves.easeOutQuad);
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.animateTo(1.0, curve: Curves.elasticOut);
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.animateTo(1.0, curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cream100,
            shape: BoxShape.circle,
            boxShadow: AppColors.shadowFloat,
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.textOnCream,
            size: 28,
          ),
        ),
      ),
    );
  }
}
