import 'package:get/get.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../utils/Setting.dart';

class NewsController extends GetxController {
  final RxList<News> newsList = <News>[].obs;
  final RxList<News> newsListModerator = <News>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;
  final Rx<News?> selectedNews = Rx<News?>(null);
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int pageSize = 10;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchPendingNews() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/news/pending/');

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = [responseData];
      } else {
        data = [];
      }

      final items = data.map((json) => News.fromJson(json)).toList();
      // trier du plus récent au plus ancien par writtenAt
      items.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
      newsListModerator.value = items;
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<void> fetchApprovedNews() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/news/approved/');

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;
      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = [responseData];
      } else {
        data = [];
      }
      final items = data.map((json) => News.fromJson(json)).toList();
      items.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
      newsListModerator.value = items;
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<void> fetchRejectedNews() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/news/rejected/');

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;
      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = [responseData];
      } else {
        data = [];
      }
      final items = data.map((json) => News.fromJson(json)).toList();
      items.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
      newsListModerator.value = items;
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<void> fetchNews({bool loadMore = false}) async {
    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
      newsList.clear();
    } else {
      isLoadingMore.value = true;
      currentPage.value++;
    }
    error.value = '';

    final page = currentPage.value;
    final result = await ApiService.getRequest(
      '/api/news/?page=$page&page_size=$pageSize',
    );

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      // Gérer différents formats de réponse API (avec ou sans pagination)
      if (responseData is Map && responseData.containsKey('results')) {
        // Format avec pagination Django REST Framework
        data = responseData['results'] as List;
        hasMore.value = responseData['next'] != null;
      } else if (responseData is List) {
        // Format simple liste
        data = responseData;
        hasMore.value = data.length >= pageSize;
      } else {
        data = [];
        hasMore.value = false;
      }

      final newNews = data.map((json) => News.fromJson(json)).toList();
      if (loadMore) {
        newsList.addAll(newNews);
      } else {
        newsList.value = newNews;
      }
      _sortByWrittenAtDesc();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      if (!loadMore) {
        Get.snackbar('Erreur', error.value);
      }
      if (loadMore) {
        currentPage.value--;
      }
    }

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<void> fetchNewsByProgram(int programId) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest(
      '/api/news/?program_id=$programId',
    );

    if (result['success'] == true) {
      final data = result['data'] as List;
      newsList.value = data.map((json) => News.fromJson(json)).toList();
      _sortByWrittenAtDesc();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<void> fetchNewsByAuthor(int authorId, {bool loadMore = false}) async {
    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
      newsList.clear();
    } else {
      isLoadingMore.value = true;
      currentPage.value++;
    }
    error.value = '';

    final page = currentPage.value;
    final result = await ApiService.getRequest(
      '/api/news/?author_id=$authorId&page=$page&page_size=$pageSize',
    );

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
        hasMore.value = responseData['next'] != null;
      } else if (responseData is List) {
        data = responseData;
        hasMore.value = data.length >= pageSize;
      } else {
        data = [];
        hasMore.value = false;
      }

      final newNews = data.map((json) => News.fromJson(json)).toList();
      if (loadMore) {
        final existingIds = newsList.map((n) => n.id).toSet();
        final uniqueNews =
            newNews.where((n) => !existingIds.contains(n.id)).toList();
        newsList.addAll(uniqueNews);
      } else {
        newsList.value = newNews;
      }
      _sortByWrittenAtDesc();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      if (!loadMore) {
        Get.snackbar('Erreur', error.value);
      }
      if (loadMore) {
        currentPage.value--;
      }
    }

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<void> loadMoreNewsByAuthor(int authorId) async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }
    await fetchNewsByAuthor(authorId, loadMore: true);
  }

  Future<void> fetchNewsForProgramIds(
    List<int> programIds, {
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
      newsList.clear();
    } else {
      isLoadingMore.value = true;
      currentPage.value++;
    }
    error.value = '';

    final page = currentPage.value;
    final List<News> collected = [];
    bool hasMoreInAny = false;

    for (final id in programIds.toSet()) {
      final res = await ApiService.getRequest(
        '/api/news/?program_id=$id&page=$page&page_size=$pageSize',
      );
      if (res['success'] == true) {
        final responseData = res['data'];
        List<dynamic> data;

        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'] as List;
          if (responseData['next'] != null) {
            hasMoreInAny = true;
          }
        } else if (responseData is List) {
          data = responseData;
          if (data.length >= pageSize) {
            hasMoreInAny = true;
          }
        } else {
          data = [];
        }

        collected.addAll(data.map((j) => News.fromJson(j)));
      }
    }

    if (collected.isEmpty && !loadMore) {
      // fallback non filtré
      await fetchNews();
      return;
    }

    if (loadMore) {
      // Éviter les doublons
      final existingIds = newsList.map((n) => n.id).toSet();
      final uniqueNews =
          collected.where((n) => !existingIds.contains(n.id)).toList();
      newsList.addAll(uniqueNews);
    } else {
      newsList.value = collected;
    }

    collected.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
    _sortByWrittenAtDesc();

    hasMore.value = hasMoreInAny;
    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<void> fetchNewsForMySubscriptions({bool loadMore = false}) async {
    if (!loadMore) {
      currentPage.value = 1;
      hasMore.value = true;
      newsList.clear();
    }

    // Si recherche active, utiliser searchNews au lieu de fetchNewsForProgramIds
    if (searchQuery.value.isNotEmpty) {
      await searchNews(query: searchQuery.value, loadMore: loadMore);
      return;
    }

    final subCtrl = Setting.subscriptionCtrl;
    if (subCtrl.subscriptions.isEmpty) {
      await subCtrl.fetchSubscriptions();
    }

    final ids =
        subCtrl.subscriptions
            .map((s) => s.program?.id ?? s.programId)
            .whereType<int>()
            .toSet()
            .toList();

    if (ids.isEmpty) {
      await fetchNews(loadMore: loadMore);
      return;
    }

    await fetchNewsForProgramIds(ids, loadMore: loadMore);
  }

  Future<void> loadMoreNews() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }

    await fetchNewsForMySubscriptions(loadMore: true);
  }

  Future<void> searchNews({
    required String query,
    bool loadMore = false,
  }) async {
    if (query.trim().isEmpty) {
      // Si la recherche est vide, revenir aux abonnements normaux
      searchQuery.value = '';
      await fetchNewsForMySubscriptions();
      return;
    }

    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
      newsList.clear();
      searchQuery.value = query.trim();
    } else {
      isLoadingMore.value = true;
      currentPage.value++;
    }
    error.value = '';

    final page = currentPage.value;
    final encodedQuery = Uri.encodeComponent(query.trim());
    final url =
        '/api/news/?search=$encodedQuery&page=$page&page_size=$pageSize';

    final result = await ApiService.getRequest(url);

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
        hasMore.value = responseData['next'] != null;
      } else if (responseData is List) {
        data = responseData;
        hasMore.value = data.length >= pageSize;
      } else {
        data = [];
        hasMore.value = false;
      }

      final newNews = data.map((json) => News.fromJson(json)).toList();
      if (loadMore) {
        // Éviter les doublons
        final existingIds = newsList.map((n) => n.id).toSet();
        final uniqueNews =
            newNews.where((n) => !existingIds.contains(n.id)).toList();
        newsList.addAll(uniqueNews);
      } else {
        newsList.value = newNews;
      }
      _sortByWrittenAtDesc();
    } else {
      error.value = result['error'] ?? 'Erreur lors de la recherche';
      if (!loadMore) {
        Get.snackbar('Erreur', error.value);
      }
      if (loadMore) {
        currentPage.value--;
      }
    }

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<void> clearSearch() async {
    searchQuery.value = '';
    await fetchNewsForMySubscriptions();
  }

  void _sortByWrittenAtDesc() {
    newsListModerator.value = newsList.toList();
    newsListModerator.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
    newsList.value =
        newsList.where((news) => news.moderatorApproved == true).toList();
    newsList.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
  }

  Future<int?> createNewsGetId({
    required int programId,
    required String titleDraft,
    required String contentDraft,
    Importance importance = Importance.moyenne,
  }) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.postRequest('/api/news/', {
      'program': programId,
      'title_draft': titleDraft,
      'content_draft': contentDraft,
      'importance': importance.name,
      'author': Setting.authCtrl.userData['id'],
    });

    if (result['success'] == true) {
      await fetchNewsForMySubscriptions();
      isLoading.value = false;
      final data = result['data'];
      if (data is Map<String, dynamic>) {
        try {
          return data['id'] as int?;
        } catch (_) {}
      }
      // fallback: essayer de retrouver par titre/contenu
      try {
        final created = newsList.firstWhere(
          (n) => n.titleDraft == titleDraft && n.contentDraft == contentDraft,
        );
        return created.id;
      } catch (_) {
        return null;
      }
    } else {
      error.value = result['error'] ?? 'Erreur lors de la création';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return null;
    }
  }

  Future<bool> updateNews(
    int id, {
    String? titleDraft,
    String? contentDraft,
    String? titleFinal,
    String? contentFinal,
    Importance? importance,
  }) async {
    isLoading.value = true;
    error.value = '';
    printDebug("titleFinal: $titleFinal");
    printDebug("contentFinal: $contentFinal");

    final Map<String, dynamic> body = {};
    if (titleDraft != null) body['title_draft'] = titleDraft;
    if (contentDraft != null) body['content_draft'] = contentDraft;
    if (titleFinal != null) body['title_final'] = titleFinal;
    if (contentFinal != null) body['content_final'] = contentFinal;
    if (importance != null) body['importance'] = importance.name;

    final result = await ApiService.putRequest('/api/news/$id/', body);

    if (result['success'] == true) {
      await fetchNewsForMySubscriptions(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de la mise à jour';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Future<bool> deleteNews(int id) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.deleteRequest('/api/news/$id/');

    if (result['success'] == true) {
      await fetchNewsForMySubscriptions(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de la suppression';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  List<News> getNewsByProgram(int programId) {
    return newsList.where((news) => news.program?.id == programId).toList();
  }

  List<News> getNewsByImportance(Importance importance) {
    return newsList.where((news) => news.importance == importance).toList();
  }

  void selectNews(News? news) {
    selectedNews.value = news;
  }

  News? getNewsById(int id) {
    try {
      return newsList.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }
}
