import 'columns.dart';

class UserRole {
  final int id;
  final int user;
  final int role;

  UserRole({required this.id, required this.user, required this.role});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json[BDColumns.userRoleId] as int,
      user: json[BDColumns.userRoleUser],
      role: json[BDColumns.userRoleRole],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.userRoleId: id,
      BDColumns.userRoleUser: user,
      BDColumns.userRoleRole: role,
    };
  }
}
