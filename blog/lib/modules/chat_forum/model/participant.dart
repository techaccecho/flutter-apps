import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/models/user_preview.dart';

class Participant {
  final String id;
  final String email;
  final String? alias;
  final String? firstName;
  final String? lastName;

  Participant({
    required this.id,
    required this.email,
    this.alias,
    this.firstName,
    this.lastName,
  });

  factory Participant.fromUser(User user) => Participant(
    id: user.id,
    email: user.email,
    alias: user.alias,
    firstName: user.firstName,
    lastName: user.lastName,
  );

  factory Participant.fromUserPreview(UserPreview user) => Participant(
    id: user.id,
    email: user.email,
    alias: user.alias,
    firstName: user.firstName,
    lastName: user.lastName,
  );
}
