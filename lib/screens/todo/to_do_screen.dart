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
import '../../components/loading_dialog.dart';
import '../../components/snackbar.dart';
import '../../constant.dart';

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
                                                child: Text('Deleting ${todo.title}'),
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
  final editTextEditingController = TextEditingController();
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
                      showDialog(
                          context: context,
                          builder: (BuildContext c) {
                            editTextEditingController.text = widget.todo.title;
                            return ProviderScope(
                              parent: ProviderScope.containerOf(context),
                              child: Dialog(
                                backgroundColor: backgroundPrimary,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: 'Edit ',
                                        children: <InlineSpan>[
                                          TextSpan(
                                            text: widget.todo.title,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: themePrimary),
                                          )
                                        ],
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).p(15),
                                    TextFormField(
                                      autofocus: true,
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: editTextEditingController,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary),
                                      minLines: 1,
                                      maxLines: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () async {
                                              if (editTextEditingController.text.isEmpty) return;
                                              LoadingScreen(context).show();
                                              await ref.watch(todoNotifierProvider.notifier).edit(widget.todo.id, editTextEditingController.text);
                                              if (!mounted) return;
                                              LoadingScreen(context).hide();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Edit'))
                                      ],
                                    ).pt(10)
                                  ],
                                ).p(10),
                              ),
                            );
                          });
                    },
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '${widget.todo.title} ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: widget.todo.completed ? themePrimary : textPrimary, decoration: widget.todo.completed ? TextDecoration.lineThrough : null),
                    ).pl(16),
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
