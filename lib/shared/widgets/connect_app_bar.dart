import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/entangl_colors.dart';

class ConnectAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsTap;
  final Widget? trailing;
  final Widget? leading;
  final String? title;
  final bool brandTitle;

  const ConnectAppBar({
    super.key,
    this.onSettingsTap,
    this.trailing,
    this.leading,
    this.title,
    this.brandTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(color: palette.outlineVariant, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else
            const SizedBox(width: 48),
          Expanded(
            child: Center(
              child: title != null
                  ? Text(
                      title!,
                      style: brandTitle
                          ? AppTextStyles.brandName
                          : AppTextStyles.title2.copyWith(
                              color: palette.primary,
                              fontStyle: FontStyle.italic,
                            ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text('entangl', style: AppTextStyles.brandName),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onSettingsTap != null)
            IconButton(
              onPressed: onSettingsTap,
              icon: Icon(
                Icons.settings_outlined,
                color: palette.onSurfaceVariant,
                size: 22,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
