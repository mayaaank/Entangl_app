import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'gradient_text.dart';

class ConnectAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsTap;
  final Widget? trailing;
  final Widget? leading;
  final String? title;

  const ConnectAppBar({
    super.key,
    this.onSettingsTap,
    this.trailing,
    this.leading,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: preferredSize.height + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: AppColors.inkMid.withOpacity(0.85),
            border: const Border(
              bottom: BorderSide(
                color: AppColors.borderSubtle,
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 8,
          ),
          child: Row(
            children: [
              if (leading != null) leading!,
              const SizedBox(width: 8),
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.title2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                )
              else
                GradientText(
                  'Connect',
                  style: AppTextStyles.brandName,
                ),
              const Spacer(),
              if (trailing != null)
                trailing!
              else if (onSettingsTap != null)
                IconButton(
                  onPressed: onSettingsTap,
                  icon: const Icon(Icons.settings_outlined,
                      color: AppColors.cream100, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
