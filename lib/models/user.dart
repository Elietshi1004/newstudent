import 'columns.dart';

class UserModel {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[BDColumns.userId] as int,
      username: json[BDColumns.username] as String,
      email: json[BDColumns.email] as String?,
      firstName: json[BDColumns.firstName] as String?,
      lastName: json[BDColumns.lastName] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.userId: id,
      BDColumns.username: username,
      BDColumns.email: email,
      BDColumns.firstName: firstName,
      BDColumns.lastName: lastName,
    };
  }
}
