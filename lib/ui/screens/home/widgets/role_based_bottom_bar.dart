import 'package:flutter/material.dart';
import '../../../../utils/const/colors/colors.dart';
import '../../../../controllers/user_role_controller.dart';
import 'package:get/get.dart';

class RoleBasedBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RoleBasedBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userRoleCtrl = Get.find<UserRoleController>();

    return Obx(() {
      final isAdmin = userRoleCtrl.isAdmin();
      final isModerator = userRoleCtrl.isModerator();
      final isPubliant = userRoleCtrl.isPubliant();
      final isStudent = userRoleCtrl.isStudent();
      List<BottomNavigationBarItem> items = [];

      // Toujours afficher Accueil
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
      );

      // Explorer pour les étudiants (ou tous si pas modérateur/publiant)
      if (!isModerator && !isPubliant && !isAdmin && isStudent) {
        items.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorer',
          ),
        );
      }

      // Si Modérateur : page de Modération (pas pour Admin)
      if (isModerator && !isAdmin) {
        items.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Modération',
          ),
        );
      }

      // Si Publiant : page pour créer des news (pas pour Admin)
      if (isPubliant && !isAdmin) {
        items.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Créer',
          ),
        );
      }

      // Si Admin : page Administration
      if (isAdmin) {
        items.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        );
      }

      // Toujours afficher Profil à la fin
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      );

      return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: items,
      );
    });
  }
}
