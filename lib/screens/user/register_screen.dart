import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/components/snackbar.dart';
import 'package:nigh/screens/others_screen.dart';
import 'package:nigh/screens/user/register_controller.dart';

import '../../api_client.dart';
import '../../appsetting.dart';
import '../../components/loading_dialog.dart';
import '../../components/logo.dart';
import '../../constant.dart';
import '../../helper/util.dart';
import '../diary/diary_controller.dart';
import '../home_screen.dart';
import '../todo/to_do_controller.dart';
import 'login_controller.dart';

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
  final emailTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _invalid = false;
  bool? _agree;

  @override
  Widget build(BuildContext context) {
    ref.listen(registerStateNotifierProvider, ((previous, next) => next == RegisterState.loading ? LoadingScreen(context).show() : LoadingScreen(context).hide()));
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
            appBar: AppBar(title: const Text('Register')),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Logo(),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _invalid = true;
                            return '*Please insert your first name';
                          }
                          return null;
                        },
                        controller: firstNameTextEditingController,
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: themeSecondary),
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
                            return '*Please insert your last name';
                          }
                          return null;
                        },
                        controller: lastNameTextEditingController,
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: themeSecondary),
                            labelStyle: TextStyle(color: textSecondary),
                            floatingLabelStyle: TextStyle(color: themePrimary),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                            border: OutlineInputBorder(),
                            label: Text('Last Name')),
                      ).p(10),
                      const Divider(
                        color: textSecondary,
                      ),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _invalid = true;
                            return '*Username cannot be empty';
                          }
                          return null;
                        },
                        controller: usernameTextEditingController,
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: themeSecondary),
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
                            return '*Password cannot be empty';
                          }
                          if (value.length < 8) {
                            _invalid = true;
                            return '*Password must be at least 8 characters long';
                          }
                          return null;
                        },
                        controller: passwordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: ref.watch(hidePasswordStateProvider),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: themeSecondary),
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
                            return '*Password cannot be empty';
                          }
                          if (value != passwordTextEditingController.text) {
                            _invalid = true;
                            return '*Password must be matching';
                          }
                          return null;
                        },
                        controller: confirmPasswordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: ref.watch(hidePasswordStateProvider),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: themeSecondary),
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
                      const Divider(color: textSecondary),
                      Text(
                        'Your email will only be used for password reset purposes.',
                        style: ref.watch(textThemeProvider(context)).caption?.copyWith(color: textSecondary),
                        textAlign: TextAlign.center,
                      ).p(5),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: themeSecondary),
                            labelStyle: TextStyle(color: textSecondary),
                            floatingLabelStyle: TextStyle(color: themePrimary),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                            border: OutlineInputBorder(),
                            label: Text('Email (optional)')),
                      ).p(10),
                      const Divider(color: textSecondary),
                      const SizedBox().pb(10),
                      ListTile(
                        leading: Checkbox(
                          value: _agree ?? false,
                          onChanged: (v) => setState(() {
                            _agree = !(_agree ?? false);
                          }),
                        ),
                        onTap: () => setState(() {
                          _agree = !(_agree ?? false);
                        }),
                        title: RichText(
                          text: TextSpan(children: [
                            const TextSpan(text: 'I have read and agreed to the ', style: TextStyle(color: textPrimary)),
                            TextSpan(
                                text: 'Terms of Use ',
                                style: const TextStyle(color: themeSecondary),
                                recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).push(OthersScreen.route('Terms of Use'))),
                            const TextSpan(text: 'and ', style: TextStyle(color: textPrimary)),
                            TextSpan(
                                text: 'Privacy Policy.',
                                style: const TextStyle(color: themeSecondary),
                                recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).push(OthersScreen.route('Privacy Policy'))),
                          ]),
                        ),
                      ),
                      _agree == false
                          ? const Text(
                              '*Required',
                              style: TextStyle(color: themeSecondary),
                            )
                          : const SizedBox(),
                      Row(children: [
                        ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    if (_agree == null || _agree == false) {
                                      _agree = false;
                                      setState(() {});
                                      return;
                                    }
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
                                        ref.read(todoNotifierProvider.notifier).getTodos(ref.watch(todoDatetimeStateProvider).toString());
                                        ref.watch(diaryNotifierProvider.notifier).getDiaries(ref.watch(diaryDatetimeStateProvider).toString());
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
                                  style: TextStyle(color: textPrimary),
                                ).p(15))
                            .exp()
                      ]).p(10),
                    ],
                  ).p(20),
                ),
              ),
            )));
  }
}
