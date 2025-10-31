import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../controllers/program_controller.dart';
import '../../../../../controllers/users_controller.dart';
import '../../../../../controllers/roles_controller.dart';
import '../../../../../controllers/user_role_controller.dart';
import '../../../../../models/user.dart';
import '../../../../../models/user_role.dart';
import '../../../../../models/program.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ProgramController _programController = Setting.programCtrl;
  final UsersController _usersController = Setting.usersCtrl;
  final RolesController _rolesController = Setting.rolesCtrl;
  final UserRoleController _userRoleController = Setting.userRoleCtrl;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _programController.fetchPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Administration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab(0, 'Programmes'),
                  const SizedBox(width: 8),
                  _buildTab(1, 'Utilisateurs'),
                  const SizedBox(width: 8),
                  _buildTab(2, 'Rôles'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenu selon l'onglet
            Expanded(
              child:
                  _selectedTab == 0
                      ? _buildProgramsTab()
                      : _selectedTab == 1
                      ? _buildUsersTab()
                      : _buildRolesTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.categoryUnselected,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProgramsTab() {
    return Obx(() {
      if (_programController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final programs = _programController.programs;

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: programs.length + 1, // +1 pour le bouton d'ajout
        itemBuilder: (context, index) {
          if (index == programs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showAddProgramDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un programme'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            );
          }

          final program = programs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(program.name),
              subtitle: Text('Code: ${program.code}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () => _showEditProgramDialog(program),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _showDeleteProgramDialog(program),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildUsersTab() {
    return Obx(() {
      if (_usersController.isLoading.value ||
          _rolesController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Barre de recherche
      final searchBar = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          onChanged: (v) => _usersController.setSearchQuery(v),
          decoration: InputDecoration(
            hintText: 'Rechercher un utilisateur (nom ou email)...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      );

      final users = _usersController.pagedUsers;
      return RefreshIndicator(
        onRefresh: () async {
          await _usersController.fetchUsers();
          await _userRoleController.fetchAllUserRoles();
        },
        child: Column(
          children: [
            searchBar,
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final rolesForUser = _userRoleController.getRolesForUser(
                    user.id,
                  );
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(user.username),
                      subtitle: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            rolesForUser
                                .map(
                                  (r) => Chip(
                                    label: Text(r.name),
                                    backgroundColor:
                                        AppColors.categoryUnselected,
                                  ),
                                )
                                .toList(),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _showAssignRolesSheet(user),
                        child: const Text('Gérer les rôles'),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pagination controls
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${_usersController.currentPage.value} / ${_usersController.totalPages}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed:
                            _usersController.currentPage.value > 1
                                ? () => _usersController.prevPage()
                                : null,
                        child: const Text('Précédent'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed:
                            _usersController.currentPage.value <
                                    _usersController.totalPages
                                ? () => _usersController.nextPage()
                                : null,
                        child: const Text('Suivant'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRolesTab() {
    return Obx(() {
      if (_rolesController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final roles = _rolesController.roles;
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          return Card(
            child: ListTile(
              title: Text(role.name),
              subtitle:
                  role.description != null && role.description!.isNotEmpty
                      ? Text(role.description!)
                      : null,
            ),
          );
        },
      );
    });
  }

  void _showAssignRolesSheet(UserModel user) async {
    await _userRoleController.fetchAllUserRoles();
    await _rolesController.fetchRoles();

    final currentRoles = _userRoleController.getRolesForUser(user.id);
    final roles = _rolesController.roles;
    final selected = currentRoles.map((r) => r.id).toSet();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
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
                      'Attribuer des rôles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        final isSelected = selected.contains(role.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) async {
                            if (value == true) {
                              selected.add(role.id);
                            } else {
                              selected.remove(role.id);
                            }
                            setModalState(() {});
                          },
                          title: Text(role.name),
                          subtitle:
                              role.description != null &&
                                      role.description!.isNotEmpty
                                  ? Text(role.description!)
                                  : null,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final original = currentRoles.map((r) => r.id).toSet();
                        final toAdd = selected.difference(original);
                        final toRemove = original.difference(selected);

                        for (final roleId in toAdd) {
                          await _userRoleController.assignRoleToUser(
                            userId: user.id,
                            roleId: roleId,
                          );
                        }

                        for (final roleId in toRemove) {
                          final link = _userRoleController.allUserRoles
                              .firstWhere(
                                (ur) => ur.user == user.id && ur.role == roleId,
                                orElse:
                                    () => UserRole(id: -1, user: -1, role: -1),
                              );
                          if (link.id != -1) {
                            await _userRoleController.removeRoleFromUser(
                              link.id,
                            );
                          }
                        }

                        await _userRoleController.fetchAllUserRoles();
                        setState(() {});
                        Get.back();
                        Get.snackbar('Succès', 'Rôles mis à jour');
                      },
                      child: const Text('Confirmer les changements'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddProgramDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter un programme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  codeController.text.trim().isEmpty) {
                Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
                return;
              }

              final success = await _programController.createProgram(
                name: nameController.text.trim(),
                code: codeController.text.trim(),
              );

              if (success) {
                Get.back();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditProgramDialog(Program program) {
    final nameController = TextEditingController(text: program.name);
    final codeController = TextEditingController(text: program.code);

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier le programme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  codeController.text.trim().isEmpty) {
                Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
                return;
              }

              final success = await _programController.updateProgram(
                program.id,
                name: nameController.text.trim(),
                code: codeController.text.trim(),
              );

              if (success) {
                Get.back();
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProgramDialog(Program program) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer le programme'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${program.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final success = await _programController.deleteProgram(
                program.id,
              );
              if (success) {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
