import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/constant.dart';

import '../appsetting.dart';
import '../components/loading_dialog.dart';
import '../components/snackbar.dart';
import '../screens/user/user_controller.dart';
import 'util.dart';

class PopUpDialogs {
  final BuildContext context;

  PopUpDialogs(this.context);

  Future<void> messageDialog(String title, String subs) async {
    // show the loading dialog
    await showDialog(
        barrierDismissible: true,
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: backgroundSecondary,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Some text
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    Text(
                      subs,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary),
                      textAlign: TextAlign.center,
                    ).pLTRB(15, 10, 15, 20),
                    const Divider(
                      height: 0,
                      color: textSecondary,
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () => hide(),
                            child: const Text(
                              'OK',
                              style: TextStyle(color: themePrimary),
                            )).exp(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<bool> confirmDialog(String title, String subs, String confirm) async {
    bool value = false;
    // show the loading dialog
    await showDialog(
        barrierDismissible: true,
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: backgroundSecondary,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Some text
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    Text(
                      subs,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary),
                      textAlign: TextAlign.center,
                    ).pLTRB(15, 10, 15, 20),
                    const Divider(
                      height: 0,
                      color: textSecondary,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: TextButton(
                                  onPressed: () => hide(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: textSecondary),
                                  ))),
                          const VerticalDivider(),
                          Expanded(
                            child: TextButton(
                                onPressed: () {
                                  value = true;
                                  hide();
                                },
                                child: Text(confirm)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
    return value;
  }

  Future<bool> deleteAccountDialog(TextEditingController passwordTextEditingController) async {
    final formKey = GlobalKey<FormState>();
    passwordTextEditingController.text = '';
    bool value = false;
    await showDialog(
        barrierDismissible: true,
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: backgroundSecondary,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Some text
                    Text(
                      'Deleting Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    Text(
                      'You are about to delete your account and all it\'s data. Please enter your password to proceed.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary),
                      textAlign: TextAlign.center,
                    ).pLTRB(15, 10, 15, 20),

                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: passwordTextEditingController,
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '*Password cannot be empty';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                          border: OutlineInputBorder(),
                          label: Text('Password'),
                        ),
                      ).pLTRB(15, 10, 15, 20),
                    ),
                    const Divider(
                      height: 0,
                      color: textSecondary,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: TextButton(
                                  onPressed: () => hide(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: textSecondary),
                                  ))),
                          const VerticalDivider(),
                          Expanded(
                            child: TextButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    await PopUpDialogs(context).confirmDialog('Delete Account', 'Are you sure you want to delete your account?', 'DELETE').then((_) {
                                      if (_) {
                                        value = true;
                                        hide();
                                      }
                                    });
                                  }
                                },
                                child: const Text('DELETE')),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
    return value;
  }

  Future<void> changePasswordDialog(BuildContext mainContext, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final currentPasswordTextEditingController = TextEditingController();
    final passwordTextEditingController = TextEditingController();
    final confirmPasswordTextEditingController = TextEditingController();

    await showDialog(
        barrierDismissible: true,
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: backgroundSecondary,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                      SizedBox(
                        child: Text(
                          'Change Password',
                          style: ref.watch(textThemeProvider(context)).titleLarge?.copyWith(color: themePrimary),
                        ).pb(10),
                      ),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*Current password cannot be empty';
                          return null;
                        },
                        controller: currentPasswordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          errorMaxLines: 2,
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('Current Password'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                        ),
                      ).p(10),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*New password cannot be empty';
                          if (value.length < 8) return '*New password must be at least 8 characters long';
                          return null;
                        },
                        controller: passwordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          errorMaxLines: 2,
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('New Password'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                        ),
                      ).p(10),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*Password cannot be empty';
                          if (value != passwordTextEditingController.text) return '*Password must be matching';
                          return null;
                        },
                        controller: confirmPasswordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('Confirm Password'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
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
                                    LoadingScreen(mainContext).show();
                                    ref
                                        .watch(userNotifierProvider.notifier)
                                        .changePassword(currentPasswordTextEditingController.text, passwordTextEditingController.text)
                                        .then((value) {
                                      LoadingScreen(mainContext).hide();
                                      messageSnackbar(mainContext, ref.watch(apiMessageStateProvider));
                                      Navigator.of(context).pop();
                                    }).catchError((err, st) {
                                      LoadingScreen(mainContext).hide();
                                      messageSnackbar(mainContext, Util.apiError(err));
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: const Text(
                                  'Reset Password',
                                  style: TextStyle(color: textPrimary),
                                ).p(15))
                            .exp()
                      ]).pLTRB(10, 20, 10, 10),
                      // const Spacer(
                      //   flex: 4,
                      // )
                    ]).p(20),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> editProfileDialog(BuildContext mainContext, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final usernameTextEditingController = TextEditingController();
    final firstNameTextEditingController = TextEditingController();
    final lastNameTextEditingController = TextEditingController();
    final emailTextEditingController = TextEditingController();

    usernameTextEditingController.text = ref.watch(userNotifierProvider).username ?? '';
    firstNameTextEditingController.text = ref.watch(userNotifierProvider).firstName ?? '';
    lastNameTextEditingController.text = ref.watch(userNotifierProvider).lastName ?? '';
    emailTextEditingController.text = ref.watch(userNotifierProvider).email ?? '';

    await showDialog(
        barrierDismissible: true,
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            // The background color
            backgroundColor: backgroundPrimary,
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: backgroundSecondary,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                      SizedBox(
                        child: Text(
                          'Edit Profile',
                          style: ref.watch(textThemeProvider(context)).titleLarge?.copyWith(color: themePrimary),
                        ).pb(10),
                      ),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*Username cannot be empty';
                          return null;
                        },
                        controller: usernameTextEditingController,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('Username'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                        ),
                      ).p(10),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*First name cannot be empty';
                          return null;
                        },
                        controller: firstNameTextEditingController,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('First Name'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                        ),
                      ).p(10),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*Last Name cannot be empty';
                          return null;
                        },
                        controller: lastNameTextEditingController,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('Last Name'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
                        ),
                      ).p(10),
                      TextFormField(
                        style: const TextStyle(color: textPrimary),
                        controller: emailTextEditingController,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(color: themeSecondary),
                          border: OutlineInputBorder(),
                          label: Text('Email (Optional)'),
                          labelStyle: TextStyle(color: textSecondary),
                          floatingLabelStyle: TextStyle(color: themePrimary),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themePrimary)),
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
                                    LoadingScreen(mainContext).show();
                                    ref
                                        .watch(userNotifierProvider.notifier)
                                        .editProfile(usernameTextEditingController.text, firstNameTextEditingController.text, lastNameTextEditingController.text,
                                            emailTextEditingController.text)
                                        .then((value) {
                                      LoadingScreen(mainContext).hide();
                                      messageSnackbar(mainContext, ref.watch(apiMessageStateProvider));
                                      Navigator.of(context).pop();
                                    }).catchError((err, st) {
                                      LoadingScreen(mainContext).hide();
                                      messageSnackbar(mainContext, Util.apiError(err));
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: const Text(
                                  'Reset Password',
                                  style: TextStyle(color: textPrimary),
                                ).p(15))
                            .exp()
                      ]).pLTRB(10, 20, 10, 10),
                      // const Spacer(
                      //   flex: 4,
                      // )
                    ]).p(20),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void hide() {
    Navigator.of(context).pop();
  }
}
