import 'columns.dart';

class Attachment {
  final int id;
  final int news;
  final String file;
  final String? mime;
  final int filesize;

  Attachment({
    required this.id,
    required this.news,
    required this.file,
    this.mime,
    required this.filesize,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json[BDColumns.attachmentId] as int,
      news: json[BDColumns.attachmentNews] as int,
      file: json[BDColumns.attachmentFile] as String,
      mime: json[BDColumns.attachmentMime] as String?,
      filesize: json[BDColumns.attachmentFilesize] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.attachmentId: id,
      BDColumns.attachmentNews: news,
      BDColumns.attachmentFile: file,
      BDColumns.attachmentMime: mime,
      BDColumns.attachmentFilesize: filesize,
    };
  }
}
