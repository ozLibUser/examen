import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/training_controller.dart';
import '../../models/performance_entry.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final performances = controller.performances;

    final weightController = TextEditingController();
    final noteController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Suivi du poids / performances',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Poids (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note / perf du jour',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final weightText =
                        weightController.text.replaceAll(',', '.');
                    final weight =
                        double.tryParse(weightText.trim()) ?? 0;
                    if (weight <= 0) return;

                    final entry = PerformanceEntry(
                      id: '',
                      date: DateTime.now(),
                      weightKg: weight,
                      note: noteController.text.trim(),
                    );

                    await controller.savePerformance(entry);
                    weightController.clear();
                    noteController.clear();
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: performances.isEmpty
                  ? const Text(
                      'Aucune mesure enregistrée pour le moment.',
                    )
                  : ListView.separated(
                      itemCount: performances.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final e = performances[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.monitor_weight),
                            title: Text(
                              '${e.weightKg.toStringAsFixed(1)} kg',
                            ),
                            subtitle: Text(
                              '${e.date.day.toString().padLeft(2, '0')}/'
                              '${e.date.month.toString().padLeft(2, '0')} '
                              '${e.date.hour.toString().padLeft(2, '0')}:'
                              '${e.date.minute.toString().padLeft(2, '0')}'
                              '${e.note.isNotEmpty ? '\n${e.note}' : ''}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

