import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../controllers/news_controller.dart';
import '../../../../../controllers/moderation_controller.dart';
import '../../../../../models/news.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  final NewsController _newsController = Setting.newsCtrl;
  final ModerationController _moderationController = Setting.moderationCtrl;
  String _filterStatus = 'En attente';
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _newsController.fetchPendingNews();
  }

  List<News> get _filteredNews {
    var news = List<News>.from(_newsController.newsListModerator);
    print("news: ${news.length}");

    // Filtrer selon le statut de modération
    if (_filterStatus == 'En attente') {
      news = news.where((n) => !n.moderatorApproved && !n.invalidated).toList();
      print("news: ${news.length}");
    } else if (_filterStatus == 'Approuvées') {
      news = news.where((n) => n.moderatorApproved).toList();
    } else if (_filterStatus == 'Refusées') {
      news = news.where((n) => n.invalidated).toList();
    }

    // Trier par date de rédaction (plus récent en premier)
    news.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
    print("news: ${news.length}");

    return news;
  }

  int get _totalPages {
    final total = _filteredNews.length;
    final pages = (total / _pageSize).ceil();
    return pages == 0 ? 1 : pages;
  }

  List<News> get _pagedNews {
    final list = _filteredNews;
    if (_currentPage > _totalPages) _currentPage = _totalPages;
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, list.length);
    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Modération',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final pendingCount =
                        _newsController.newsListModerator
                            .where(
                              (n) => !n.moderatorApproved && !n.invalidated,
                            )
                            .length;
                    if (pendingCount > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.notificationBadge,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            // Filtres
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount:
                    [
                      /* 'Tout', */ 'En attente',
                      'Approuvées',
                      'Refusées',
                    ].length,
                itemBuilder: (context, index) {
                  final status =
                      [
                        /* 'Tout', */ 'En attente',
                        'Approuvées',
                        'Refusées',
                      ][index];
                  final isSelected = _filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          _filterStatus = status;
                          _currentPage = 1; // reset page on filter change
                        });
                        // Charger selon l'onglet
                        if (status == 'En attente') {
                          print("fetchPendingNews");
                          await _newsController.fetchPendingNews();
                        } else if (status == 'Approuvées') {
                          await _newsController.fetchApprovedNews();
                        } else if (status == 'Refusées') {
                          await _newsController.fetchRejectedNews();
                        } else {
                          // Par défaut: afficher en attente
                          await _newsController.fetchPendingNews();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.categorySelected
                                  : AppColors.categoryUnselected,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Liste des news à modérer
            Expanded(
              child: Obx(() {
                if (_newsController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                }

                final news = _pagedNews;
                if (news.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus == 'En attente'
                              ? 'Aucune news en attente'
                              : 'Aucune news',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: news.length,
                        itemBuilder: (context, index) {
                          final newsItem = news[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildModerationCard(newsItem),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Page $_currentPage / $_totalPages',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed:
                                    _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                child: const Text('Précédent'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed:
                                    _currentPage < _totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                child: const Text('Suivant'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationCard(News news) {
    final isPending = !news.moderatorApproved && !news.invalidated;
    final isApproved = news.moderatorApproved;
    final isRejected = news.invalidated;

    return InkWell(
      onTap: () => Get.toNamed('/news/detail', arguments: news),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.titleDraft.isNotEmpty
                              ? news.titleDraft
                              : news.titleFinal,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (news.program != null)
                          Chip(
                            label: Text(news.program!.name),
                            backgroundColor: AppColors.tagCampus,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(isPending, isApproved, isRejected),
                ],
              ),

              const SizedBox(height: 12),

              // Contenu
              Text(
                news.contentDraft.isNotEmpty
                    ? news.contentDraft
                    : news.contentFinal,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Infos
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  FutureBuilder(
                    future: Setting.usersCtrl.getUserById(news.author ?? 0),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 60,
                          child: LinearProgressIndicator(minHeight: 2),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return Text(
                          snapshot.data!.username,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        );
                      } else {
                        return const Text(
                          'Auteur inconnu',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(news.writtenAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Actions
              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectNews(news),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Refuser'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveNews(news),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approuver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              else if (isRejected && news.invalidationReason != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Raison: ${news.invalidationReason}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPending, bool isApproved, bool isRejected) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'En attente',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (isApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Approuvée',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Refusée',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _approveNews(News news) {
    final titleCtrl = TextEditingController(text: news.titleDraft);
    final contentCtrl = TextEditingController(text: news.contentDraft);
    final commentCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Modifier avant approbation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titre (brouillon)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contenu (brouillon)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Commentaire (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // 1) Mettre à jour les champs finaux sans toucher aux brouillons
                            final newTitle = titleCtrl.text.trim();
                            final newContent = contentCtrl.text.trim();
                            await _newsController.updateNews(
                              news.id,
                              titleFinal: newTitle,
                              contentFinal: newContent,
                            );
                            // 2) Approuver
                            final comment = commentCtrl.text.trim();
                            final ok = await _moderationController.approveNews(
                              news.id,
                              comment: comment.isEmpty ? null : comment,
                            );
                            if (ok) {
                              // recharger en attente
                              await _newsController.fetchPendingNews();
                              if (mounted) setState(() {});
                              Get.back();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approuver'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _rejectNews(News news) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Refuser la news'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez indiquer la raison du refus :'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Raison du refus...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar('Erreur', 'Veuillez indiquer une raison');
                return;
              }
              Get.back();
              final success = await _moderationController.rejectNews(
                news.id,
                reasonController.text.trim(),
              );
              if (success) {
                _newsController.fetchNews();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }
}
