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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: programs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final program = programs[index];
          return Card(
            child: ListTile(
              title: Text(program.name),
              subtitle: Text(program.description),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openEditor(context, existing: program);
                  } else if (value == 'delete') {
                    controller.deleteProgram(program.id);
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
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    String level = existing?.level ?? 'Débutant';

    final controller = context.read<TrainingController>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null
                    ? 'Nouveau programme'
                    : 'Modifier le programme',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du programme',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description / contenu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: level,
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
                    level = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Niveau',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;

                  final program = TrainingProgram(
                    id: existing?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    level: level,
                  );

                  await controller.saveProgram(program);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }
}

