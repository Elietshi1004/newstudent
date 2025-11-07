import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../utils/Setting.dart';
import '../../../../../models/news.dart';
import '../../../../../models/attachment.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Marquer la news comme vue quand la page s'affiche
      final News news = Get.arguments as News;
      if (news.moderatorApproved) {
        Setting.newsViewCtrl.markNewsAsViewed(news.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final News news = Get.arguments as News;
    final isApproved = news.moderatorApproved;
    final isRejected = news.invalidated;
    final isPending = !isApproved && !isRejected;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'actualité')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Programme et Importance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          news.program?.name ??
                              (() {
                                if (news.programId != null) {
                                  final p = Setting.programCtrl.getProgramById(
                                    news.programId!,
                                  );
                                  return p?.name ?? 'Programme';
                                }
                                return 'Programme';
                              })(),
                        ),
                        backgroundColor: AppColors.tagCampus,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (news.importance == Importance.importante ||
                          news.importance == Importance.urgente) ...[
                        const SizedBox(width: 8),
                        _buildImportanceBadge(news.importance),
                      ],
                    ],
                  ),
                  _statusBadge(isPending, isApproved, isRejected),
                ],
              ),
              const SizedBox(height: 12),

              // Titre
              Text(
                news.titleFinal.isNotEmpty ? news.titleFinal : news.titleDraft,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Meta
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(news.writtenAt),
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Images des attachments
              _buildAttachments(news),
              const SizedBox(height: 16),

              // Contenu
              Text(
                news.contentFinal.isNotEmpty
                    ? news.contentFinal
                    : news.contentDraft,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),

              if (isRejected && news.invalidationReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Raison du refus: ${news.invalidationReason}',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // S'abonner au programme si non abonné
              Builder(
                builder: (context) {
                  final programId = news.program?.id ?? news.programId;
                  printDebug('programId: $programId');
                  if (programId == null) return const SizedBox.shrink();

                  final subCtrl = Setting.subscriptionCtrl;
                  return Obx(() {
                    final isSub = subCtrl.isSubscribedToProgram(programId);
                    printDebug('isSub: $isSub');
                    if (isSub) return const SizedBox.shrink();
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            subCtrl.isLoading.value
                                ? null
                                : () async {
                                  await subCtrl.subscribeToProgram(programId);
                                },
                        icon: const Icon(Icons.notifications_active_outlined),
                        label:
                            subCtrl.isLoading.value
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('S\'abonner à ce programme'),
                      ),
                    );
                  });
                },
              ),

              const SizedBox(height: 32),

              // Section News Similaires
              _buildSimilarNewsSection(news),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimilarNewsSection(News currentNews) {
    final programId = currentNews.program?.id ?? currentNews.programId;
    if (programId == null) return const SizedBox.shrink();

    return Obx(() {
      final newsController = Setting.newsCtrl;
      final allNews = newsController.newsList;

      // Filtrer les news similaires (même programme, approuvées, exclure la news actuelle)
      final similarNews =
          allNews
              .where(
                (n) =>
                    n.moderatorApproved &&
                    (n.program?.id ?? n.programId) == programId &&
                    n.id != currentNews.id,
              )
              .toList();

      // Limiter à 6 news similaires et trier par date (plus récentes d'abord)
      similarNews.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
      final limitedSimilarNews = similarNews.take(6).toList();

      if (limitedSimilarNews.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Similaires à celle-ci',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Liste horizontale des news similaires
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: limitedSimilarNews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final similarNewsItem = limitedSimilarNews[index];
                return _buildSimilarNewsCard(similarNewsItem);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSimilarNewsCard(News news) {
    final programName =
        news.program?.name ??
        (news.programId != null
            ? (Setting.programCtrl.getProgramById(news.programId!)?.name ??
                'Programme')
            : 'Programme');

    // Récupérer la première image
    final imageAttachment =
        news.attachments.where((att) => _isImageAttachment(att)).firstOrNull;

    return InkWell(
      onTap: () {
        printDebug('news: ${news.id}');
        Get.to(() => const NewsDetailPage(), arguments: news);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textLight.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageAttachment != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Image.network(
                        imageAttachment.file,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 140,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 140,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                      // Badge d'importance
                      if (news.importance == Importance.urgente ||
                          news.importance == Importance.importante)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  news.importance == Importance.urgente
                                      ? AppColors.error
                                      : AppColors.warning,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  news.importance == Importance.urgente
                                      ? Icons.priority_high
                                      : Icons.star,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  news.importance == Importance.urgente
                                      ? 'Urgente'
                                      : 'Importante',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),

            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Programme
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tagCampus.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        programName,
                        style: TextStyle(
                          color: AppColors.tagCampus,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Titre
                    Expanded(
                      child: Text(
                        news.titleFinal.isNotEmpty
                            ? news.titleFinal
                            : news.titleDraft,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(news.writtenAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isPending, bool isApproved, bool isRejected) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'En attente',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (isApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Validée',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Refusée',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAttachments(News news) {
    final imageAttachments =
        news.attachments.where((att) => _isImageAttachment(att)).toList();

    if (imageAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    if (imageAttachments.length == 1) {
      return _buildSingleImage(imageAttachments.first);
    }

    return Column(
      children:
          imageAttachments.map((attachment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSingleImage(attachment),
            );
          }).toList(),
    );
  }

  Widget _buildSingleImage(Attachment attachment) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        attachment.file,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  bool _isImageAttachment(Attachment attachment) {
    if (attachment.mime == null) {
      // Vérifier par extension si pas de mime type
      final file = attachment.file.toLowerCase();
      return file.endsWith('.jpg') ||
          file.endsWith('.jpeg') ||
          file.endsWith('.png') ||
          file.endsWith('.gif') ||
          file.endsWith('.webp');
    }
    return attachment.mime!.startsWith('image/');
  }

  Widget _buildImportanceBadge(Importance importance) {
    String label;
    Color color;
    IconData icon;

    switch (importance) {
      case Importance.urgente:
        label = 'Urgente';
        color = AppColors.error;
        icon = Icons.priority_high;
        break;
      case Importance.importante:
        label = 'Importante';
        color = AppColors.warning;
        icon = Icons.star;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
