import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/appsetting.dart';
import 'package:nigh/screens/user/user_controller.dart';

import '../api_client.dart';
import '../components/loading_dialog.dart';
import '../components/snackbar.dart';
import '../constant.dart';
import '../helper/dialogs.dart';
import '../helper/util.dart';
import 'diary/diary_controller.dart';
import 'todo/to_do_controller.dart';
import 'user/login_controller.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  static MaterialPageRoute<dynamic> route() => MaterialPageRoute(builder: (context) => const SettingScreen());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.warning,
              color: backgroundPrimary,
            ),
            title: const Text('Delete Account', style: TextStyle(color: textPrimary)),
            tileColor: themePrimary,
            onTap: () async {
              bool delete = false;
              await PopUpDialogs(context).deleteAccountDialog(passwordTextEditingController).then((value) {
                delete = value;
              });
              if (!mounted) return;
              // delete account here
              if (delete) {
                LoadingScreen(context).show();
                ref.watch(userNotifierProvider.notifier).deleteUser(passwordTextEditingController.text).then((value) async {
                  messageSnackbar(context, ref.watch(apiMessageStateProvider));
                  await globalSharedPrefs.setString('api_key', '').then((value) async {
                    await ApiClient.setHeader();
                  });
                  await ref.watch(loginStateNotifierProvider.notifier).initLogin();
                  ref.invalidate(screenStateProvider);
                  ref.invalidate(todoNotifierProvider);
                  await ref.read(todoNotifierProvider.notifier).getTodos(ref.watch(todoDatetimeStateProvider).toString());
                  ref.invalidate(diaryNotifierProvider);
                  await ref.watch(diaryNotifierProvider.notifier).getDiaries(ref.watch(diaryDatetimeStateProvider).toString());
                  if (!mounted) return;
                  LoadingScreen(context).hide();
                  Navigator.of(context).pop();
                }).catchError((err, st) {
                  LoadingScreen(context).hide();
                  messageSnackbar(context, Util.apiError(err));
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
