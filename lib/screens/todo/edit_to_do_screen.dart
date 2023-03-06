import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/screens/todo/to_do_controller.dart';
import 'package:nigh/screens/todo/to_do_screen.dart';

import '../../api/model/todo.dart';
import '../../components/loading_dialog.dart';
import '../../constant.dart';
import '../../helper/dialogs.dart';
import '../../notification/firebase_message.dart';

class EditTodoScreen extends ConsumerStatefulWidget {
  final Todo? todo;
  const EditTodoScreen({this.todo, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends ConsumerState<EditTodoScreen> {
  DateTime threeMinutesLater = DateTime.now().add(const Duration(minutes: 3));
  String? reminderTime;
  bool edit = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      edit = true;
      ref.read(todoTextEditingStateProvider).text = widget.todo?.title ?? '';
    }
    // ignore: unused_result
    // ref.refresh(reminderDatetimeStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundSecondary,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: backgroundSecondary,
            automaticallyImplyLeading: false,
            title: edit
                ? Text.rich(
                    TextSpan(
                      text: 'Edit ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: ref.watch(todoTextEditingStateProvider).text,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: themePrimary),
                        )
                      ],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textPrimary),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'Add new to do',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
            actions: ref.watch(todoDatetimeStateProvider).day == DateTime.now().day || ref.watch(todoDatetimeStateProvider).isAfter(DateTime.now())
                ? [
                    IconButton(
                        onPressed: () async {
                          if (ref.watch(disabledNotification)) {
                            // check again
                            bool allowedNotification = await ref.read(firebaseMessageProvider).checkPermission();
                            if (allowedNotification) {
                              ref.watch(disabledNotification.notifier).state = false;
                            } else {
                              if (!mounted) return;
                              PopUpDialogs(context).messageDialog('Reminder Feature', 'Notification permission is required for the reminder feature');
                              return;
                            }
                          }
                          ref.watch(hasReminderStateProvider.notifier).state = !ref.watch(hasReminderStateProvider);
                          if (!ref.watch(hasReminderStateProvider)) reminderTime = null;
                        },
                        icon: ref.watch(hasReminderStateProvider)
                            ? const Icon(Icons.notifications)
                            : const Icon(
                                Icons.notifications_off,
                                color: textSecondary,
                              ))
                  ]
                : [const SizedBox()],
          ),
          TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            controller: ref.watch(todoTextEditingStateProvider),
            minLines: 1,
            maxLines: 1,
          ).pLTRB(20, 0, 20, 0),
          AppBar(
            backgroundColor: backgroundSecondary,
            automaticallyImplyLeading: false,
            title: ref.watch(hasReminderStateProvider)
                ? ref.watch(todoDatetimeStateProvider).day == DateTime.now().day || ref.watch(todoDatetimeStateProvider).isAfter(DateTime.now())
                    ? ElevatedButton(
                        onPressed: () {
                          showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 200,
                                  padding: const EdgeInsets.only(top: 6.0),
                                  color: CupertinoColors.white,
                                  child: DefaultTextStyle(
                                    style: const TextStyle(
                                      color: CupertinoColors.black,
                                      fontSize: 22.0,
                                    ),
                                    child: SafeArea(
                                      top: false,
                                      child: CupertinoDatePicker(
                                        // minimumDate: threeMinutesLater,
                                        // initialDateTime: ref.watch(reminderDatetimeStateProvider) ?? threeMinutesLater,
                                        minimumDate: DateTime.now(),
                                        initialDateTime: ref.watch(reminderDatetimeStateProvider) ?? DateTime.now(),
                                        mode: CupertinoDatePickerMode.time,
                                        onDateTimeChanged: (value) => setState(() {
                                          // for API
                                          reminderTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
                                          // for UI
                                          ref.watch(reminderDatetimeStateProvider.notifier).state = value;
                                          ref.watch(reminderStateProvider.notifier).state = DateFormat("h:mma").format(value);
                                        }),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text(
                          ref.watch(reminderStateProvider) ?? 'Set Reminer',
                          style: const TextStyle(color: textPrimary),
                        ))
                    : const SizedBox()
                : const SizedBox(),
            actions: [
              TextButton(
                  onPressed: () async {
                    if (ref.watch(todoTextEditingStateProvider).text.isEmpty) return;
                    // add Todo
                    LoadingScreen(context).show();
                    if (!ref.watch(hasReminderStateProvider)) reminderTime = null;
                    edit
                        ? await ref.watch(todoNotifierProvider.notifier).edit(widget.todo?.id ?? 0, ref.watch(todoTextEditingStateProvider).text, reminderTime)
                        : await ref.watch(todoNotifierProvider.notifier).add(reminderTime);
                    if (!mounted) return;
                    LoadingScreen(context).hide();
                    Navigator.of(context).pop(true);
                  },
                  child: Text(edit ? 'Edit' : 'Add'))
            ],
          ).pLTRB(0, 10, 0, 10),
        ],
      ).pLTRB(10, 10, 10, MediaQuery.of(context).viewInsets.bottom),
    );
  }
}
