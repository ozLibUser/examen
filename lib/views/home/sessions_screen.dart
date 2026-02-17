import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/training_controller.dart';
import '../../models/training_session.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // -----------------------
  // TIMER LOGIC
  // -----------------------

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final sessions = controller.sessions;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTimerCard(context),
          const SizedBox(height: 24),
          _buildHistoryTitle(context),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            const Text('Aucune séance enregistrée pour le moment.')
          else
            ...sessions.map(_buildSessionCard),
        ],
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chronomètre',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _formatDuration(_elapsedSeconds),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(letterSpacing: 3),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  onPressed: _isRunning ? null : _startTimer,
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton.filled(
                  onPressed: _isRunning ? _pauseTimer : null,
                  icon: const Icon(Icons.pause),
                ),
                IconButton.outlined(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  _elapsedSeconds == 0 ? null : () => _saveSession(context),
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la séance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTitle(BuildContext context) {
    return Text(
      'Historique des séances',
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    final formattedDate =
        '${session.date.day.toString().padLeft(2, '0')}/'
        '${session.date.month.toString().padLeft(2, '0')} '
        '${session.date.hour.toString().padLeft(2, '0')}:'
        '${session.date.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(formattedDate),
        subtitle: Text(
          'Durée : ${_formatDuration(session.durationSeconds)}'
          '${session.notes.isNotEmpty ? '\nNotes : ${session.notes}' : ''}',
        ),
      ),
    );
  }

  // -----------------------
  // SAVE SESSION
  // -----------------------

  Future<void> _saveSession(BuildContext context) async {
    final notesController = TextEditingController();
    final controller = context.read<TrainingController>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Valider la séance'),
          content: TextField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final session = TrainingSession(
                  id: '',
                  programId: '',
                  date: DateTime.now(),
                  durationSeconds: _elapsedSeconds,
                  notes: notesController.text.trim(),
                );

                final ok = await controller.saveSession(session);

                if (!mounted) return;

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Séance enregistrée'
                          : controller.error ?? 'Erreur',
                    ),
                    backgroundColor: ok
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                if (ok) _resetTimer();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    notesController.dispose();
  }
}
