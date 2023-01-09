import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/api/todo_api.dart';

import '../../api/model/todo.dart';

final loadedStateProvider = StateProvider<bool>((ref) => false);

final datetimeStateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dateStateProvider = StateProvider<String>((ref) => ref.watch(datetimeStateProvider).toString().substring(0, 10));

final todoNotifierProvider = StateNotifierProvider<TodosNotifier, Map<String, List<Todo>>>((ref) => TodosNotifier(ref));

class TodosNotifier extends StateNotifier<Map<String, List<Todo>>> {
  StateNotifierProviderRef ref;
  TodosNotifier(this.ref) : super({});

  Future<void> getTodos(String date) async {
    ref.watch(loadedStateProvider.notifier).state = false;
    String cleanDate = date.substring(0, 10);

    if (state.isNotEmpty) {
      bool exist = state.containsKey(cleanDate.substring(0, 10));
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
    ref.watch(loadedStateProvider.notifier).state = true;
  }

  Future<void> add(Todo todo) async {
    final todoApi = TodoApi();
    final res = await todoApi.addTodo(date: todo.date, title: todo.title);
    Todo newTodo = res.response;
    newTodo = newTodo.copyWith(date: newTodo.date.substring(0, 10));

    Map<String, List<Todo>> test = {};
    List<Todo> todoList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var todo in element.value) {
          todoList.add(todo);
        }
        if (newTodo.date == element.key) todoList.add(newTodo);
        test.addAll({element.key: todoList});
      }
    }
    state = {...test};
  }

  Future<void> complete(int todoId) async {
    final todoApi = TodoApi();
    await todoApi.complete(id: todoId);

    Map<String, List<Todo>> test = {};
    List<Todo> todoList = [];

    for (var element in state.entries) {
      if (ref.read(dateStateProvider.notifier).state == element.key) {
        for (var todo in element.value) {
          if (todo.id == todoId) {
            todo = todo.copyWith(completed: !todo.completed);
          }
          todoList.add(todo);
        }
        test.addAll({element.key: todoList});
      }
    }

    state = {...test};
  }

  Future<void> edit(int todoId, String title) async {
    final todoApi = TodoApi();
    await todoApi.edit(id: todoId, title: title);

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

  // void addTodos(List<Todo> todos) {
  //   state = [...state, ...todos];
  // }

  // void addTodo(Todo todo) {
  //   state = [...state, todo];
  // }

  // void editTodo(int todoId, String title) {
  //   state = [
  //     for (final todo in state)
  //       if (todo.id == todoId) todo.copyWith(id: todo.id, date: todo.date, title: desc, completed: todo.completed) else todo,
  //   ];
  // }

  // void removeTodo(int todoId) {
  //   state = [
  //     for (final todo in state)
  //       if (todo.id != todoId) todo,
  //   ];
  // }

  // void toggle(int todoId) {
  //   Map<String, List<Todo>> test = {};
  //   List<Todo> todoList = [];

  //   for (var element in state.entries) {
  //     if (ref.read(dateStateProvider.notifier).state == element.key) {
  //       for (var todo in element.value) {
  //         if (todo.id == todoId) {
  //           todo = todo.copyWith(completed: !todo.completed);
  //         }
  //         todoList.add(todo);
  //       }
  //       test.addAll({element.key: todoList});
  //     }
  //   }

  //   state = {...test};
  // }
}
