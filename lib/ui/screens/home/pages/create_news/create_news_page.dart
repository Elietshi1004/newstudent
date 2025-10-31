import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../../../../../utils/const/colors/colors.dart';
import '../../../../../controllers/news_controller.dart';
import '../../../../../controllers/program_controller.dart';
import '../../../../../models/news.dart';
import '../../../../../models/program.dart';
import '../../../../components/custom_textfield.dart';
import '../../../../components/custom_button.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../../services/attachment_service.dart';

class CreateNewsPage extends StatefulWidget {
  const CreateNewsPage({super.key});

  @override
  State<CreateNewsPage> createState() => _CreateNewsPageState();
}

class _CreateNewsPageState extends State<CreateNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final NewsController _newsController = Setting.newsCtrl;
  final ProgramController _programController = Setting.programCtrl;

  Program? _selectedProgram;
  Importance _selectedImportance = Importance.moyenne;
  String? _pickedFilePath;

  @override
  void initState() {
    super.initState();
    _programController.fetchPrograms();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitNews() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProgram == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner un programme');
      return;
    }

    final newId = await _newsController.createNewsGetId(
      programId: _selectedProgram!.id,
      titleDraft: _titleController.text.trim(),
      contentDraft: _contentController.text.trim(),
      importance: _selectedImportance,
    );

    if (newId != null) {
      // Upload attachement si présent
      if (_pickedFilePath != null) {
        try {
          final file = File(_pickedFilePath!);
          final res = await AttachmentService.uploadAttachment(
            newsId: newId,
            file: file,
          );
          if (res['success'] != true) {
            Get.snackbar('Info', 'News créée, mais upload image échoué');
          }
        } catch (e) {
          Get.snackbar('Info', 'News créée, mais image invalide');
        }
      }
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedProgram = null;
        _selectedImportance = Importance.moyenne;
        _pickedFilePath = null;
      });
      Get.snackbar('Succès', 'Actualité créée et soumise pour modération');
    }
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
                    'Créer une actualité',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sélection du programme
                      const Text(
                        'Programme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (_programController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return DropdownButtonFormField<Program>(
                          value: _selectedProgram,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          hint: const Text('Sélectionner un programme'),
                          items:
                              _programController.programs.map((program) {
                                return DropdownMenuItem<Program>(
                                  value: program,
                                  child: Text(program.name),
                                );
                              }).toList(),
                          onChanged: (program) {
                            setState(() {
                              _selectedProgram = program;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un programme';
                            }
                            return null;
                          },
                        );
                      }),

                      const SizedBox(height: 24),

                      // Titre
                      CustomTextField(
                        controller: _titleController,
                        hintText: 'Titre de l\'actualité',
                        prefixIcon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un titre';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Contenu
                      CustomTextField(
                        controller: _contentController,
                        hintText: 'Contenu de l\'actualité',
                        prefixIcon: Icons.article,
                        maxLines: 8,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le contenu';
                          }
                          if (value.length < 20) {
                            return 'Le contenu doit contenir au moins 20 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Importance
                      const Text(
                        'Importance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            Importance.values.map((importance) {
                              final isSelected =
                                  _selectedImportance == importance;
                              return ChoiceChip(
                                label: Text(_getImportanceLabel(importance)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedImportance = importance;
                                  });
                                },
                                selectedColor: _getImportanceColor(importance),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Pièce jointe (optionnelle)
                      const Text(
                        'Pièce jointe (image) — optionnel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Text(
                                _pickedFilePath != null
                                    ? _pickedFilePath!
                                        .split(Platform.pathSeparator)
                                        .last
                                    : 'Aucun fichier sélectionné',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(type: FileType.image);
                              if (result != null && result.files.isNotEmpty) {
                                final path = result.files.single.path;
                                if (path != null) {
                                  setState(() {
                                    _pickedFilePath = path;
                                  });
                                }
                              }
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Choisir'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Bouton de soumission
                      Obx(
                        () => CustomButton(
                          text: 'Soumettre pour modération',
                          onPressed: _submitNews,
                          isLoading: _newsController.isLoading.value,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Votre actualité sera soumise pour modération avant publication.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImportanceLabel(Importance importance) {
    switch (importance) {
      case Importance.faible:
        return 'Faible';
      case Importance.moyenne:
        return 'Moyenne';
      case Importance.importante:
        return 'Importante';
      case Importance.urgente:
        return 'Urgente';
    }
  }

  Color _getImportanceColor(Importance importance) {
    switch (importance) {
      case Importance.faible:
        return AppColors.textSecondary;
      case Importance.moyenne:
        return AppColors.tagCampus;
      case Importance.importante:
        return AppColors.warning;
      case Importance.urgente:
        return AppColors.error;
    }
  }
}
