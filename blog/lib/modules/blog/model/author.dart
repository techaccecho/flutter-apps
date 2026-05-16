class Author {
  final String id;
  final String? alias;
  final String? firstName;
  final String? lastName;

  Author({
    required this.id,
    this.alias,
    this.firstName,
    this.lastName,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        id: json['id'],
        alias: json['alias'],
        firstName: json['firstName'],
        lastName: json['lastName'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'alias': alias,
        'firstName': firstName,
        'lastName': lastName,
      };
}