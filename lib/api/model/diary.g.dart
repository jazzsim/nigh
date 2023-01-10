// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Diary _$DiaryFromJson(Map<String, dynamic> json) => Diary(
      id: json['id'] as int,
      date: json['date'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$DiaryToJson(Diary instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'title': instance.title,
      'content': instance.content,
    };
