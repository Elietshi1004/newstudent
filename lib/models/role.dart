import 'columns.dart';

class Role {
  final int id;
  final String name;
  final String? description;

  Role({required this.id, required this.name, this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json[BDColumns.roleId] as int,
      name: json[BDColumns.roleName] as String,
      description: json[BDColumns.roleDescription] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.roleId: id,
      BDColumns.roleName: name,
      BDColumns.roleDescription: description,
    };
  }
}
