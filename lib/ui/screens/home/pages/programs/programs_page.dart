import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final programCtrl = Setting.programCtrl;
    final subCtrl = Setting.subscriptionCtrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.background,
        child: Obx(() {
          if (programCtrl.programs.isEmpty && !programCtrl.isLoading.value) {
            programCtrl.fetchPrograms();
          }

          if (programCtrl.isLoading.value || subCtrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final programs = programCtrl.programs;
          if (programs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun programme disponible',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              final isSubscribed = subCtrl.isSubscribedToProgram(program.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 28,
                    ),
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
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  trailing: SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed:
                          subCtrl.isLoading.value
                              ? null
                              : () async {
                                if (isSubscribed) {
                                  final subscription = subCtrl
                                      .getSubscriptionByProgramId(program.id);
                                  if (subscription != null) {
                                    await subCtrl.unsubscribeFromProgram(
                                      subscription.id,
                                    );
                                  }
                                } else {
                                  await subCtrl.subscribeToProgram(program.id);
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSubscribed ? AppColors.error : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          subCtrl.isLoading.value
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                isSubscribed ? 'Se désabonner' : 'S\'abonner',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
