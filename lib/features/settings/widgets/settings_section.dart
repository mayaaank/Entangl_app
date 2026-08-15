import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';

/// Reusable settings card — theme tokens only.
class SettingsSection extends StatelessWidget {
  final String label;
  final List<Widget> rows;
  final Color? labelColor;

  const SettingsSection({
    super.key,
    required this.label,
    required this.rows,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: labelColor ?? palette.onSurfaceVariant,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.outline, width: 1.5),
            boxShadow: palette.shadowCard,
          ),
          child: Material(
            color: palette.surfaceLowest,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      leading: Icon(icon, color: palette.primary, size: 22),
      title: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: palette.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSmall.copyWith(
          color: palette.onSurfaceVariant,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: palette.primary,
      ),
    );
  }
}

class SettingsSubToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsSubToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: palette.primary,
          ),
        ],
      ),
    );
  }
}

class SettingsChevronRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsChevronRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      leading: Icon(icon, color: palette.primary, size: 22),
      title: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: palette.onSurface),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: AppTextStyles.labelSmall.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right,
        color: palette.outline,
      ),
      onTap: onTap,
    );
  }
}

class SettingsDangerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  const SettingsDangerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = muted ? palette.error.withValues(alpha: 0.55) : palette.error;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}
