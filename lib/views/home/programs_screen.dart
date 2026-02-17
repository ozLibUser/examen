import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/training_controller.dart';
import '../../models/training_program.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final programs = controller.programs;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (controller.error != null)
            SliverToBoxAdapter(
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  title: Text(
                    controller.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clearError,
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final program = programs[index];

                return Card(
                  child: ListTile(
                    title: Text(program.name),
                    subtitle: Text(program.description),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _openEditor(context, existing: program);
                        } else if (value == 'delete') {
                          final ok =
                              await controller.deleteProgram(program.id);

                          if (context.mounted) {
                            _showSnackbar(
                              context,
                              ok
                                  ? 'Programme supprimé'
                                  : controller.error ?? 'Erreur',
                              isError: !ok,
                            );
                          }
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau programme'),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    TrainingProgram? existing,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProgramEditorSheet(existing: existing),
    );
  }

  void _showSnackbar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ProgramEditorSheet extends StatefulWidget {
  final TrainingProgram? existing;

  const ProgramEditorSheet({super.key, this.existing});

  @override
  State<ProgramEditorSheet> createState() => _ProgramEditorSheetState();
}

class _ProgramEditorSheetState extends State<ProgramEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late String _level;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');

    _descriptionController =
        TextEditingController(text: widget.existing?.description ?? '');

    _level = widget.existing?.level ?? 'Débutant';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TrainingController>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null
                  ? 'Nouveau programme'
                  : 'Modifier le programme',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du programme',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / contenu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _level,
              items: const [
                DropdownMenuItem(
                  value: 'Débutant',
                  child: Text('Débutant'),
                ),
                DropdownMenuItem(
                  value: 'Intermédiaire',
                  child: Text('Intermédiaire'),
                ),
                DropdownMenuItem(
                  value: 'Avancé',
                  child: Text('Avancé'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _level = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Niveau',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;

                final program = TrainingProgram(
                  id: widget.existing?.id ?? '',
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  level: _level,
                );

                final ok = await controller.saveProgram(program);

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Programme enregistré'
                            : controller.error ?? 'Erreur',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
