import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:newstudent/controllers/roles_controller.dart';
import 'package:newstudent/controllers/users_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/auth_controller.dart';
import '../controllers/news_controller.dart';
import '../controllers/notification_pref_controller.dart';
import '../controllers/program_controller.dart';
import '../controllers/subscription_controller.dart';
import '../controllers/user_role_controller.dart';
import '../controllers/moderation_controller.dart';
import '../controllers/news_view_controller.dart';
import '../controllers/push_subscription_controller.dart';
import '../services/storage_service.dart';

void printDebug(Object? message) {
  if (kDebugMode) {
    print(message);
  }
}

class Setting {
  static const String baseUrl = 'http://127.0.0.1:8000/';
  static const String onesignal_app_id = 'c2db50d7-c369-4be9-81f1-29f4455c26fb';
  static const String onesignal_secret_key =
      'os_v2_app_ylnvbv6dnff6taprfh2ekxbg7ngb3ihhyf7ubv5fly6xkadme4errldtej2kd7otllb4h7qm2essieff5c3fd3xieznxi2eir2adlzy';

  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialiser le stockage
      await StorageService.init();

      await authCtrl.restoreSession();
    } catch (e) {
      printDebug('Error initializing settings: $e');
    }
  }

  static Future<bool> requestPermission(dynamic permission) async {
    // Utiliser soit un objet Permission, soit un nom de permission (String)
    try {
      Permission p;
      if (permission is Permission) {
        p = permission;
      } else if (permission is String) {
        p = _permissionFromString(permission);
      } else {
        throw ArgumentError('Type de permission non supporté');
      }

      final status = await p.request();
      return status.isGranted;
    } catch (e) {
      printDebug('Erreur lors de la demande de permission $permission: $e');
      return false;
    }
  }

  static Permission _permissionFromString(String name) {
    switch (name.toLowerCase()) {
      case 'storage':
      case 'photos':
      case 'media':
        return Permission.storage;
      case 'camera':
        return Permission.camera;
      case 'microphone':
        return Permission.microphone;
      case 'location':
      case 'locationwheninuse':
        return Permission.locationWhenInUse;
      case 'locationalways':
        return Permission.locationAlways;
      case 'notifications':
      case 'notification':
        return Permission.notification;
      case 'contacts':
        return Permission.contacts;
      case 'calendar':
        return Permission.calendar;
      default:
        return Permission.storage; // valeur par défaut raisonnable
    }
  }

  static AuthController get authCtrl {
    try {
      return Get.find<AuthController>();
    } catch (e) {
      return Get.put(AuthController());
    }
  }

  static SubscriptionController get subscriptionCtrl {
    try {
      return Get.find<SubscriptionController>();
    } catch (e) {
      return Get.put(SubscriptionController());
    }
  }

  static ProgramController get programCtrl {
    try {
      return Get.find<ProgramController>();
    } catch (e) {
      return Get.put(ProgramController());
    }
  }

  static NewsController get newsCtrl {
    try {
      return Get.find<NewsController>();
    } catch (e) {
      return Get.put(NewsController());
    }
  }

  static NotificationPrefController get notificationPrefCtrl {
    try {
      return Get.find<NotificationPrefController>();
    } catch (e) {
      return Get.put(NotificationPrefController());
    }
  }

  static UserRoleController get userRoleCtrl {
    try {
      return Get.find<UserRoleController>();
    } catch (e) {
      return Get.put(UserRoleController());
    }
  }

  static ModerationController get moderationCtrl {
    try {
      return Get.find<ModerationController>();
    } catch (e) {
      return Get.put(ModerationController());
    }
  }

  static UsersController get usersCtrl {
    try {
      return Get.find<UsersController>();
    } catch (e) {
      return Get.put(UsersController());
    }
  }

  static RolesController get rolesCtrl {
    try {
      return Get.find<RolesController>();
    } catch (e) {
      return Get.put(RolesController());
    }
  }

  static NewsViewController get newsViewCtrl {
    try {
      return Get.find<NewsViewController>();
    } catch (e) {
      return Get.put(NewsViewController());
    }
  }

  static PushSubscriptionController get pushSubscriptionCtrl {
    try {
      return Get.find<PushSubscriptionController>();
    } catch (e) {
      return Get.put(PushSubscriptionController());
    }
  }
}
