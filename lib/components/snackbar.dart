import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';

import '../api/model/todo.dart';
import '../constant.dart';

messageSnackbar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: backgroundSecondary,
    content: Container(
      decoration: const BoxDecoration(
          color: backgroundSecondary,
          borderRadius: BorderRadius.all(
            Radius.circular(13),
          )),
      child: Text(
        message,
        textAlign: TextAlign.center,
      ).p(2),
    ),
    behavior: SnackBarBehavior.floating,
  ));
}

todoSnackbar(BuildContext context, Todo item, [WidgetRef? ref]) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: themePrimary,
    content: Container(
      decoration: const BoxDecoration(
          color: themePrimary,
          borderRadius: BorderRadius.all(
            Radius.circular(13),
          )),
      child: Text(
        item.completed ? 'Undo ${item.title}' : 'Completed ${item.title}',
        textAlign: TextAlign.center,
      ),
    ),
    behavior: SnackBarBehavior.floating,
  ));
}
