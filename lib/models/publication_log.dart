import 'columns.dart';
import 'news.dart';

class PublicationLog {
  final int id;
  final News news;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final String channel;
  final int sentCount;

  PublicationLog({
    required this.id,
    required this.news,
    this.scheduledAt,
    this.publishedAt,
    required this.channel,
    required this.sentCount,
  });

  factory PublicationLog.fromJson(Map<String, dynamic> json) {
    return PublicationLog(
      id: json[BDColumns.publicationLogId] as int,
      news: News.fromJson(
        json[BDColumns.publicationLogNews] as Map<String, dynamic>,
      ),
      scheduledAt:
          json[BDColumns.publicationLogScheduledAt] != null
              ? DateTime.parse(
                json[BDColumns.publicationLogScheduledAt] as String,
              )
              : null,
      publishedAt:
          json[BDColumns.publicationLogPublishedAt] != null
              ? DateTime.parse(
                json[BDColumns.publicationLogPublishedAt] as String,
              )
              : null,
      channel: json[BDColumns.publicationLogChannel] as String,
      sentCount: json[BDColumns.publicationLogSentCount] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.publicationLogId: id,
      BDColumns.publicationLogNews: news.toJson(),
      BDColumns.publicationLogScheduledAt: scheduledAt?.toIso8601String(),
      BDColumns.publicationLogPublishedAt: publishedAt?.toIso8601String(),
      BDColumns.publicationLogChannel: channel,
      BDColumns.publicationLogSentCount: sentCount,
    };
  }
}
