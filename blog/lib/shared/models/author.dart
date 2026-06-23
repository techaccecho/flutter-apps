import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/models/user_preview.dart';

class Author {
  final String id;
  final String email;
  final String? alias;
  final String? firstName;
  final String? lastName;

  Author({
    required this.id,
    required this.email,
    this.alias,
    this.firstName,
    this.lastName,
  });

  String get displayName {
    final currentAlias = alias;
    
    if (currentAlias != null && currentAlias.trim().isNotEmpty)  {
      return currentAlias;
    }

    final currentFirstName = firstName;

    if (currentFirstName != null && currentFirstName.trim().isNotEmpty) {
      return currentFirstName;
    }

    final currentLastName = lastName;

    if (currentLastName != null && currentLastName.trim().isNotEmpty) {
      return currentLastName;
    }

    return email;
  }

  factory Author.fromUser(User user) => Author(
    id: user.id,
    email: user.email,
    alias: user.alias,
    firstName: user.firstName,
    lastName: user.lastName,
  );

  factory Author.fromUserPreview(UserPreview user) => Author(
    id: user.id,
    email: user.email,
    alias: user.alias,
    firstName: user.firstName,
    lastName: user.lastName,
  );
}
