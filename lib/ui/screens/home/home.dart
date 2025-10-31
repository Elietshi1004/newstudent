import 'package:flutter/material.dart';
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
