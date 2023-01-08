import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/model/user.dart';
import '../../api/user_api.dart';
import '../../appsetting.dart';
import '../../constant.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier(ref));

class UserNotifier extends StateNotifier<User> {
  StateNotifierProviderRef ref;
  UserNotifier(this.ref) : super(const User(id: 0, username: ''));

  // Future<void> initLogin([String? name, String? password]) async {
  //   final userApi = UserApi();
  //   await userApi.login(name: name, password: password).then((value) async {
  //     await globalSharedPrefs.setString('api_key', value.response.token ?? '');
  //     state = value.response;
  //     ref.read(loggedInStateProvider.notifier).state = true;
  //   }).catchError((err, st) {
  //     ref.watch(loggedInStateProvider.notifier).state = false;
  //   });
  // }
}

// class TodosNotifier extends StateNotifier<List<Todo>> {
//   StateNotifierProviderRef ref;
//   TodosNotifier(this.ref) : super([]);

//   String percentage() {
//     int totalCompleted = 0;
//     for (var todo in state) {
//       if (todo.completed) totalCompleted++;
//     }
//     return (totalCompleted / state.length * 100).toStringAsFixed(0).toString();
//   }

//   void addTodos(List<Todo> todos) {
//     state = [...state, ...todos];
//   }

//   void addTodo(Todo todo) {
//     state = [...state, todo];
//   }

//   void editTodo(int todoId, String title) {
//     state = [
//       for (final todo in state)
//         if (todo.id == todoId) todo.copyWith(id: todo.id, title: title, completed: todo.completed) else todo,
//     ];
//   }

//   void removeTodo(int todoId) {
//     state = [
//       for (final todo in state)
//         if (todo.id != todoId) todo,
//     ];
//   }

//   void toggle(int todoId) {
//     state = [
//       for (final todo in state)
//         if (todo.id == todoId) todo.copyWith(completed: !todo.completed) else todo,
//     ];
//   }
// }
