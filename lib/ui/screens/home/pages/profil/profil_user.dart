import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../controllers/auth_controller.dart';
import '../../../../../controllers/notification_pref_controller.dart';
// controllers accessibles via Setting
import '../../../../../models/notification_pref.dart';

class ProfilUser extends StatelessWidget {
  const ProfilUser({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Setting.authCtrl;
    final notificationPrefCtrl = Setting.notificationPrefCtrl;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // En-tête avec avatar
                Obx(() {
                  final userData = authController.userData;
                  final username = userData['username'] ?? 'Utilisateur';
                  final email = userData['email'] ?? '';

                  return Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // Section Programmes (Étudiant uniquement)
                Obx(() {
                  final userRoleCtrl = Setting.userRoleCtrl;
                  if (!userRoleCtrl.isStudent() && !userRoleCtrl.isPubliant()) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Mes Programmes'),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/programs');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Voir mes programmes',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Gérer vos abonnements',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // Section Mes Publications (si Publiant)
                Obx(() {
                  final userRoleCtrl = Setting.userRoleCtrl;
                  if (userRoleCtrl.isPubliant()) {
                    return Column(
                      children: [
                        // _buildSectionTitle('Mes Publications'),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed('/my-publications');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.article_outlined,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Voir mes publications',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Consulter toutes vos actualités',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Section Rôles
                _buildSectionTitle('Mes Rôles'),
                Obx(() {
                  final userRoleCtrl = Setting.userRoleCtrl;
                  final rolesCtrl = Setting.rolesCtrl;

                  if (userRoleCtrl.userRoles.isEmpty ||
                      rolesCtrl.roles.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Aucun rôle attribué',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  // Résoudre les noms des rôles à partir des IDs
                  final roleIds =
                      userRoleCtrl.userRoles.map((ur) => ur.role).toSet();
                  final resolvedRoles =
                      rolesCtrl.roles
                          .where((r) => roleIds.contains(r.id))
                          .toList();

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        resolvedRoles.map((role) {
                          return Chip(
                            label: Text(role.name),
                            backgroundColor: _getRoleColor(role.name),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                  );
                }),

                const SizedBox(height: 32),

                // Section Préférences de notification (Étudiant uniquement)
                Obx(() {
                  final userRoleCtrl = Setting.userRoleCtrl;
                  if (!userRoleCtrl.isStudent()) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Préférences de notification'),
                      Obx(() {
                        final pref =
                            notificationPrefCtrl.notificationPref.value;
                        if (pref == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildNotificationSetting(
                                  'Fréquence',
                                  _getFrequencyLabel(pref.frequency),
                                  () => _showFrequencyDialog(
                                    notificationPrefCtrl,
                                  ),
                                ),
                                const Divider(),
                                _buildNotificationSetting(
                                  'Notifications Push',
                                  pref.pushEnabled ? 'Activées' : 'Désactivées',
                                  () => notificationPrefCtrl
                                      .updateNotificationPrefs(
                                        pushEnabled: !pref.pushEnabled,
                                      ),
                                  isSwitch: true,
                                  switchValue: pref.pushEnabled,
                                  onSwitchChanged: (value) {
                                    notificationPrefCtrl
                                        .updateNotificationPrefs(
                                          pushEnabled: value,
                                        );
                                  },
                                ),
                                const Divider(),
                                _buildNotificationSetting(
                                  'Notifications Email',
                                  pref.emailEnabled
                                      ? 'Activées'
                                      : 'Désactivées',
                                  () => notificationPrefCtrl
                                      .updateNotificationPrefs(
                                        emailEnabled: !pref.emailEnabled,
                                      ),
                                  isSwitch: true,
                                  switchValue: pref.emailEnabled,
                                  onSwitchChanged: (value) {
                                    notificationPrefCtrl
                                        .updateNotificationPrefs(
                                          emailEnabled: value,
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // Section Paramètres
                _buildSectionTitle('Paramètres'),
                _buildSettingCard(),

                const SizedBox(height: 32),

                // Bouton Déconnexion
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        authController.isLoading.value
                            ? null
                            : () => _showLogoutDialog(context, authController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        authController.isLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Déconnexion',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildNotificationSetting(
    String label,
    String value,
    VoidCallback onTap, {
    bool isSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
  }) {
    return InkWell(
      onTap: isSwitch ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isSwitch && switchValue != null && onSwitchChanged != null)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: AppColors.primary,
              )
            else if (!isSwitch)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'À propos',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Aide et support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
              : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'modérateur':
      case 'moderateur':
        return AppColors.warning;
      case 'publiant':
        return AppColors.info;
      case 'étudiant':
      case 'etudiant':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _getFrequencyLabel(Frequency frequency) {
    switch (frequency) {
      case Frequency.immediate:
        return 'Immédiate';
      case Frequency.daily:
        return 'Quotidienne';
      case Frequency.weekly:
        return 'Hebdomadaire';
    }
  }

  void _showFrequencyDialog(NotificationPrefController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Fréquence des notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flash_on, color: AppColors.primary),
              title: const Text('Immédiate'),
              onTap: () {
                controller.updateNotificationPrefs(
                  frequency: Frequency.immediate,
                );
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.today, color: AppColors.primary),
              title: const Text('Quotidienne'),
              onTap: () {
                controller.updateNotificationPrefs(frequency: Frequency.daily);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              title: const Text('Hebdomadaire'),
              onTap: () {
                controller.updateNotificationPrefs(frequency: Frequency.weekly);
                Get.back();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
