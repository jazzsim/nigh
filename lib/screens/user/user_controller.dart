import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/api/user_api.dart';

import '../../api/model/user.dart';
import '../../appsetting.dart';

final changePasswordStateProvider = StateProvider<bool>((ref) => false);

final userNotifierProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier(ref));

class UserNotifier extends StateNotifier<User> {
  StateNotifierProviderRef ref;
  UserNotifier(this.ref) : super(const User(id: 0, username: ''));

  Future<void> deleteUser(String password) async {
    final userApi = UserApi();
    final res = await userApi.deleteUser(password: password);
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
  }

  Future<void> editProfile(String username, String firstName, String lastName, String email) async {
    final userApi = UserApi();
    final res = await userApi.editProfile(username: username, firstName: firstName, lastName: lastName, email: email);
    ref.watch(userNotifierProvider.notifier).state = res.response;
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final userApi = UserApi();
    final res = await userApi.changePassword(currentPassword: currentPassword, newPassword: newPassword);
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
  }
}
