import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../controllers/user_role_controller.dart';
import 'pages/accueil/home_accueil.dart';
import 'pages/profil/profil_user.dart';
import 'pages/moderation/moderation_page.dart';
import 'pages/create_news/create_news_page.dart';
import 'pages/admin/admin_page.dart';
import 'pages/explorer/explorer_page.dart';
import 'widgets/role_based_bottom_bar.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  int _currentIndex = 0;
  final UserRoleController _userRoleCtrl = Setting.userRoleCtrl;

  List<Widget> _buildPages() {
    final isAdmin = _userRoleCtrl.isAdmin();
    final isModerator = _userRoleCtrl.isModerator();
    final isPubliant = _userRoleCtrl.isPubliant();
    final isStudent = _userRoleCtrl.isStudent();
    List<Widget> pages = [const HomeAccueil()];

    // Explorer pour les étudiants seulement
    if (!isModerator && !isPubliant && !isAdmin && isStudent) {
      pages.add(const ExplorerPage());
    }

    // Page Modération pour Modérateurs (pas pour Admin)
    if (isModerator && !isAdmin) {
      pages.add(const ModerationPage());
    }

    // Page Créer pour Publiants (pas pour Admin)
    if (isPubliant && !isAdmin) {
      pages.add(const CreateNewsPage());
    }

    // Page Admin pour Admins seulement
    if (isAdmin) {
      pages.add(const AdminPage());
    }

    // Page Profil pour tous
    pages.add(const ProfilUser());

    return pages;
  }

  @override
  void initState() {
    super.initState();
    Setting.subscriptionCtrl.fetchSubscriptions();
    Setting.authCtrl;
    if (Setting.authCtrl.userData['id'] == null) {
      Setting.authCtrl.refreshUserData();
    }
    if (!kIsWeb) {
      printDebug("initialize one signal ${Setting.authCtrl.userData['email']}");
      OneSignal.initialize(Setting.onesignal_app_id);
      OneSignal.login(Setting.authCtrl.userData['id'].toString());
      printDebug("initialize one signal success");
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}',
        );

        /// Display Notification, preventDefault to not display
        event.preventDefault();

        /// Do async work

        /// notification.display() to display after preventing default
        event.notification.display();

        // this.setState(() {
        //   _debugLabelString =
        //       "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
        // });
      });
      printDebug("getOnesignalId");
      OneSignal.User.getOnesignalId().then((value) async {
        printDebug("getOnesignalId success $value");
        if (value != null) {
          // Enregistrer l'abonnement push OneSignal
          final userId = Setting.authCtrl.userData['id']?.toString() ?? '';
          if (userId.isNotEmpty) {
            await Setting.pushSubscriptionCtrl.registerPushSubscription(
              externalUserId: userId,
              deviceToken: value,
            );
            printDebug("Push subscription registered: $userId");
          }
        }
      });
      printDebug("getOnesignalId success");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final pages = _buildPages();
        if (_currentIndex >= pages.length) {
          return const Center(child: Text('Page introuvable'));
        }
        return pages[_currentIndex];
      }),
      bottomNavigationBar: RoleBasedBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
