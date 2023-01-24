import 'package:flutter/material.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/constant.dart';

class PopUpDialogs {
  final BuildContext context;

  PopUpDialogs(this.context);

  Future<bool> confirmDialog(String title, String subs, String confirm) async {
    bool value = false;
    // show the loading dialog
    await showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: true,
        // barrierColor: Color.fromARGB(70, 105, 104, 104),
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            // The background color
            backgroundColor: backgroundPrimary,
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
          );
        });
    return value;
  }

  Future<bool> deleteAccountDialog(TextEditingController passwordTextEditingController) async {
    final formKey = GlobalKey<FormState>();
    passwordTextEditingController.text = '';
    bool value = false;
    await showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: true,
        // barrierColor: Color.fromARGB(70, 105, 104, 104),
        barrierColor: const Color.fromARGB(149, 46, 56, 64),
        context: context,
        builder: (_) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
            // The background color
            backgroundColor: backgroundPrimary,
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
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: const InputDecoration(
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
                              child: Text('DELETE')),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
    return value;
  }

  void hide() {
    Navigator.of(context).pop();
  }
}
