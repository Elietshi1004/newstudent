import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/models/program.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../controllers/news_controller.dart';
import '../../../../../controllers/subscription_controller.dart';
import '../../../../../models/news.dart';
import '../../widgets/news_card.dart';
import '../../widgets/category_chip.dart';

class HomeAccueil extends StatefulWidget {
  const HomeAccueil({super.key});

  @override
  State<HomeAccueil> createState() => _HomeAccueilState();
}

class _HomeAccueilState extends State<HomeAccueil> {
  final NewsController _newsController = Setting.newsCtrl;
  final SubscriptionController _subscriptionController =
      Setting.subscriptionCtrl;

  String _selectedCategory = 'Tout';
  bool _isLoadingMore = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _newsController.fetchNewsForMySubscriptions();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      _newsController.searchNews(query: query);
    });
  }

  List<News> get _filteredNews {
    final news = List<News>.from(_newsController.newsList);

    // Appliquer le filtre de catégorie seulement si pas en mode recherche
    List<News> filtered;
    if (_selectedCategory != 'Tout' &&
        _newsController.searchQuery.value.isEmpty) {
      filtered =
          news
              .where((news) => news.program?.name == _selectedCategory)
              .toList();
    } else {
      filtered = news;
    }

    // Trier par importance (urgente > importante > moyenne > faible), puis par date
    filtered.sort((a, b) {
      final importanceOrder = {
        Importance.urgente: 0,
        Importance.importante: 1,
        Importance.moyenne: 2,
        Importance.faible: 3,
      };
      final importanceDiff = importanceOrder[a.importance]!.compareTo(
        importanceOrder[b.importance]!,
      );
      if (importanceDiff != 0) return importanceDiff;
      // Si même importance, trier par date décroissante
      return b.writtenAt.compareTo(a.writtenAt);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = _formatDate(now);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(formattedDate),

            // Search Bar
            _buildSearchBar(),

            // Trends Section
            _buildTrendsSection(),
            const SizedBox(height: 16),

            // News List
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

                final news = _filteredNews;
                if (news.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune actualité',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollUpdateNotification) {
                      final maxScroll = scrollInfo.metrics.maxScrollExtent;
                      final currentScroll = scrollInfo.metrics.pixels;
                      final threshold =
                          maxScroll * 0.8; // Déclenche à 80% du scroll

                      if (currentScroll >= threshold &&
                          currentScroll < maxScroll &&
                          !_isLoadingMore) {
                        // Déclenche le chargement de plus de news
                        if (_newsController.hasMore.value &&
                            !_newsController.isLoadingMore.value &&
                            !_newsController.isLoading.value) {
                          setState(() {
                            _isLoadingMore = true;
                          });
                          _newsController.loadMoreNews().then((_) {
                            if (mounted) {
                              setState(() {
                                _isLoadingMore = false;
                              });
                            }
                          });
                        }
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        news.length + (_newsController.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == news.length) {
                        // Afficher un indicateur de chargement en bas
                        return Obx(() {
                          if (_newsController.isLoadingMore.value) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        });
                      }

                      final newsItem = news[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NewsCard(news: newsItem),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String date) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EduNews',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Stack(
          //   children: [
          //     IconButton(
          //       icon: const Icon(Icons.notifications_outlined),
          //       onPressed: () {},
          //     ),
          //     Positioned(
          //       right: 8,
          //       top: 8,
          //       child: Container(
          //         width: 8,
          //         height: 8,
          //         decoration: const BoxDecoration(
          //           color: AppColors.notificationBadge,
          //           shape: BoxShape.circle,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher une actualité...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: Obx(() {
              if (_newsController.searchQuery.value.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _newsController.clearSearch();
                  },
                );
              }
              return const SizedBox.shrink();
            }),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppColors.notificationBadge,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tendances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final subscribedPrograms =
              _subscriptionController.getSubscribedPrograms();
          var listremovedub = [...subscribedPrograms];
          var map = <String, Program>{};
          for (var p in listremovedub) {
            map[p.name] = p;
          }
          final categ = map.values.toList();

          final categories = ['Tout', ...categ.map((p) => p.name)];

          return SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
