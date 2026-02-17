// stats_screen.dart - Écran des statistiques
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

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _addEntry(BuildContext context) async {
    final controller = context.read<TrainingController>();
    final weightText = _weightController.text.replaceAll(',', '.');
    final weight = double.tryParse(weightText.trim());

    if (weight == null || weight <= 0) {
      _showSnackbar(context, 'Veuillez entrer un poids valide', isError: true);
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

  Future<void> _deleteEntry(BuildContext context, String id) async {
    final controller = context.read<TrainingController>();
    final ok = await controller.deletePerformance(id);

    if (!mounted) return;

    _showSnackbar(
      context,
      ok ? 'Mesure supprimée' : controller.error ?? 'Erreur',
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final performances = controller.performances;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          if (controller.error != null)
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFFEE2E2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.error!,
                        style: const TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFB91C1C)),
                      onPressed: controller.clearError,
                    ),
                  ],
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune mesure enregistrée',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: performances.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
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
        const Text(
          'Suivi du poids',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Poids (kg)',
                        labelStyle: const TextStyle(color: Color(0xFF64748B)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note / performance',
                        labelStyle: const TextStyle(color: Color(0xFF64748B)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addEntry(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ajouter la mesure'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Historique',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(BuildContext context, PerformanceEntry entry) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.monitor_weight, color: Color(0xFF1E293B)),
        ),
        title: Text(
          '${entry.weightKg.toStringAsFixed(1)} kg',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_formatDate(entry.date)}${entry.note.isNotEmpty ? '\n${entry.note}' : ''}',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
          onPressed: () => _deleteEntry(context, entry.id),
        ),
      ),
    );
  }
}