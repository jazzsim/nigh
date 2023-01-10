import 'package:json_annotation/json_annotation.dart';

part 'diary.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Diary {
  final int id;
  final String date;
  final String title;
  final String? content;

  const Diary({required this.id, required this.date, required this.title, this.content});

  Diary copyWith({int? id, String? date, String? title, String? content}) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  factory Diary.fromJson(Map<String, dynamic> json) => _$DiaryFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryToJson(this);
}
