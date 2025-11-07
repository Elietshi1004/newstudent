import 'package:get/get.dart';
import '../models/moderation.dart';
import '../services/api_service.dart';
import 'package:newstudent/utils/Setting.dart';

class ModerationController extends GetxController {
  final RxList<Moderation> moderations = <Moderation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchModerations();
  }

  Future<void> fetchModerations() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/moderations/');

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
      moderations.value =
          data.map((json) => Moderation.fromJson(json)).toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<bool> approveNews(int newsId, {String? comment}) async {
    isLoading.value = true;
    error.value = '';

    final moderatorId = Setting.authCtrl.userData['id'];
    final Map<String, dynamic> body = {
      'news': newsId,
      'approved': true,
      'moderator': moderatorId,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };

    final result = await ApiService.postRequest('/api/moderations/', body);

    if (result['success'] == true) {
      // Récupérer la news pour copier les brouillons vers les champs finaux
      // String? titleDraft;
      // String? contentDraft;
      // final getNews = await ApiService.getRequest('/api/news/$newsId/');
      // if (getNews['success'] == true &&
      //     getNews['data'] is Map<String, dynamic>) {
      //   final data = getNews['data'] as Map<String, dynamic>;
      //   titleDraft = data['title_draft'] as String?;
      //   contentDraft = data['content_draft'] as String?;
      // }

      // Mettre à jour l'objet News pour refléter l'approbation et fixer les champs finaux
      final updateNews = await ApiService.putRequest(
        '/api/news/$newsId/update/',
        {
          'moderator_approved': true,
          'moderator': moderatorId,
          'moderated_at': DateTime.now().toIso8601String(),
          'invalidated': false,
          'invalidation_reason': null,
          // if (titleDraft != null) 'title_final': titleDraft,
          // if (contentDraft != null) 'content_final': contentDraft,
        },
      );
      if (updateNews['success'] != true) {
        // On continue mais on informe de l'erreur d'update News
        Get.snackbar(
          'Avertissement',
          updateNews['error'] ?? 'News approuvée, mais la mise à jour a échoué',
        );
      }

      await fetchModerations(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de l\'approbation';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Future<bool> rejectNews(int newsId, String comment) async {
    isLoading.value = true;
    error.value = '';

    final moderatorId = Setting.authCtrl.userData['id'];
    final result = await ApiService.postRequest('/api/moderations/', {
      'news': newsId,
      'approved': false,
      'moderator': moderatorId,
      'comment': comment,
    });

    if (result['success'] == true) {
      // Mettre à jour l'objet News pour refléter le refus
      final updateNews = await ApiService.putRequest('/api/news/$newsId/', {
        'moderator_approved': false,
        'moderator': moderatorId,
        'moderated_at': DateTime.now().toIso8601String(),
        'invalidated': true,
        'invalidation_reason': comment,
      });
      if (updateNews['success'] != true) {
        Get.snackbar(
          'Avertissement',
          updateNews['error'] ?? 'News refusée, mais la mise à jour a échoué',
        );
      }

      await fetchModerations(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors du refus';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }
}
