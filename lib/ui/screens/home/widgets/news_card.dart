import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/const/colors/colors.dart';
import '../../../../utils/Setting.dart';
import '../../../../models/news.dart';
import '../../../../models/attachment.dart';

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  Color _getCategoryTagColor(String? category) {
    if (category == null) return AppColors.tagCampus;

    switch (category.toLowerCase()) {
      case 'campus':
        return AppColors.tagCampus;
      case 'études':
      case 'etudes':
        return AppColors.tagStudies;
      case 'emploi':
        return AppColors.tagEmployment;
      case 'culture':
        return AppColors.tagCulture;
      default:
        return AppColors.tagCampus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = news == news;
    String categoryName = news.program?.name ?? 'Programme';
    if (news.program == null && news.programId != null) {
      final p = Setting.programCtrl.getProgramById(news.programId!);
      if (p != null) categoryName = p.name;
    }
    final categoryColor = _getCategoryTagColor(categoryName);

    if (isLarge) {
      return _buildLargeCard(categoryName, categoryColor);
    } else {
      return _buildSmallCard(categoryName, categoryColor);
    }
  }

  Widget _buildLargeCard(String category, Color categoryColor) {
    final isApproved = news.moderatorApproved;
    final isRejected = news.invalidated;
    final isPending = !isApproved && !isRejected;
    final importanceColor = _getImportanceColor();
    final hasHighImportance =
        news.importance == Importance.importante ||
        news.importance == Importance.urgente;
    final bool shouldShowStatusBadge =
        !Setting.userRoleCtrl.isStudent();

    print("titleFinal: ${news.titleFinal}");

    return GestureDetector(
      onTap: () => Get.toNamed('/news/detail', arguments: news),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border:
              hasHighImportance
                  ? Border.all(color: importanceColor, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color:
                  hasHighImportance
                      ? importanceColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: hasHighImportance ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: _buildImage(),
                ),
                if (shouldShowStatusBadge)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _buildStatusBadge(
                      isPending,
                      isApproved,
                      isRejected,
                    ),
                  ),
                // Badge pour les news non lues
                if (isApproved)
                  Obx(() {
                    final isUnread =
                        !Setting.newsViewCtrl.isNewsViewed(news.id);
                    if (isUnread) {
                      return Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.notificationBadge,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(category),
                        backgroundColor: categoryColor,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      if (news.importance == Importance.importante ||
                          news.importance == Importance.urgente) ...[
                        const SizedBox(width: 8),
                        _buildImportanceBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.titleFinal.isNotEmpty
                        ? news.titleFinal
                        : news.titleDraft,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.contentFinal.isNotEmpty
                        ? news.contentFinal
                        : news.contentDraft,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeAgo(news.writtenAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(String category, Color categoryColor) {
    final isApproved = news.moderatorApproved;
    final isRejected = news.invalidated;
    final isPending = !isApproved && !isRejected;
    final importanceColor = _getImportanceColor();
    final hasHighImportance =
        news.importance == Importance.importante ||
        news.importance == Importance.urgente;
    final bool shouldShowStatusBadge =
        !Setting.userRoleCtrl.isStudent();

    return GestureDetector(
      onTap: () => Get.toNamed('/news/detail', arguments: news),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border:
              hasHighImportance
                  ? Border.all(color: importanceColor, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color:
                  hasHighImportance
                      ? importanceColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: hasHighImportance ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: _buildSmallImage(),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Chip(
                            label: Text(category),
                            backgroundColor: categoryColor,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        if (news.importance == Importance.importante ||
                            news.importance == Importance.urgente)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildImportanceBadge(),
                          ),
                        if (shouldShowStatusBadge)
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildStatusBadge(
                              isPending,
                              isApproved,
                              isRejected,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.titleFinal.isNotEmpty
                          ? news.titleFinal
                          : news.titleDraft,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(news.writtenAt),
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

  Widget _buildStatusBadge(bool isPending, bool isApproved, bool isRejected) {
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a ${difference.inDays ~/ 7}sem';
    }
  }

  Widget _buildImage() {
    final imageAttachment = _getFirstImageAttachment();
    if (imageAttachment == null) {
      return const Icon(Icons.image, size: 60, color: Colors.grey);
    }
    return Image.network(
      imageAttachment.file,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 60, color: Colors.grey);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSmallImage() {
    final imageAttachment = _getFirstImageAttachment();
    if (imageAttachment == null) {
      return const Icon(Icons.image, size: 40, color: Colors.grey);
    }
    return Image.network(
      imageAttachment.file,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  Attachment? _getFirstImageAttachment() {
    if (news.attachments.isEmpty) return null;
    return news.attachments.firstWhere(
      (att) => _isImageAttachment(att),
      orElse: () => news.attachments.first,
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

  Color _getImportanceColor() {
    switch (news.importance) {
      case Importance.urgente:
        return AppColors.error;
      case Importance.importante:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildImportanceBadge() {
    String label;
    Color color;
    IconData icon;

    switch (news.importance) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
