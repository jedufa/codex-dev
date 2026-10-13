import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../chat_models.dart';

class ChatThreadHeader extends StatelessWidget {
  const ChatThreadHeader({
    super.key,
    required this.workingDirectory,
    required this.modelLabel,
    required this.selectedProjectId,
    required this.selectedModelId,
    required this.projects,
    required this.modelPresets,
    required this.onDirectoryChanged,
    required this.onProjectAdded,
    required this.onProjectSelected,
    required this.onModelChanged,
  });

  final String workingDirectory;
  final String modelLabel;
  final String? selectedProjectId;
  final String selectedModelId;
  final List<ProjectSummary> projects;
  final List<CodexModelPreset> modelPresets;
  final ValueChanged<String> onDirectoryChanged;
  final Future<void> Function({required String name, required String rootPath})
  onProjectAdded;
  final ValueChanged<ProjectSummary> onProjectSelected;
  final ValueChanged<String> onModelChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final compactProjectDecoration = _compactHeaderDecoration(
      scheme: scheme,
      colors: colors,
      prefixIcon: const Icon(Icons.folder_rounded, size: 18),
      hintText: 'Working directory',
    );
    final compactModelDecoration = _compactHeaderDecoration(
      scheme: scheme,
      colors: colors,
    );
    final projectItems = projects
        .map(
          (project) => DropdownMenuItem<String>(
            value: project.id,
            child: Text(
              project.displayName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        )
        .toList(growable: false);
    final presets = modelPresets.isEmpty
        ? CodexModelPreset.fallbackPresets
        : modelPresets;
    final modelItems = presets
        .map(
          (preset) => DropdownMenuItem<String>(
            value: preset.id,
            child: Text(
              preset.label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        )
        .toList(growable: false);
    final selectedProjectValue =
        projectItems.any((item) => item.value == selectedProjectId)
        ? selectedProjectId
        : null;
    final selectedModelValue =
        modelItems.any((item) => item.value == selectedModelId)
        ? selectedModelId
        : presets.first.id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: projects.isEmpty
                ? TextField(
                    key: const Key('working-directory-field'),
                    controller: TextEditingController(text: workingDirectory)
                      ..selection = TextSelection.collapsed(
                        offset: workingDirectory.length,
                      ),
                    onChanged: onDirectoryChanged,
                    minLines: 1,
                    maxLines: 1,
                    decoration: compactProjectDecoration,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  )
                : DropdownButtonFormField<String>(
                    key: const Key('project-picker'),
                    isExpanded: true,
                    initialValue: selectedProjectValue,
                    decoration: compactProjectDecoration,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                      height: 1.1,
                    ),
                    items: projectItems,
                    selectedItemBuilder: (context) => projects
                        .map(
                          (project) => Tooltip(
                            message: project.rootPath,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                project.displayName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (id) {
                      if (id == null) return;
                      final project = projects.firstWhere(
                        (item) => item.id == id,
                        orElse: () => projects.first,
                      );
                      onProjectSelected(project);
                    },
                  ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton.filledTonal(
              key: const Key('add-project-button'),
              onPressed: () => _showAddRepositoryDialog(context),
              tooltip: 'Add repository',
              icon: const Icon(Icons.create_new_folder_rounded, size: 19),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<String>(
              key: const Key('model-preset-picker'),
              isExpanded: true,
              initialValue: selectedModelValue,
              decoration: compactModelDecoration,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
                height: 1.1,
              ),
              items: modelItems,
              onChanged: (value) {
                if (value != null) {
                  onModelChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _compactHeaderDecoration({
    required ColorScheme scheme,
    required AppColors colors,
    Widget? prefixIcon,
    String? hintText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.22)),
    );
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: colors.floatingSurface,
      hintText: hintText,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints.tightFor(
        width: 36,
        height: 34,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.72)),
      ),
    );
  }

  Future<void> _showAddRepositoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final rootController = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add repository'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('add-project-root-field'),
                  controller: rootController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Server path',
                  ),
                  onSubmitted: (_) async {
                    final root = rootController.text.trim();
                    if (root.isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    await onProjectAdded(
                      name: nameController.text,
                      rootPath: root,
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const Key('confirm-add-project-button'),
                onPressed: () async {
                  final root = rootController.text.trim();
                  if (root.isEmpty) return;
                  Navigator.of(dialogContext).pop();
                  await onProjectAdded(
                    name: nameController.text,
                    rootPath: root,
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      rootController.dispose();
    }
  }
}
