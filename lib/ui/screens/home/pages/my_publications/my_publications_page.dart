import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../controllers/news_controller.dart';
import '../../widgets/news_card.dart';

class MyPublicationsPage extends StatefulWidget {
  const MyPublicationsPage({super.key});

  @override
  State<MyPublicationsPage> createState() => _MyPublicationsPageState();
}

class _MyPublicationsPageState extends State<MyPublicationsPage> {
  final NewsController _newsController = Setting.newsCtrl;
  final _authController = Setting.authCtrl;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    final userId = _authController.userData['id'] as int?;
    if (userId != null) {
      _newsController.fetchNewsByAuthor(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authController.userData['id'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Publications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.background,
        child: Obx(() {
          if (_newsController.isLoading.value &&
              _newsController.newsList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final news = _newsController.newsList;
          if (news.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune publication',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas encore publié d\'actualité',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollUpdateNotification) {
                final maxScroll = scrollInfo.metrics.maxScrollExtent;
                final currentScroll = scrollInfo.metrics.pixels;
                final threshold = maxScroll * 0.8;

                if (currentScroll >= threshold &&
                    currentScroll < maxScroll &&
                    !_isLoadingMore &&
                    userId != null) {
                  if (_newsController.hasMore.value &&
                      !_newsController.isLoadingMore.value &&
                      !_newsController.isLoading.value) {
                    setState(() {
                      _isLoadingMore = true;
                    });
                    _newsController.loadMoreNewsByAuthor(userId).then((_) {
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
              padding: const EdgeInsets.all(16),
              itemCount: news.length + (_newsController.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == news.length) {
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
    );
  }
}
