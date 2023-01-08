import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/components/snackbar.dart';
import 'package:nigh/screens/user/register_controller.dart';

import '../../api_client.dart';
import '../../appsetting.dart';
import '../../components/loading_dialog.dart';
import '../../components/logo.dart';
import '../../constant.dart';
import '../../helper/util.dart';
import '../home_screen.dart';
import '../todo/to_do_controller.dart';
import 'login_controller.dart';
import 'user_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  static MaterialPageRoute<dynamic> route() => MaterialPageRoute(builder: (context) => const RegisterScreen());

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final firstNameTextEditingController = TextEditingController();
  final lastNameTextEditingController = TextEditingController();
  final usernameTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _invalid = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(registerStateNotifierProvider, ((previous, next) => next == RegisterState.loading ? LoadingScreen(context).show() : LoadingScreen(context).hide()));
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      _invalid = true;
                      return 'Please insert your first name';
                    }
                    return null;
                  },
                  controller: firstNameTextEditingController,
                  decoration: const InputDecoration(
                      labelStyle: TextStyle(color: textSecondary),
                      floatingLabelStyle: TextStyle(color: themePrimary),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                      border: OutlineInputBorder(),
                      label: Text('First Name')),
                ).p(10),
                TextFormField(
                  style: const TextStyle(color: textPrimary),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _invalid = true;
                      return 'Please insert your last name';
                    }
                    return null;
                  },
                  controller: lastNameTextEditingController,
                  decoration: const InputDecoration(
                      labelStyle: TextStyle(color: textSecondary),
                      floatingLabelStyle: TextStyle(color: themePrimary),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                      border: OutlineInputBorder(),
                      label: Text('Last Name')),
                ).p(10),
                TextFormField(
                  style: const TextStyle(color: textPrimary),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _invalid = true;
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
                      _invalid = true;
                      return 'Password cannot be empty';
                    }
                    if (value.length < 8) {
                      _invalid = true;
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                  controller: passwordTextEditingController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: ref.watch(hidePasswordStateProvider),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text('Password'),
                    labelStyle: const TextStyle(color: textSecondary),
                    floatingLabelStyle: const TextStyle(color: themePrimary),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                    suffixIcon: IconButton(
                      splashRadius: 0.1,
                      icon: Icon(
                        ref.watch(hidePasswordStateProvider) ? Icons.visibility_off : Icons.visibility, //change icon based on boolean value
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        ref.watch(hidePasswordStateProvider.notifier).state = !ref.watch(hidePasswordStateProvider);
                      },
                    ),
                  ),
                ).p(10),
                TextFormField(
                  style: const TextStyle(color: textPrimary),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _invalid = true;
                      return 'Password cannot be empty';
                    }
                    if (value != passwordTextEditingController.text) {
                      _invalid = true;
                      return 'Password must be matching';
                    }
                    return null;
                  },
                  controller: confirmPasswordTextEditingController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: ref.watch(hidePasswordStateProvider),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text('Confirm Password'),
                    labelStyle: const TextStyle(color: textSecondary),
                    floatingLabelStyle: const TextStyle(color: themePrimary),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                    suffixIcon: IconButton(
                      splashRadius: 0.1,
                      icon: Icon(
                        ref.watch(hidePasswordStateProvider) ? Icons.visibility_off : Icons.visibility, //change icon based on boolean value
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        ref.watch(hidePasswordStateProvider.notifier).state = !ref.watch(hidePasswordStateProvider);
                      },
                    ),
                  ),
                ).p(10),
                Row(children: [
                  ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await ref
                                  .watch(registerStateNotifierProvider.notifier)
                                  .register(
                                    usernameTextEditingController.text,
                                    passwordTextEditingController.text,
                                    firstNameTextEditingController.text,
                                    lastNameTextEditingController.text,
                                  )
                                  .then((value) async {
                                if (value != null) {
                                  globalSharedPrefs.setString('api_key', value.token ?? '');
                                  await ApiClient.setHeader();
                                  ref.read(loginStateNotifierProvider.notifier).loggedin();
                                  ref.read(todoNotifierProvider.notifier).getTodos(ref.watch(datetimeStateProvider).toString());
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  messageSnackbar(context, ref.watch(apiMessageStateProvider));
                                  Navigator.of(context).pushAndRemoveUntil(HomeScreen.route(), (route) => false);
                                }
                              }).catchError((err, st) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                messageSnackbar(context, Util.apiError(err));
                              });
                            }
                          },
                          child: const Text(
                            'Register',
                          ).p(15))
                      .exp()
                ]).p(10),
              ],
            ).p(20),
          ),
        ),
      ),
    );
  }
}
