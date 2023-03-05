import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Todo {
  final int id;
  final String date;
  final String title;
  final String? reminderTime;
  final bool completed;

  const Todo({required this.id, required this.date, required this.title, this.reminderTime, required this.completed});

  Todo copyWith({int? id, String? date, String? title, String? reminderTime, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      reminderTime: reminderTime ?? this.reminderTime,
      completed: completed ?? this.completed,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
