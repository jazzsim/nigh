import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/appsetting.dart';
import 'package:nigh/screens/todo/to_do_screen.dart';
import 'package:nigh/screens/user/login_controller.dart';

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen> {
  @override
  void initState() {
    super.initState();
    ref.read(appSettingProvider).initializeApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(loginStateNotifierProvider) == LoginState.idle
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : const ToDoScreen();
  }
}
