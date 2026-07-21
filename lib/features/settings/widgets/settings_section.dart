import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Settings card container — white outlined paper card.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: labelColor ?? AppColors.textSecondary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inkMid,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderCard, width: 2),
            boxShadow: AppColors.shadowDoodle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: rows),
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
  final ValueChanged<bool> onChanged;

  const SettingsToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.pastelYellow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderCard, width: 1.5),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 18),
        ),
        title: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(value: value, onChanged: onChanged),
      );
}

class SettingsSubToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSubToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 56, right: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class SettingsChevronRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SettingsChevronRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.pastelMint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderCard, width: 1.5),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 18),
        ),
        title: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      );
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
    final color = muted
        ? AppColors.dislike.withValues(alpha: 0.5)
        : AppColors.dislike;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.pastelPink.withValues(alpha: muted ? 0.4 : 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderCard, width: 1.5),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}
