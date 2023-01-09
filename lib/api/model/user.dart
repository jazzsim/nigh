import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final num? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? token;
  final bool? isGuest;

  const User({required this.id, required this.username, this.firstName, this.lastName, this.token, this.isGuest});

  User copyWith({num? id, String? username}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName,
      lastName: lastName,
      isGuest: isGuest,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
