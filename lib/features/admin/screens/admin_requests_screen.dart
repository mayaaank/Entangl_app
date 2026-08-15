import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/connect_app_bar.dart';
import '../providers/admin_requests_provider.dart';

class AdminRequestsScreen extends ConsumerStatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  ConsumerState<AdminRequestsScreen> createState() =>
      _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends ConsumerState<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

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
    final palette = context.palette;
    final state = ref.watch(adminRequestsProvider);
    final notifier = ref.read(adminRequestsProvider.notifier);
    final pendingCount =
        state.pendingUsers.where((u) => u.status == 'pending').length;
    final emailCount = state.emailChangeRequests.length;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: ConnectAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: palette.onSurface,
            size: 20,
          ),
        ),
        title: 'Admin requests',
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: palette.onSurface,
            unselectedLabelColor: palette.onSurfaceVariant,
            indicatorColor: palette.primary,
            tabs: [
              Tab(text: pendingCount > 0
                  ? 'Registrations ($pendingCount)'
                  : 'Registrations'),
              Tab(text: emailCount > 0
                  ? 'Email changes ($emailCount)'
                  : 'Email changes'),
            ],
          ),
          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: palette.primary,
                      strokeWidth: 2,
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _RequestList(
                        users: state.pendingUsers,
                        empty: 'No pending registrations',
                        loadingId: state.actionLoadingId,
                        onRefresh: notifier.refresh,
                        subtitleOf: (u) => u.status,
                        onApprove: notifier.approveUser,
                        onReject: (u) => notifier.rejectUser(u.id),
                      ),
                      _RequestList(
                        users: state.emailChangeRequests,
                        empty: 'No email change requests',
                        loadingId: state.actionLoadingId,
                        onRefresh: notifier.refresh,
                        subtitleOf: (u) => u.status
                            .replaceFirst('email_change_pending:', ''),
                        onApprove: (id) {
                          final user = state.emailChangeRequests
                              .firstWhere((u) => u.id == id);
                          final email = user.status
                              .replaceFirst('email_change_pending:', '');
                          return notifier.approveEmailChange(id, email);
                        },
                        onReject: (u) => notifier.rejectEmailChange(u.id),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<UserModel> users;
  final String empty;
  final String? loadingId;
  final Future<void> Function() onRefresh;
  final String Function(UserModel) subtitleOf;
  final Future<void> Function(String id) onApprove;
  final Future<void> Function(UserModel user) onReject;

  const _RequestList({
    required this.users,
    required this.empty,
    required this.loadingId,
    required this.onRefresh,
    required this.subtitleOf,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (users.isEmpty) {
      return Center(
        child: Text(
          empty,
          style: AppTextStyles.bodyMedium.copyWith(
            color: palette.onSurfaceVariant,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final user = users[i];
          final busy = loadingId == user.id;
          final created = DateTime.tryParse(user.createdAt);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.outline, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarWidget(imageUrl: user.avatarUrl, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: AppTextStyles.labelLarge),
                          Text(
                            '@${user.username}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: palette.onSurfaceVariant,
                            ),
                          ),
                          if (created != null)
                            Text(
                              timeago.format(created),
                              style: AppTextStyles.timestamp,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleOf(user),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: busy ? null : () => onReject(user),
                      child: Text(
                        'Reject',
                        style: TextStyle(color: palette.error),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: busy ? null : () => onApprove(user.id),
                      child: Text(busy ? '…' : 'Approve'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
