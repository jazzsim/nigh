import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/api/diary_api.dart';
import 'package:nigh/screens/diary/edit_diary_screen.dart';

import '../../api/model/diary.dart';

final diaryLoadedStateProvider = StateProvider<bool>((ref) => false);

final diaryStateProvider = StateProvider<Diary>(
    (ref) => Diary(id: 0, date: ref.watch(diaryDatetimeStateProvider).toString(), title: '', content: ''));

final diaryDatetimeStateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dateStateProvider = StateProvider<String>((ref) => ref.watch(diaryDatetimeStateProvider).toString().substring(0, 10));

final diaryNotifierProvider = StateNotifierProvider<DiarysNotifier, Map<String, List<Diary>>>((ref) => DiarysNotifier(ref));

class DiarysNotifier extends StateNotifier<Map<String, List<Diary>>> {
  StateNotifierProviderRef ref;
  DiarysNotifier(this.ref) : super({});

  Future<void> getDiaries(String date) async {
    ref.watch(diaryLoadedStateProvider.notifier).state = false;
    String cleanDate = date.substring(0, 10);

    if (state.isNotEmpty) {
      bool exist = state.containsKey(cleanDate.substring(0, 10));
      if (exist) return;
    }

    final diaryApi = DiaryApi();
    final res = await diaryApi.getDiarys(date: cleanDate);
    if (res.response.isNotEmpty) {
      state = {
        ...state,
        res.response.first.date: [...res.response]
      };
    } else {
      state = {...state, cleanDate: []};
    }
    ref.watch(diaryLoadedStateProvider.notifier).state = true;
  }

  Future<void> add() async {
    final diaryApi = DiaryApi();
    final res = await diaryApi.addDiary(
        date: ref.watch(diaryDatetimeStateProvider).toString(), title: ref.watch(titleTextEditingProvider).text, content: ref.watch(contentTextEditingProvider).text);
    Diary newDiary = res.response;
    newDiary = newDiary.copyWith(date: newDiary.date.substring(0, 10));

    Map<String, List<Diary>> test = {};
    List<Diary> diaryList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var diary in element.value) {
          diaryList.add(diary);
        }
        if (newDiary.date == element.key) diaryList.add(newDiary);
        test.addAll({element.key: diaryList});
      }
    }
    state = {...test};
  }

  Future<void> edit() async {
    final diaryApi = DiaryApi();
    await diaryApi.edit(id: ref.watch(diaryStateProvider).id, title: ref.watch(titleTextEditingProvider).text, content: ref.watch(contentTextEditingProvider).text);

    Map<String, List<Diary>> test = {};
    List<Diary> diaryList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var diary in element.value) {
          if (diary.id == ref.watch(diaryStateProvider).id) {
            diary = diary.copyWith(title: ref.watch(titleTextEditingProvider).text, content: ref.watch(contentTextEditingProvider).text);
          }
          diaryList.add(diary);
        }
        test.addAll({element.key: diaryList});
      }
    }

    state = {...test};
  }

  Future<void> delete(int diaryId) async {
    final diaryApi = DiaryApi();
    await diaryApi.delete(id: diaryId);

    Map<String, List<Diary>> test = {};
    List<Diary> diaryList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var diary in element.value) {
          if (diary.id != diaryId) {
            diaryList.add(diary);
          }
        }
        test.addAll({element.key: diaryList});
      }
    }

    state = {...test};
  }
}
