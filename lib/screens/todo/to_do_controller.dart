import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/api/todo_api.dart';
import 'package:nigh/screens/todo/to_do_screen.dart';

import '../../api/model/todo.dart';

final todoLoadedStateProvider = StateProvider<bool>((ref) => false);

final todoDatetimeStateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dateStateProvider = StateProvider<String>((ref) => ref.watch(todoDatetimeStateProvider).toString().substring(0, 10));

final reminderDatetimeStateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final hasReminderStateProvider = StateProvider<bool>((ref) => false);

final reminderStateProvider = StateProvider<String?>((ref) => null);

final todoNotifierProvider = StateNotifierProvider<TodosNotifier, Map<String, List<Todo>>>((ref) => TodosNotifier(ref));

class TodosNotifier extends StateNotifier<Map<String, List<Todo>>> {
  StateNotifierProviderRef ref;
  TodosNotifier(this.ref) : super({});

  Future<void> getTodos(String date) async {
    ref.watch(todoLoadedStateProvider.notifier).state = false;
    String cleanDate = date.substring(0, 10);

    if (state.isNotEmpty) {
      bool exist = state.containsKey(cleanDate);
      if (exist) return;
    }

    final todoApi = TodoApi();
    final res = await todoApi.getTodos(date: cleanDate);
    if (res.response.isNotEmpty) {
      state = {
        ...state,
        res.response.first.date: [...res.response]
      };
    } else {
      state = {...state, cleanDate: []};
    }
    ref.watch(todoLoadedStateProvider.notifier).state = true;
  }

  Future<void> add(String? reminderTime) async {
    final todoApi = TodoApi();
    final res = await todoApi.addTodo(date: ref.watch(todoDatetimeStateProvider).toString(), title: ref.watch(todoTextEditingStateProvider).text, reminderTime: reminderTime);
    Todo newTodo = res.response;
    newTodo = newTodo.copyWith(date: newTodo.date.substring(0, 10));

    Map<String, List<Todo>> newTodoState = {};

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        List<Todo> todoList = [];
        for (var todo in element.value) {
          todoList.add(todo);
        }
        if (newTodo.date == element.key) todoList.add(newTodo);
        newTodoState.addAll({element.key: todoList});
      }
    }
    state = {...newTodoState};
  }

  Future<void> complete(int todoId) async {
    final todoApi = TodoApi();
    todoApi.complete(id: todoId);

    Map<String, List<Todo>> newTodoState = {};

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        List<Todo> todoList = [];
        for (var todo in element.value) {
          if (todo.id == todoId) {
            todo = todo.copyWith(completed: !todo.completed);
          }
          todoList.add(todo);
        }
        newTodoState.addAll({element.key: todoList});
      } else {
        List<Todo> copyOfTodoList = [];
        for (var todo in element.value) {
          copyOfTodoList.add(todo);
        }
        newTodoState.addAll({element.key: copyOfTodoList});
      }
    }
    state = {...newTodoState};
  }

  Future<void> edit(int todoId, String title, String? reminderTime) async {
    final todoApi = TodoApi();
    await todoApi.edit(id: todoId, title: title, reminderTime: reminderTime);

    Map<String, List<Todo>> test = {};
    List<Todo> todoList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var todo in element.value) {
          if (todo.id == todoId) {
            todo = todo.copyWith(title: title);
          }
          todoList.add(todo);
        }
        test.addAll({element.key: todoList});
      }
    }

    state = {...test};
  }

  Future<void> delete(int todoId) async {
    final todoApi = TodoApi();
    await todoApi.delete(id: todoId);

    Map<String, List<Todo>> test = {};
    List<Todo> todoList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var todo in element.value) {
          if (todo.id != todoId) {
            todoList.add(todo);
          }
        }
        test.addAll({element.key: todoList});
      }
    }

    state = {...test};
  }

  void setReminderDateTime(DateTime timerDateTime) => ref.watch(reminderDatetimeStateProvider.notifier).state = timerDateTime;

  void setReminder(String timer) => ref.watch(reminderStateProvider.notifier).state = timer;
}
