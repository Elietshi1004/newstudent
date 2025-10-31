import 'columns.dart';

class Moderation {
  final int id;
  final int newsId;
  final int? moderatorId;
  final bool approved;
  final String comment;
  final DateTime moderatedAt;

  Moderation({
    required this.id,
    required this.newsId,
    this.moderatorId,
    required this.approved,
    required this.comment,
    required this.moderatedAt,
  });

  factory Moderation.fromJson(Map<String, dynamic> json) {
    return Moderation(
      id: json[BDColumns.moderationId] as int,
      newsId:
          json[BDColumns.moderationNews] is int
              ? json[BDColumns.moderationNews] as int
              : (json[BDColumns.moderationNews] is Map<String, dynamic>
                  ? (json[BDColumns.moderationNews]
                          as Map<String, dynamic>)[BDColumns.newsId]
                      as int
                  : 0),
      moderatorId:
          json[BDColumns.moderationModerator] is int
              ? json[BDColumns.moderationModerator] as int
              : (json[BDColumns.moderationModerator] is Map<String, dynamic>
                  ? (json[BDColumns.moderationModerator]
                          as Map<String, dynamic>)[BDColumns.userId]
                      as int?
                  : null),
      approved: json[BDColumns.moderationApproved] as bool,
      comment: json[BDColumns.moderationComment] as String? ?? '',
      moderatedAt: DateTime.parse(
        json[BDColumns.moderationModeratedAt] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.moderationId: id,
      BDColumns.moderationNews: newsId,
      BDColumns.moderationModerator: moderatorId,
      BDColumns.moderationApproved: approved,
      BDColumns.moderationComment: comment,
      BDColumns.moderationModeratedAt: moderatedAt.toIso8601String(),
    };
  }
}
