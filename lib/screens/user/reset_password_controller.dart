import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/appsetting.dart';

import '../../api/user_api.dart';

final hidePasswordStateProvider = StateProvider.autoDispose<bool>((ref) => true);

final usernameStateProvider = StateProvider<String>((ref) => '');

final passwordResetStateNotifierProvider = StateNotifierProvider<PasswordResetStateNotifier, PasswordResetState>((ref) => PasswordResetStateNotifier(ref));

enum PasswordResetState { idle, pending, verified, failed }

class PasswordResetStateNotifier extends StateNotifier<PasswordResetState> {
  StateNotifierProviderRef ref;
  PasswordResetStateNotifier(this.ref) : super(PasswordResetState.idle);

  Future<void> requestResetPassword(String username, String email) async {
    final userApi = UserApi();
    final res = await userApi.requestResetPassword(username: username, email: email);
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
  }

  Future<void> verifyResetPassword(String username, String code) async {
    final userApi = UserApi();
    final res = await userApi.verifyResetPassword(username: username, code: code);
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
  }

  Future<void> resetPassword(String username, String password) async {
    final userApi = UserApi();
    final res = await userApi.resetPassword(username: username, password: password);
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
  }

  void idle() => state = PasswordResetState.idle;

  void pending() => state = PasswordResetState.pending;

  // void loading() => state = PasswordResetState.loading;

  void verified() => state = PasswordResetState.verified;

  void failed() => state = PasswordResetState.failed;
}
