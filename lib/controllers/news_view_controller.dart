import 'package:get/get.dart';
import '../models/news_view.dart';
import '../models/news.dart';
import '../services/api_service.dart';

class NewsViewController extends GetxController {
  final RxList<NewsView> newsViews = <NewsView>[].obs;
  final RxList<News> unreadNews = <News>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Marquer une news comme vue
  Future<bool> markNewsAsViewed(int newsId) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.postRequest('/api/news/$newsId/view/', {});

    if (result['success'] == true) {
      isLoading.value = false;
      // Recharger les news non lues après avoir marqué une comme vue
      await fetchUnreadNews();
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors du marquage';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  /// Récupérer les news non lues selon les abonnements
  Future<void> fetchUnreadNews() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/news/unread/');

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else {
        data = [];
      }

      unreadNews.value =
          data
              .map((json) => News.fromJson(json as Map<String, dynamic>))
              .toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  /// Vérifier si une news a été vue (basé sur la liste des news non lues)
  bool isNewsViewed(int newsId) {
    return !unreadNews.any((news) => news.id == newsId);
  }
}
