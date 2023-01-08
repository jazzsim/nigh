import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final num? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? token;

  const User({required this.id, required this.username, this.firstName, this.lastName, this.token});

  User copyWith({num? id, String? username}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName,
      lastName: lastName,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
