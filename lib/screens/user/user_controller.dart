import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/model/user.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier(ref));

class UserNotifier extends StateNotifier<User> {
  StateNotifierProviderRef ref;
  UserNotifier(this.ref) : super(const User(id: 0, username: ''));
}