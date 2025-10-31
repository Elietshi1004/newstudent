import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../utils/Setting.dart';
import '../../../../../models/news.dart';
import '../../../../../models/attachment.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key});

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
            ],
          ),
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
