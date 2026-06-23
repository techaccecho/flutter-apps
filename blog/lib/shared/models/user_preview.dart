import 'package:blog/shared/models/user.dart';

class UserPreview {
  final String id;
  final String email;
  final String? alias;
  final String? firstName;
  final String? lastName;

  UserPreview({
    required this.id,
    required this.email,
    this.alias,
    this.firstName,
    this.lastName,
  });

  String get displayName {
    final currentAlias = alias;

    if (currentAlias != null) {
      return currentAlias;
    }

    final currentFirstName = firstName;

    if (currentFirstName != null) {
      return currentFirstName;
    }

    final currentLastName = lastName;

    if (currentLastName != null) {
      return currentLastName;
    }

    return email;
  }

  factory UserPreview.fromJson(Map<String, dynamic> json) => UserPreview(
    id: json['id'],
    email: json['email'],
    alias: json['alias'],
    firstName: json['firstName'],
    lastName: json['lastName']
  );

  factory UserPreview.fromUser(User user) =>  UserPreview(
    id: user.id,
    email: user.email,
    alias: user.alias,
    firstName: user.firstName,
    lastName: user.lastName
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'alias': alias,
      'firstName': firstName,
      'lastName': lastName
    };
  }
}