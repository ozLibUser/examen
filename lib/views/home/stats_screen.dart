import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/training_controller.dart';
import '../../models/performance_entry.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // -----------------------
  // UI HELPERS
  // -----------------------

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // -----------------------
  // ACTIONS
  // -----------------------

  Future<void> _addEntry(BuildContext context) async {
    final controller = context.read<TrainingController>();

    final weightText = _weightController.text.replaceAll(',', '.');
    final weight = double.tryParse(weightText.trim());

    if (weight == null || weight <= 0) {
      _showSnackbar(context, 'Veuillez entrer un poids valide',
          isError: true);
      return;
    }

    final entry = PerformanceEntry(
      id: '',
      date: DateTime.now(),
      weightKg: weight,
      note: _noteController.text.trim(),
    );

    final ok = await controller.savePerformance(entry);

    if (!mounted) return;

    _showSnackbar(
      context,
      ok ? 'Mesure enregistrée' : controller.error ?? 'Erreur',
      isError: !ok,
    );

    if (ok) {
      _weightController.clear();
      _noteController.clear();
    }
  }

  Future<void> _deleteEntry(
    BuildContext context,
    String id,
  ) async {
    final controller = context.read<TrainingController>();
    final ok = await controller.deletePerformance(id);

    if (!mounted) return;

    _showSnackbar(
      context,
      ok ? 'Mesure supprimée' : controller.error ?? 'Erreur',
      isError: !ok,
    );
  }

  // -----------------------
  // BUILD
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final performances = controller.performances;

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
                      color: Theme.of(context)
                          .colorScheme
                          .onErrorContainer,
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
            sliver: SliverToBoxAdapter(
              child: _buildInputSection(context),
            ),
          ),
          if (performances.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Aucune mesure enregistrée pour le moment.',
                ),
              ),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: performances.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = performances[index];
                  return _buildEntryCard(context, entry);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suivi du poids / performances',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                        decimal: true),
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
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note / perf du jour',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _addEntry(context),
              child: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Historique',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    PerformanceEntry entry,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.monitor_weight),
        title: Text(
          '${entry.weightKg.toStringAsFixed(1)} kg',
        ),
        subtitle: Text(
          '${_formatDate(entry.date)}'
          '${entry.note.isNotEmpty ? '\n${entry.note}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () =>
              _deleteEntry(context, entry.id),
        ),
      ),
    );
  }
}
