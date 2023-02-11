import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';

import '../api/model/todo.dart';
import '../constant.dart';

messageSnackbar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: textPrimary),
    ).p(2),
    behavior: SnackBarBehavior.floating,
  ));
}

todoSnackbar(BuildContext context, Todo item, [WidgetRef? ref]) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      item.completed ? 'Undo ${item.title}' : 'Completed "${item.title}"',
      textAlign: TextAlign.center,
      style: const TextStyle(color: textPrimary),
    ),
    behavior: SnackBarBehavior.floating,
  ));
}
