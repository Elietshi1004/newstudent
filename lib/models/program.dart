import 'columns.dart';

class Program {
  final int id;
  final String name;
  final String code;

  Program({required this.id, required this.name, required this.code});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json[BDColumns.programId] as int,
      name: json[BDColumns.programName] as String,
      code: json[BDColumns.programCode] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.programId: id,
      BDColumns.programName: name,
      BDColumns.programCode: code,
    };
  }
}
