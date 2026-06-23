import 'package:blog/shared/models/user_preview.dart';

class Reaction {
  final String id;
  final UserPreview user;
  final String code;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reaction({
    required this.id,
    required this.user,
    required this.code,
    required this.createdAt,
    this.updatedAt
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
    id: json['id'],
    user: UserPreview.fromJson(json['user']),
    code: json['code'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'code': code,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}