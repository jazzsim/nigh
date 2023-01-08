import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/screens/user/login_controller.dart';

final apiMessageStateProvider = StateProvider<String>((ref) => '');

final screenStateProvider = StateProvider<int>((ref) => 0);

final textThemeProvider = Provider.family<TextTheme, BuildContext>((ref, context) => Theme.of(context).textTheme);

final loadingStateProvider = StateProvider<bool>((ref) => false);

final initializedStateProvider = StateProvider<bool>((ref) => false);

// final loggedInStateProvider = StateProvider<bool?>((ref) => null);

final appSettingProvider = Provider<AppSetting>((ref) {
  return AppSetting(ref);
});

class AppSetting {
  final ProviderRef<AppSetting> ref;
  AppSetting(this.ref) : super();

  Future<void> initializeApp(BuildContext context) async {
    await isLoggedIn(context);
    ref.read(initializedStateProvider.notifier).state = true;
  }

  Future<void> isLoggedIn(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    await ref.watch(loginStateNotifierProvider.notifier).initLogin();
  }
}