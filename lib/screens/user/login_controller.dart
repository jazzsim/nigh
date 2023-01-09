import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/screens/user/user_controller.dart';

import '../../api/model/user.dart';
import '../../api/user_api.dart';
import '../../api_client.dart';
import '../../appsetting.dart';
import '../../constant.dart';

final hidePasswordStateProvider = StateProvider.autoDispose<bool>((ref) => true);

final loginStateNotifierProvider = StateNotifierProvider<LoginStateNotifier, LoginState>((ref) => LoginStateNotifier(ref));

enum LoginState { idle, guest, loading, loggedin }

class LoginStateNotifier extends StateNotifier<LoginState> {
  StateNotifierProviderRef ref;
  LoginStateNotifier(this.ref) : super(LoginState.idle);

  Future<void> initLogin([String? username, String? password]) async {
    final userApi = UserApi();
    await userApi.login(username: username, password: password).then((value) async {
      await globalSharedPrefs.setString('api_key', value.response.token ?? '');
      await ApiClient.setHeader();
      state = LoginState.loggedin;
      if (value.response.isGuest == true) state = LoginState.guest;
      ref.watch(userNotifierProvider.notifier).state = value.response;
    }).catchError((err, st) {
      state = LoginState.guest;
    });
  }

  Future<User?> login(String username, String password) async {
    state = LoginState.loading;
    final userApi = UserApi();
    final res = await userApi.login(username: username, password: password).onError((error, stackTrace) {
      state = LoginState.guest;
      throw error!;
    });
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
    ref.watch(userNotifierProvider.notifier).state = res.response;
    state = LoginState.loggedin;
    return res.response;
  }

  void logout() => state = LoginState.guest;

  void loading() => state = LoginState.loading;

  void loggedin() => state = LoginState.loggedin;
}
