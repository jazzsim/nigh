import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nigh/appsetting.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/screens/todo/to_do_controller.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

import '../../animation/expansion_animation.dart';
import '../../animation/rotate_animation.dart';
import '../../api/model/todo.dart';
import '../../components/snackbar.dart';
import '../../constant.dart';
import 'edit_to_do_screen.dart';

final todoTextEditingStateProvider = StateProvider<TextEditingController>((ref) => TextEditingController());

class ToDoScreen extends ConsumerStatefulWidget {
  const ToDoScreen({super.key});

  @override
  ConsumerState<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends ConsumerState<ToDoScreen> {
  bool _weekAnimation = true, _loaded = false;

  @override
  Widget build(BuildContext context) {
    List<Todo> todoList = ref.watch(todoNotifierProvider)[ref.watch(todoDatetimeStateProvider).toString().substring(0, 10)] ?? [];

    ref.listen<bool>(todoLoadedStateProvider, ((previous, next) {
      _loaded = next;
    }));
    // work on reminder UI for todo item and carry disable reminder after today
    return RefreshIndicator(
      onRefresh: (() => _getData()),
      color: textPrimary,
      backgroundColor: backgroundSecondary,
      child: Scaffold(
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                _weekAnimation = !_weekAnimation;
                setState(() {});
              },
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: Colors.transparent,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat.yMMMEd().format(ref.watch(todoDatetimeStateProvider))),
                      RotateAnimation(
                        rotate: _weekAnimation,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: textPrimary,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            ExpansionAnimation(
              expand: _weekAnimation,
              child: WeeklyDatePicker(
                selectedDay: ref.watch(todoDatetimeStateProvider),
                changeDay: (value) => setState(() {
                  ref.watch(todoDatetimeStateProvider.notifier).state = value;
                  _loaded = false;
                  ref.watch(todoNotifierProvider.notifier).getTodos(ref.watch(todoDatetimeStateProvider).toString()).then((value) {
                    _loaded = true;
                  });
                }),
                enableWeeknumberText: false,
                weeknumberColor: themePrimary,
                weeknumberTextColor: textPrimary,
                backgroundColor: backgroundPrimary,
                weekdayTextColor: textSecondary,
                digitsColor: Colors.white,
                selectedBackgroundColor: themePrimary,
                weekdays: const ["Mo", "Tu", "We", "Th", "Fr", "Sat", "Sun"],
                daysInWeek: 7,
              ),
            ),
            _loaded
                ? ListView(
                        shrinkWrap: true,
                        physics: todoList.isEmpty ? const NeverScrollableScrollPhysics() : null,
                        children: todoList.isEmpty
                            ? [
                                Container(
                                  padding: const EdgeInsets.all(20.0),
                                  constraints: BoxConstraints(
                                    minHeight: MediaQuery.of(context).size.height / 2,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Empty',
                                      style: ref.watch(textThemeProvider(context)).bodyMedium?.copyWith(color: textSecondary),
                                    ),
                                  ),
                                ),
                              ]
                            : todoList
                                .map((todo) => Dismissible(
                                      key: UniqueKey(),
                                      background: Container(
                                        color: themePrimary,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'Remove',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                                              ).pr(5),
                                              const Icon(
                                                Icons.delete,
                                                color: textPrimary,
                                              ).pr(10)
                                            ],
                                          ),
                                        ),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (_) async {
                                        int index = todoList.indexOf(todo);
                                        Todo deletedItem = todoList.removeAt(index);
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                              backgroundColor: Colors.transparent,
                                              content: Container(
                                                padding: const EdgeInsets.all(18),
                                                decoration: const BoxDecoration(
                                                    color: themePrimary,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(13),
                                                    )),
                                                child: Text(
                                                  'Deleting ${todo.title}',
                                                  style: const TextStyle(color: textPrimary),
                                                ),
                                              ),
                                              action: SnackBarAction(
                                                onPressed: () => setState(() {
                                                  todoList.add(deletedItem);
                                                }),
                                                label: 'Undo',
                                              ),
                                              behavior: SnackBarBehavior.floating,
                                            ))
                                            .closed
                                            .then((reason) {
                                          if (reason != SnackBarClosedReason.action) {
                                            ref.watch(todoNotifierProvider.notifier).delete(todo.id);
                                          }
                                        });
                                      },
                                      child: CheckboxLT(
                                        todo: todo,
                                      ),
                                    ))
                                .toList())
                    .exp()
                : const Center(
                    child: CircularProgressIndicator(),
                  ).exp(),
          ],
        ),
      ),
    );
  }

  Future<void> _getData() async {
    ref.invalidate(todoNotifierProvider);
    await ref.watch(todoNotifierProvider.notifier).getTodos(ref.watch(todoDatetimeStateProvider).toString());
  }
}

class CheckboxLT extends ConsumerStatefulWidget {
  final Todo todo;
  const CheckboxLT({super.key, required this.todo});

  @override
  ConsumerState<CheckboxLT> createState() => _CheckboxLTState();
}

class _CheckboxLTState extends ConsumerState<CheckboxLT> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggle(),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.todo.completed
                  ? null
                  : () {
                      if (widget.todo.reminderTime?.isNotEmpty ?? false) {
                        String reminder = DateFormat("h:mma").format(DateTime.parse((widget.todo.reminderTime!)));
                        ref.read(reminderDatetimeStateProvider.notifier).state = DateTime.parse(widget.todo.reminderTime!);
                        ref.read(reminderStateProvider.notifier).state = reminder;
                        ref.read(hasReminderStateProvider.notifier).state = true;
                      }
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          return EditTodoScreen(todo: widget.todo);
                        },
                      ).then((value) async {
                        if (value ?? false) {
                          ref.invalidate(todoNotifierProvider);
                          await ref.watch(todoNotifierProvider.notifier).getTodos(ref.watch(todoDatetimeStateProvider).toString());
                        }
                        await Future.delayed(const Duration(milliseconds: 500));
                        ref.invalidate(reminderDatetimeStateProvider);
                        ref.invalidate(hasReminderStateProvider);
                        ref.invalidate(reminderStateProvider);
                        ref.invalidate(todoTextEditingStateProvider);
                      });
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${widget.todo.title} ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decorationColor: themePrimary,
                                color: widget.todo.completed ? themePrimary : textPrimary,
                                decoration: widget.todo.completed ? TextDecoration.lineThrough : null,
                              ),
                        ),
                      ),
                      widget.todo.completed
                          ? const SizedBox()
                          : const Icon(
                              Icons.edit,
                              color: textPrimary,
                              size: 16,
                            )
                    ],
                  ),
                  (widget.todo.reminderTime?.isNotEmpty ?? false) && !widget.todo.completed
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DateTime.now().isBefore((DateTime.parse(widget.todo.reminderTime ?? '')))
                                ? const Icon(
                                    Icons.notifications_active,
                                    color: themePrimary,
                                    size: 16,
                                  )
                                : const Icon(
                                    Icons.notifications,
                                    color: textSecondary,
                                    size: 16,
                                  ),
                            Text(
                              '  ${DateFormat("h:mma").format(DateTime.parse(widget.todo.reminderTime!))}',
                              style: DateTime.now().isBefore((DateTime.parse(widget.todo.reminderTime ?? '')))
                                  ? const TextStyle(color: textPrimary)
                                  : const TextStyle(color: textSecondary),
                            )
                          ],
                        )
                      : const SizedBox()
                ],
              ).pl(16),
            ).exp(8),
            Checkbox(shape: const CircleBorder(), checkColor: backgroundPrimary, value: widget.todo.completed, onChanged: (value) => _toggle()).pr(12)
          ],
        ),
      ),
    );
  }

  void _toggle() {
    ref.read(todoNotifierProvider.notifier).complete(widget.todo.id);
    // toast
    if (!widget.todo.completed) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      todoSnackbar(context, widget.todo, ref);
    }
  }
}
