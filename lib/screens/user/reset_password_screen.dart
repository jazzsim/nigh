import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/appsetting.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/components/loading_dialog.dart';
import 'package:nigh/components/snackbar.dart';
import 'package:nigh/screens/user/reset_password_controller.dart';

import '../../constant.dart';
import '../../helper/dialogs.dart';
import '../../helper/util.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static MaterialPageRoute<dynamic> route() => MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  @override
  void initState() {
    super.initState();
    // ignore: unused_result
    ref.refresh(passwordResetStateNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(passwordResetStateNotifierProvider) == PasswordResetState.idle
        ? const ResetPasswordEmailScreen()
        : ref.watch(passwordResetStateNotifierProvider) == PasswordResetState.pending
            ? const ResetPasswordCodeScreen()
            : const ResetPasswordResetScreen();
  }
}

class ResetPasswordEmailScreen extends ConsumerStatefulWidget {
  const ResetPasswordEmailScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResetPasswordEmailScreenState();
}

class _ResetPasswordEmailScreenState extends ConsumerState<ResetPasswordEmailScreen> {
  final usernameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reset Password (1/3)')),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step One',
                    style: ref.watch(textThemeProvider(context)).headline3?.copyWith(color: textPrimary, fontWeight: ref.watch(textThemeProvider(context)).headline1?.fontWeight),
                  ),
                  Text(
                    'Before we proceed, please enter your username and email for verification purposes.',
                    style: ref.watch(textThemeProvider(context)).headline5?.copyWith(color: textPrimary, fontWeight: ref.watch(textThemeProvider(context)).headline1?.fontWeight),
                  ).pb(20).pl(5),
                ],
              ).pb(50),
              Column(
                children: [
                  TextFormField(
                    style: const TextStyle(color: textPrimary),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*Email cannot be empty';
                      }
                      return null;
                    },
                    controller: emailTextEditingController,
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: themeSecondary),
                        labelStyle: TextStyle(color: textSecondary),
                        floatingLabelStyle: TextStyle(color: themePrimary),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                        border: OutlineInputBorder(),
                        label: Text('Email')),
                  ).p(10),
                  Row(children: [
                    ElevatedButton(
                            onPressed: () async {
                              FocusScopeNode currentFocus = FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (formKey.currentState!.validate()) {
                                LoadingScreen(context).show();
                                ref.watch(usernameStateProvider.notifier).state = usernameTextEditingController.text;
                                ref
                                    .watch(passwordResetStateNotifierProvider.notifier)
                                    .requestResetPassword(usernameTextEditingController.text, emailTextEditingController.text)
                                    .then((value) {
                                  LoadingScreen(context).hide();
                                  ref.watch(passwordResetStateNotifierProvider.notifier).pending();
                                  messageSnackbar(context, ref.watch(apiMessageStateProvider));
                                }).catchError((err, st) {
                                  LoadingScreen(context).hide();
                                  messageSnackbar(context, Util.apiError(err));
                                });
                              }
                            },
                            child: const Text(
                              'Next',
                              style: TextStyle(color: textPrimary),
                            ).p(15))
                        .exp()
                  ]).pLTRB(10, 20, 10, 10),
                ],
              ),
              // const Spacer(
              //   flex: 4,
              // )
            ]).p(20),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordCodeScreen extends ConsumerStatefulWidget {
  const ResetPasswordCodeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ResetPasswordCodeScreenState();
}

class ResetPasswordCodeScreenState extends ConsumerState<ResetPasswordCodeScreen> {
  final codeTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool pop = true;
        await PopUpDialogs(context).confirmDialog('Aborting', 'Are you sure you want to abort the password reset process?', 'Abort').then((value) {
          pop = value;
        });
        return pop;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Reset Password (2/3)')),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step Two',
                      style: ref.watch(textThemeProvider(context)).headline2?.copyWith(color: textPrimary, fontWeight: ref.watch(textThemeProvider(context)).headline1?.fontWeight),
                    ),
                    Text(
                      'We had sent a verification code to your email, please enter the code from the email to proceed.',
                      style: ref.watch(textThemeProvider(context)).headline5?.copyWith(color: textPrimary, fontWeight: ref.watch(textThemeProvider(context)).headline1?.fontWeight),
                    ).pb(20).pl(5),
                  ],
                ).pb(50),
                // const Spacer(),
                Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color: textPrimary),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Code cannot be empty';
                        }
                        return null;
                      },
                      controller: codeTextEditingController,
                      decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                          border: OutlineInputBorder(),
                          hintText: 'Enter your code here',
                          hintStyle: TextStyle(color: textSecondary)),
                    ).pLTRB(10, 0, 10, 10),
                    Row(children: [
                      ElevatedButton(
                              onPressed: () async {
                                FocusScopeNode currentFocus = FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                if (formKey.currentState!.validate()) {
                                  LoadingScreen(context).show();
                                  ref.watch(passwordResetStateNotifierProvider.notifier).verifyResetPassword(codeTextEditingController.text).then((value) {
                                    LoadingScreen(context).hide();
                                    ref.watch(passwordResetStateNotifierProvider.notifier).verified();
                                    messageSnackbar(context, ref.watch(apiMessageStateProvider));
                                  }).catchError((err, st) {
                                    LoadingScreen(context).hide();
                                    messageSnackbar(context, Util.apiError(err));
                                  });
                                }
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(color: textPrimary),
                              ).p(15))
                          .exp()
                    ]).pLTRB(10, 20, 10, 10),
                  ],
                ),
              ]).p(20),
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordResetScreen extends ConsumerStatefulWidget {
  const ResetPasswordResetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResetPasswordResetScreenState();
}

class _ResetPasswordResetScreenState extends ConsumerState<ResetPasswordResetScreen> {
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _invalid = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool pop = true;
        await PopUpDialogs(context).confirmDialog('Aborting', 'Are you sure you want to abort the password reset process?', 'Abort').then((value) {
          pop = value;
        });
        return pop;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Reset Password (3/3)')),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step Three',
                      style: ref.watch(textThemeProvider(context)).headline2?.copyWith(color: textPrimary, fontWeight: ref.watch(textThemeProvider(context)).headline1?.fontWeight),
                    ),
                    Text(
                      'Completed account verification. Thank you for your time, now let\'s reset your new password.',
                      style: ref.watch(textThemeProvider(context)).headline5?.copyWith(color: textPrimary, fontWeight: ref.watch(textThemeProvider(context)).headline1?.fontWeight),
                    ).pb(20).pl(5),
                  ],
                ).pb(50),
                // const Spacer(),
                Column(
                  children: [
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
                    Row(children: [
                      ElevatedButton(
                              onPressed: () async {
                                FocusScopeNode currentFocus = FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                if (formKey.currentState!.validate()) {
                                  LoadingScreen(context).show();
                                  ref.watch(passwordResetStateNotifierProvider.notifier).resetPassword(passwordTextEditingController.text).then((value) {
                                    LoadingScreen(context).hide();
                                    messageSnackbar(context, ref.watch(apiMessageStateProvider));
                                    Navigator.of(context).pop();
                                  }).catchError((err, st) {
                                    LoadingScreen(context).hide();
                                    messageSnackbar(context, Util.apiError(err));
                                  });
                                }
                              },
                              child: const Text(
                                'Reset Password',
                                style: TextStyle(color: textPrimary),
                              ).p(15))
                          .exp()
                    ]).pLTRB(10, 20, 10, 10),
                  ],
                ),
                // const Spacer(
                //   flex: 4,
                // )
              ]).p(20),
            ),
          ),
        ),
      ),
    );
  }
}
