import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';

class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final programController = Setting.programCtrl;
    final subscriptionController = Setting.subscriptionCtrl;

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
                    'Explorer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // IconButton(
                  //   icon: const Icon(Icons.search),
                  //   onPressed: () {
                  //     // TODO: Implémenter la recherche
                  //   },
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Abonnez-vous aux programmes pour recevoir leurs actualités',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 16),

            // Liste des programmes
            Expanded(
              child: Obx(() {
                if (programController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                }

                final programs = programController.programs;
                if (programs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun programme disponible',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.school, color: AppColors.primary),
                        ),
                        title: Text(
                          program.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Code: ${program.code}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        trailing: Obx(() {
                          final currentSubscription = subscriptionController
                              .getSubscriptionByProgramId(program.id);
                          final subscribed = subscriptionController
                              .isSubscribedToProgram(program.id);

                          if (subscriptionController.isLoading.value) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          return subscribed
                              ? ElevatedButton(
                                onPressed: () async {
                                  if (currentSubscription != null) {
                                    await subscriptionController
                                        .unsubscribeFromProgram(
                                          currentSubscription.id,
                                        );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Se désabonner'),
                              )
                              : ElevatedButton(
                                onPressed: () async {
                                  await subscriptionController
                                      .subscribeToProgram(program.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('S\'abonner'),
                              );
                        }),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
