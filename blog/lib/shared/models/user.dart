import 'package:blog/shared/models/attachment.dart';
import 'package:intl/intl.dart';

class User {
  final String id;
  final String authId;
  final String email;
  final String? alias;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? bio;
  final String role;
  final bool isLocked;
  final Attachment? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime lastActivityAt;

  User({
    required this.id,
    required this.authId,
    required this.email,
    this.alias,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.bio,
    required this.role,
    required this.isLocked,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
    required this.lastActivityAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    authId: json['authId'],
    email: json['email'],
    alias: json['alias'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    dateOfBirth: json['dateOfBirth'],
    bio: json['bio'],
    role: json['role'],
    isLocked: json['isLocked'],
    avatar: json['avatar'] != null ? Attachment.fromJson(json['avatar']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    lastActivityAt: DateTime.parse(json['lastActivityAt'])
  );

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

  String get displayCreatedAt => DateFormat('yyyy-MM-dd').format(createdAt.toLocal());
}