import 'columns.dart';
import 'program.dart';
import 'user.dart';

class Subscription {
  final int id;
  final DateTime subscribedAt;
  final UserModel? user;
  final Program? program;
  final int? userId;
  final int? programId;

  Subscription({
    required this.id,
    required this.subscribedAt,
    this.user,
    this.program,
    this.userId,
    this.programId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final userField = json[BDColumns.subscriptionUser];
    final programField = json[BDColumns.subscriptionProgram];

    UserModel? parsedUser;
    int? parsedUserId;
    if (userField is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(userField);
    } else if (userField is int) {
      parsedUserId = userField;
    }

    Program? parsedProgram;
    int? parsedProgramId;
    if (programField is Map<String, dynamic>) {
      parsedProgram = Program.fromJson(programField);
    } else if (programField is int) {
      parsedProgramId = programField;
    }

    return Subscription(
      id: json[BDColumns.subscriptionId] as int,
      subscribedAt: DateTime.parse(
        json[BDColumns.subscriptionSubscribedAt] as String,
      ),
      user: parsedUser,
      program: parsedProgram,
      userId: parsedUserId,
      programId: parsedProgramId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.subscriptionId: id,
      BDColumns.subscriptionUser: user != null ? user!.toJson() : userId,
      BDColumns.subscriptionProgram:
          program != null ? program!.toJson() : programId,
      BDColumns.subscriptionSubscribedAt: subscribedAt.toIso8601String(),
    };
  }
}
