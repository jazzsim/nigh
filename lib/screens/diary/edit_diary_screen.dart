// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nigh/api/model/diary.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/components/loading_dialog.dart';
import 'package:nigh/components/snackbar.dart';
import 'package:nigh/constant.dart';

import '../../helper/dialogs.dart';
import 'diary_controller.dart';

final titleTextEditingProvider = Provider<TextEditingController>((ref) => TextEditingController());

final contentTextEditingProvider = Provider<TextEditingController>((ref) => TextEditingController());

class EditDiaryScreen extends ConsumerStatefulWidget {
  final Diary? diary;
  const EditDiaryScreen({super.key, this.diary});

  static MaterialPageRoute<dynamic> route({Diary? diary}) => MaterialPageRoute(builder: (context) => EditDiaryScreen(diary: diary));

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditDiaryScreenState();
}

class _EditDiaryScreenState extends ConsumerState<EditDiaryScreen> {
  final _scrollController = ScrollController();
  bool _save = false, _changed = false;

  @override
  void initState() {
    super.initState();
    if (widget.diary == null) ref.refresh(diaryStateProvider);
    ref.refresh(titleTextEditingProvider);
    ref.refresh(contentTextEditingProvider);

    if (widget.diary != null) {
      ref.read(titleTextEditingProvider).text = widget.diary!.title;
      ref.read(contentTextEditingProvider).text = widget.diary!.content ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool pop = true;
        if (_changed || (widget.diary == null && ref.watch(contentTextEditingProvider).text.isNotEmpty)) {
          await PopUpDialogs(context).confirmDialog('Discarding Diary', 'This can\'t be undone and you\'ll lost your unsaved diary', 'Discard').then((value) {
            pop = value;
          });
        }
        return pop;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          if (ref.watch(contentTextEditingProvider).text.isNotEmpty) _save = true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: backgroundPrimary,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Title',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary),
                                ).p(15),
                                TextFormField(
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.sentences,
                                  controller: ref.watch(titleTextEditingProvider),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary),
                                  minLines: 1,
                                  maxLines: 1,
                                ).pLTRB(20, 0, 20, 0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          if (ref.watch(titleTextEditingProvider).text.isEmpty) return;
                                          _changed = true;
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Change'))
                                  ],
                                ).pt(10)
                              ],
                            ).p(10),
                          );
                        });
                  },
                  child: Text(
                    ref.watch(titleTextEditingProvider).text.isEmpty ? 'Title' : ref.watch(titleTextEditingProvider).text,
                    style: TextStyle(color: ref.watch(titleTextEditingProvider).text.isEmpty ? textSecondary : null),
                  )),
              actions: [
                TextButton(
                    onPressed: ref.watch(contentTextEditingProvider).text.isNotEmpty
                        ? _save
                            ? () async {
                                LoadingScreen(context).show();
                                // when title is null, set default
                                if (ref.watch(titleTextEditingProvider).text.isEmpty) {
                                  ref.watch(titleTextEditingProvider).text = DateFormat.yMMMEd().format(ref.watch(diaryDatetimeStateProvider));
                                }
                                widget.diary == null ? await ref.watch(diaryNotifierProvider.notifier).add() : await ref.watch(diaryNotifierProvider.notifier).edit();
                                if (!mounted) return;
                                LoadingScreen(context).hide();
                                messageSnackbar(context, 'Saved Diary');
                                ref.invalidate(diaryNotifierProvider);
                                await ref.watch(diaryNotifierProvider.notifier).getDiaries(ref.watch(diaryDatetimeStateProvider).toString());
                                if (!mounted) return;
                                _changed = false;
                                Navigator.of(context).pop();
                              }
                            : () async {
                                _save = true;
                                FocusScopeNode currentFocus = FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              }
                        : () => _save = true,
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(ref.watch(contentTextEditingProvider).text.isNotEmpty
                        ? _save
                            ? 'Save'
                            : 'Done'
                        : ''))
              ],
            ),
            body: Column(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  child: TextFormField(
                    onTap: () => _save = false,
                    scrollController: _scrollController,
                    scrollPhysics: const BouncingScrollPhysics(),
                    controller: ref.watch(contentTextEditingProvider),
                    style: const TextStyle(color: textPrimary),
                    onChanged: (value) {
                      _changed = true;
                    },
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Write something...', hintStyle: TextStyle(color: textSecondary)),
                    maxLines: null,
                  ).p(10),
                ).exp(),
              ],
            )),
      ),
    );
  }
}
