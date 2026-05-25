import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/users_repository.dart';
import '../../profile/providers/profile_provider.dart';

/// State for the admin requests screen.
class AdminRequestsState {
  final List<UserModel> pendingUsers;
  final List<UserModel> emailChangeRequests;
  final bool isLoading;
  final String? actionLoadingId;

  const AdminRequestsState({
    this.pendingUsers         = const [],
    this.emailChangeRequests  = const [],
    this.isLoading            = true,
    this.actionLoadingId,
  });

  AdminRequestsState copyWith({
    List<UserModel>? pendingUsers,
    List<UserModel>? emailChangeRequests,
    bool?    isLoading,
    String?  actionLoadingId,
    bool     clearActionLoading = false,
  }) => AdminRequestsState(
    pendingUsers:        pendingUsers        ?? this.pendingUsers,
    emailChangeRequests: emailChangeRequests ?? this.emailChangeRequests,
    isLoading:           isLoading           ?? this.isLoading,
    actionLoadingId:     clearActionLoading ? null : (actionLoadingId ?? this.actionLoadingId),
  );
}

class AdminRequestsNotifier extends Notifier<AdminRequestsState> {
  @override
  AdminRequestsState build() {
    _fetchAll();
    return const AdminRequestsState();
  }

  UsersRepository get _repo => ref.read(usersRepositoryProvider);

  Future<void> _fetchAll() async {
    try {
      final pending = await _repo.getPendingUsers();
      final emailChanges = await _repo.getEmailChangeRequests();
      state = state.copyWith(
        pendingUsers:        pending,
        emailChangeRequests: emailChanges,
        isLoading:           false,
      );
    } catch (e) {
      debugPrint('ENTANGL admin fetch error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchAll();
  }

  Future<void> approveUser(String userId) async {
    state = state.copyWith(actionLoadingId: userId);
    try {
      await _repo.approveUser(userId);
      await _fetchAll();
    } catch (e) {
      debugPrint('ENTANGL approve error: $e');
    }
    state = state.copyWith(clearActionLoading: true);
  }

  Future<void> rejectUser(String userId) async {
    state = state.copyWith(actionLoadingId: userId);
    try {
      await _repo.rejectUser(userId);
      await _fetchAll();
    } catch (e) {
      debugPrint('ENTANGL reject error: $e');
    }
    state = state.copyWith(clearActionLoading: true);
  }

  Future<void> approveEmailChange(String userId, String newEmail) async {
    state = state.copyWith(actionLoadingId: userId);
    try {
      await _repo.approveEmailChange(userId, newEmail);
      await _fetchAll();
    } catch (e) {
      debugPrint('ENTANGL approve email error: $e');
    }
    state = state.copyWith(clearActionLoading: true);
  }

  Future<void> rejectEmailChange(String userId) async {
    state = state.copyWith(actionLoadingId: userId);
    try {
      await _repo.rejectEmailChange(userId);
      await _fetchAll();
    } catch (e) {
      debugPrint('ENTANGL reject email error: $e');
    }
    state = state.copyWith(clearActionLoading: true);
  }
}

final adminRequestsProvider =
    NotifierProvider<AdminRequestsNotifier, AdminRequestsState>(
        AdminRequestsNotifier.new);
