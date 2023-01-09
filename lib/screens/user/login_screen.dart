import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/components/logo.dart';
import 'package:nigh/components/snackbar.dart';
import 'package:nigh/constant.dart';
import 'package:nigh/screens/todo/to_do_controller.dart';

import '../../api_client.dart';
import '../../appsetting.dart';
import '../../components/loading_dialog.dart';
import '../../helper/util.dart';
import '../home_screen.dart';
import 'login_controller.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static MaterialPageRoute<dynamic> route() => MaterialPageRoute(builder: (context) => const LoginScreen());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.listen(loginStateNotifierProvider, ((previous, next) => next == LoginState.loading ? LoadingScreen(context).show() : LoadingScreen(context).hide()));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Logo(height: 220).pb(80),
                TextFormField(
                  style: const TextStyle(color: textPrimary),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty';
                    }
                    return null;
                  },
                  controller: usernameTextEditingController,
                  decoration: const InputDecoration(
                      labelStyle: TextStyle(color: textSecondary),
                      floatingLabelStyle: TextStyle(color: themePrimary),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                      border: OutlineInputBorder(),
                      label: Text('Username')),
                ).p(10),
                TextFormField(
                  style: const TextStyle(color: textPrimary),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    return null;
                  },
                  controller: passwordTextEditingController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: ref.watch(hidePasswordStateProvider),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: textSecondary),
                    floatingLabelStyle: const TextStyle(color: themePrimary),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                    border: const OutlineInputBorder(),
                    label: const Text('Password'),
                    suffixIcon: IconButton(
                      splashRadius: 0.1,
                      icon: Icon(
                        ref.watch(hidePasswordStateProvider) ? Icons.visibility_off : Icons.visibility, //change icon based on boolean value
                        // color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        ref.watch(hidePasswordStateProvider.notifier).state = !ref.watch(hidePasswordStateProvider);
                      },
                    ),
                  ),
                ).p(10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot password?', style: ref.watch(textThemeProvider(context)).caption).pr(15),
                ),
                Row(children: [
                  ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await ref
                                  .watch(loginStateNotifierProvider.notifier)
                                  .login(usernameTextEditingController.text, passwordTextEditingController.text)
                                  .then((value) async {
                                await globalSharedPrefs.setString('api_key', value?.token ?? '');
                                await ApiClient.setHeader();
                                ref.invalidate(todoNotifierProvider);
                                ref.invalidate(datetimeStateProvider);
                                await ref.read(todoNotifierProvider.notifier).getTodos(ref.watch(datetimeStateProvider).toString());
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                messageSnackbar(context, ref.watch(apiMessageStateProvider));
                                Navigator.of(context).pop();
                              }).catchError((err, st) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                messageSnackbar(context, Util.apiError(err));
                              });
                            }
                          },
                          child: const Text(
                            'Login',
                          ).p(15))
                      .exp()
                ]).p(10),
                const Divider(
                  height: 0,
                  color: textSecondary,
                ).pt(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.of(context).push(RegisterScreen.route()),
                        child: const Text(
                          'Don\'t have an account? Register now!',
                        )).exp(),
                  ],
                ).pLTRB(10, 0, 10, 0)
              ],
            ).p(20),
          ),
        ));
  }
}
