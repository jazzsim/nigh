import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/screens/user/user_controller.dart';

import '../../api/model/user.dart';
import '../../api/user_api.dart';
import '../../appsetting.dart';

final registerStateNotifierProvider = StateNotifierProvider<RegisterStateNotifier, RegisterState>((ref) => RegisterStateNotifier(ref));

enum RegisterState { idle, failed, loading, loggedin }

class RegisterStateNotifier extends StateNotifier<RegisterState> {
  StateNotifierProviderRef ref;
  RegisterStateNotifier(this.ref) : super(RegisterState.idle);

  Future<User?> register(String username, String password, String firstname, String lastname) async {
    state = RegisterState.loading;
    final userApi = UserApi();
    final res = await userApi.register(username: username, firstName: firstname, lastName: lastname, password: password).onError((error, stackTrace) {
      state = RegisterState.failed;
      throw error!;
    });
    ref.watch(apiMessageStateProvider.notifier).state = res.message;
    ref.watch(userNotifierProvider.notifier).state = res.response;
    state = RegisterState.loggedin;
    return res.response;
  }
}
