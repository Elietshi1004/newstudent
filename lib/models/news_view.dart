import 'package:newstudent/models/columns.dart';
import 'package:newstudent/models/user.dart';
import 'package:newstudent/models/news.dart';

class NewsView {
  final int id;
  final int userId;
  final int newsId;
  final DateTime viewedAt;
  final UserModel? user;
  final News? news;

  NewsView({
    required this.id,
    required this.userId,
    required this.newsId,
    required this.viewedAt,
    this.user,
    this.news,
  });

  factory NewsView.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    int? parsedUserId;
    final userField = json[BDColumns.newsViewUser];
    if (userField is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(userField);
      parsedUserId = parsedUser.id;
    } else if (userField is int) {
      parsedUserId = userField;
    }

    News? parsedNews;
    int? parsedNewsId;
    final newsField = json[BDColumns.newsViewNews];
    if (newsField is Map<String, dynamic>) {
      parsedNews = News.fromJson(newsField);
      parsedNewsId = parsedNews.id;
    } else if (newsField is int) {
      parsedNewsId = newsField;
    }

    return NewsView(
      id: json[BDColumns.newsViewId] as int,
      userId: parsedUserId ?? json[BDColumns.newsViewUser] as int,
      newsId: parsedNewsId ?? json[BDColumns.newsViewNews] as int,
      viewedAt: DateTime.parse(json[BDColumns.newsViewViewedAt] as String),
      user: parsedUser,
      news: parsedNews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.newsViewId: id,
      BDColumns.newsViewUser: user != null ? user!.toJson() : userId,
      BDColumns.newsViewNews: news != null ? news!.toJson() : newsId,
      BDColumns.newsViewViewedAt: viewedAt.toIso8601String(),
    };
  }
}
