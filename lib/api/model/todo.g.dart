// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as int,
      date: json['date'] as String,
      title: json['title'] as String,
      reminderTime: json['reminder_time'] as String?,
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'title': instance.title,
      'reminder_time': instance.reminderTime,
      'completed': instance.completed,
    };
