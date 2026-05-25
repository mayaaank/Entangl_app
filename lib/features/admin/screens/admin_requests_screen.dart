import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../providers/admin_requests_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminRequestsScreen extends ConsumerStatefulWidget {
  const AdminRequestsScreen({super.key});
  @override
  ConsumerState<AdminRequestsScreen> createState() =>
      _AdminRequestsScreenState();
}

class _AdminRequestsScreenState
    extends ConsumerState<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminRequestsProvider);
    final notifier   = ref.read(adminRequestsProvider.notifier);

    final pendingCount = adminState.pendingUsers
        .where((u) => u.status == 'pending')
        .length;
    final emailCount = adminState.emailChangeRequests.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.onSurfaceDark, size: 20),
        ),
        title: Text('Admin Requests',
            style: AppTextStyles.labelLarge
                .copyWith(color: AppColors.onSurfaceDark)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelColor: AppColors.onSurfaceDark,
          unselectedLabelColor:
              AppColors.onSurfaceVariantDark.withOpacity(0.4),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Registrations'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$pendingCount',
                          style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Email Changes'),
                  if (emailCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$emailCount',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: adminState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : TabBarView(
              controller: _tabs,
              children: [
                _RegistrationsTab(
                  users:           adminState.pendingUsers,
                  actionLoadingId: adminState.actionLoadingId,
                  onApprove:       notifier.approveUser,
                  onReject:        notifier.rejectUser,
                  onRefresh:       notifier.refresh,
                ),
                _EmailChangesTab(
                  users:           adminState.emailChangeRequests,
                  actionLoadingId: adminState.actionLoadingId,
                  onApprove:       notifier.approveEmailChange,
                  onReject:        notifier.rejectEmailChange,
                  onRefresh:       notifier.refresh,
                ),
              ],
            ),
    );
  }
}

// ── Registrations Tab ──────────────────────────────────────────

class _RegistrationsTab extends StatelessWidget {
  final List<UserModel> users;
  final String? actionLoadingId;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;
  final Future<void> Function() onRefresh;

  const _RegistrationsTab({
    required this.users,
    this.actionLoadingId,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_outline_rounded,
              color: const Color(0xFF10B981).withOpacity(0.5), size: 48),
          const SizedBox(height: 16),
          Text('No pending registrations',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariantDark)),
          const SizedBox(height: 4),
          Text('All requests have been processed.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.outlineVariant)),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLow,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final user = users[i];
          final isActionLoading = actionLoadingId == user.id;
          return _UserRequestCard(
            user:    user,
            loading: isActionLoading,
            statusChip: user.status == 'pending'
                ? _StatusChip(
                    label: 'Pending',
                    color: const Color(0xFFF59E0B),
                    icon:  Icons.schedule_rounded,
                  )
                : _StatusChip(
                    label: 'Rejected',
                    color: AppColors.error,
                    icon:  Icons.cancel_outlined,
                  ),
            actions: [
              _ActionButton(
                label:   'Approve',
                icon:    Icons.check_rounded,
                color:   const Color(0xFF10B981),
                onTap:   isActionLoading ? null : () => onApprove(user.id),
              ),
              if (user.status != 'rejected')
                _ActionButton(
                  label:   'Reject',
                  icon:    Icons.close_rounded,
                  color:   AppColors.error,
                  onTap:   isActionLoading ? null : () => onReject(user.id),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Email Changes Tab ──────────────────────────────────────────

class _EmailChangesTab extends StatelessWidget {
  final List<UserModel> users;
  final String? actionLoadingId;
  final Future<void> Function(String, String) onApprove;
  final Future<void> Function(String) onReject;
  final Future<void> Function() onRefresh;

  const _EmailChangesTab({
    required this.users,
    this.actionLoadingId,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.mail_outline_rounded,
              color: AppColors.outlineVariant.withOpacity(0.5), size: 48),
          const SizedBox(height: 16),
          Text('No email change requests',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariantDark)),
          const SizedBox(height: 4),
          Text('No users have requested an email change.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.outlineVariant)),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLow,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final user = users[i];
          final requestedEmail =
              user.status.replaceFirst('email_change_pending:', '');
          final isActionLoading = actionLoadingId == user.id;

          return _UserRequestCard(
            user:    user,
            loading: isActionLoading,
            subtitle: Row(children: [
              const Icon(Icons.mail_outline_rounded,
                  color: AppColors.primary, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'Wants email: ',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariantDark),
                    ),
                    TextSpan(
                      text: requestedEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            actions: [
              _ActionButton(
                label: 'Approve',
                icon:  Icons.check_rounded,
                color: const Color(0xFF10B981),
                onTap: isActionLoading
                    ? null
                    : () => onApprove(user.id, requestedEmail),
              ),
              _ActionButton(
                label: 'Reject',
                icon:  Icons.close_rounded,
                color: AppColors.error,
                onTap: isActionLoading
                    ? null
                    : () => onReject(user.id),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Shared card ────────────────────────────────────────────────

class _UserRequestCard extends StatelessWidget {
  final UserModel user;
  final bool loading;
  final Widget? statusChip;
  final Widget? subtitle;
  final List<Widget> actions;

  const _UserRequestCard({
    required this.user,
    this.loading  = false,
    this.statusChip,
    this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AvatarWidget(imageUrl: user.avatarUrl, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceDark,
                          fontWeight: FontWeight.w600)),
                  Text('@${user.username}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariantDark)),
                  if (user.createdAt.isNotEmpty)
                    Text(
                      timeago.format(DateTime.parse(user.createdAt)),
                      style: AppTextStyles.timestamp,
                    ),
                ],
              ),
            ),
            if (statusChip != null) statusChip!,
          ]),

          if (subtitle != null) ...[
            const SizedBox(height: 12),
            subtitle!,
          ],

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions
                .expand((a) => [a, const SizedBox(width: 8)])
                .toList()
              ..removeLast(),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color  color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final Color     color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
