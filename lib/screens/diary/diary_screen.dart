import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nigh/apptheme.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

import '../../animation/expansion_animation.dart';
import '../../animation/rotate_animation.dart';
import '../../api/model/diary.dart';
import '../../appsetting.dart';
import '../../constant.dart';
import 'edit_diary_screen.dart';
import 'diary_controller.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  bool _weekAnimation = true, _loaded = false;
  final contentTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Diary> diaryList = ref.watch(diaryNotifierProvider)[ref.watch(diaryDatetimeStateProvider).toString().substring(0, 10)] ?? [];

    ref.listen<bool>(diaryLoadedStateProvider, ((previous, next) {
      _loaded = next;
    }));

    return RefreshIndicator(
      onRefresh: _getData,
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
                      Text(DateFormat.yMMMEd().format(ref.watch(diaryDatetimeStateProvider))),
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
                selectedDay: ref.watch(diaryDatetimeStateProvider),
                changeDay: (value) => setState(() {
                  ref.watch(diaryDatetimeStateProvider.notifier).state = value;
                  _loaded = false;
                  ref.watch(diaryNotifierProvider.notifier).getDiaries(ref.watch(diaryDatetimeStateProvider).toString()).then((value) {
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
                        physics: diaryList.isEmpty ? const NeverScrollableScrollPhysics() : null,
                        children: diaryList.isEmpty
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
                            : diaryList.map((diary) {
                                contentTextEditingController.text = diary.content ?? '[Empty]';
                                return Dismissible(
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
                                    int index = diaryList.indexOf(diary);
                                    Diary deletedItem = diaryList.removeAt(index);
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
                                            child: Text('Deleting ${diary.title}'),
                                          ),
                                          action: SnackBarAction(
                                            onPressed: () => setState(() {
                                              diaryList.add(deletedItem);
                                            }),
                                            label: 'Undo',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ))
                                        .closed
                                        .then((reason) {
                                      if (reason != SnackBarClosedReason.action) {
                                        ref.watch(diaryNotifierProvider.notifier).delete(diary.id);
                                      }
                                    });
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(diaryStateProvider.notifier).state = diary;
                                      Navigator.of(context).push(EditDiaryScreen.route(diary: diary));
                                    },
                                    child: Card(
                                            color: backgroundSecondary,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(diary.title, style: ref.watch(textThemeProvider(context)).titleLarge?.copyWith(color: themePrimary)),
                                                SizedBox(
                                                  height: MediaQuery.of(context).size.height * 0.15,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    enabled: false,
                                                    enableInteractiveSelection: false,
                                                    scrollPhysics: const NeverScrollableScrollPhysics(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(color: contentTextEditingController.text == '[Empty]' ? textSecondary : textPrimary),
                                                    initialValue: contentTextEditingController.text,
                                                    decoration: const InputDecoration(border: InputBorder.none),
                                                    maxLines: null,
                                                  ).pLTRB(10, 0, 10, 10),
                                                )
                                              ],
                                            ).pLTRB(20, 20, 20, 10))
                                        .p(20),
                                  ),
                                );
                              }).toList())
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
    ref.invalidate(diaryNotifierProvider);
    await ref.watch(diaryNotifierProvider.notifier).getDiaries(ref.watch(diaryDatetimeStateProvider).toString());
  }
}
