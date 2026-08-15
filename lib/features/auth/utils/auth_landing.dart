import '../../../core/router/app_router.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/users_repository.dart';

/// Where to send a signed-in user after splash / login / register.
Future<String> landingRouteAfterAuth() async {
  try {
    final users = UsersRepository();
    final profile = await users.getOwnProfile();
    if (profile == null) return AppRoutes.home;

    if (profile.status.startsWith('email_change_approved:')) {
      final newEmail =
          profile.status.replaceFirst('email_change_approved:', '');
      try {
        await AuthRepository().updateEmail(newEmail);
        await users.processApprovedEmailChange();
      } catch (_) {}
    }

    if (!profile.isApproved) return AppRoutes.approvalStatus;
    return AppRoutes.home;
  } catch (_) {
    return AppRoutes.home;
  }
}
