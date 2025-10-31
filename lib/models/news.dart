import 'package:newstudent/models/attachment.dart';

import 'columns.dart';
import 'user.dart';
import 'program.dart';

enum Importance { faible, moyenne, importante, urgente }

class News {
  final int id;
  final int? author;
  final Program? program;
  final int? programId; // supporte les réponses où program est un entier
  final String titleDraft;
  final String contentDraft;
  final String titleFinal;
  final String contentFinal;
  final Importance importance;
  final bool moderatorApproved;
  final UserModel? moderator;
  final DateTime writtenAt;
  final DateTime? moderatedAt;
  final DateTime? publishDateRequested;
  final DateTime? publishDateEffective;
  final bool invalidated;
  final UserModel? invalidatedBy;
  final String? invalidationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Attachment> attachments;

  News({
    required this.id,
    this.author,
    this.program,
    this.programId,
    required this.titleDraft,
    required this.contentDraft,
    required this.titleFinal,
    required this.contentFinal,
    required this.importance,
    required this.moderatorApproved,
    this.moderator,
    required this.writtenAt,
    this.moderatedAt,
    this.publishDateRequested,
    this.publishDateEffective,
    required this.invalidated,
    this.invalidatedBy,
    this.invalidationReason,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    Program? parsedProgram;
    int? parsedProgramId;
    final programValue = json[BDColumns.newsProgram];
    if (programValue is Map<String, dynamic>) {
      parsedProgram = Program.fromJson(programValue);
    } else if (programValue is int) {
      parsedProgramId = programValue;
    }

    return News(
      id: json[BDColumns.newsId] as int,
      author: json[BDColumns.newsAuthor] ?? 0,
      program: parsedProgram,
      programId: parsedProgramId,
      titleDraft: json[BDColumns.newsTitleDraft] as String? ?? '',
      contentDraft: json[BDColumns.newsContentDraft] as String? ?? '',
      titleFinal: json[BDColumns.newsTitleFinal] as String? ?? '',
      contentFinal: json[BDColumns.newsContentFinal] as String? ?? '',
      importance: _parseImportance(json[BDColumns.newsImportance] as String),
      moderatorApproved:
          json[BDColumns.newsModeratorApproved] as bool? ?? false,
      moderator:
          json[BDColumns.newsModerator] == null
              ? null
              : (json[BDColumns.newsModerator] is Map<String, dynamic>
                  ? UserModel.fromJson(
                    json[BDColumns.newsModerator] as Map<String, dynamic>,
                  )
                  : null),
      writtenAt: DateTime.parse(json[BDColumns.newsWrittenAt] as String),
      moderatedAt:
          json[BDColumns.newsModeratedAt] != null
              ? DateTime.parse(json[BDColumns.newsModeratedAt] as String)
              : null,
      publishDateRequested:
          json[BDColumns.newsPublishDateRequested] != null
              ? DateTime.parse(
                json[BDColumns.newsPublishDateRequested] as String,
              )
              : null,
      publishDateEffective:
          json[BDColumns.newsPublishDateEffective] != null
              ? DateTime.parse(
                json[BDColumns.newsPublishDateEffective] as String,
              )
              : null,
      invalidated: json[BDColumns.newsInvalidated] as bool? ?? false,
      invalidatedBy:
          json[BDColumns.newsInvalidatedBy] != null
              ? UserModel.fromJson(
                json[BDColumns.newsInvalidatedBy] as Map<String, dynamic>,
              )
              : null,
      invalidationReason: json[BDColumns.newsInvalidationReason] as String?,
      createdAt: DateTime.parse(json[BDColumns.newsCreatedAt] as String),
      updatedAt: DateTime.parse(json[BDColumns.newsUpdatedAt] as String),
      attachments:
          json[BDColumns.newsAttachments] != null
              ? (json[BDColumns.newsAttachments] as List)
                  .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }

  static Importance _parseImportance(String value) {
    switch (value) {
      case 'faible':
        return Importance.faible;
      case 'importante':
        return Importance.importante;
      case 'urgente':
        return Importance.urgente;
      default:
        return Importance.moyenne;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.newsId: id,
      BDColumns.newsAuthor: author,
      BDColumns.newsProgram:
          program != null
              ? program!.toJson()
              : programId, // envoie l'id si pas d'objet
      BDColumns.newsTitleDraft: titleDraft,
      BDColumns.newsContentDraft: contentDraft,
      BDColumns.newsTitleFinal: titleFinal,
      BDColumns.newsContentFinal: contentFinal,
      BDColumns.newsImportance: importance.name,
      BDColumns.newsModeratorApproved: moderatorApproved,
      BDColumns.newsModerator: moderator?.toJson(),
      BDColumns.newsWrittenAt: writtenAt.toIso8601String(),
      BDColumns.newsModeratedAt: moderatedAt?.toIso8601String(),
      BDColumns.newsPublishDateRequested:
          publishDateRequested?.toIso8601String(),
      BDColumns.newsPublishDateEffective:
          publishDateEffective?.toIso8601String(),
      BDColumns.newsInvalidated: invalidated,
      BDColumns.newsInvalidatedBy: invalidatedBy?.toJson(),
      BDColumns.newsInvalidationReason: invalidationReason,
      BDColumns.newsCreatedAt: createdAt.toIso8601String(),
      BDColumns.newsUpdatedAt: updatedAt.toIso8601String(),
      BDColumns.newsAttachments: attachments.map((a) => a.toJson()).toList(),
    };
  }
}
