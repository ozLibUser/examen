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
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() {
      _running = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _running = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _elapsedSeconds = 0;
    });
  }

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final sessions = controller.sessions;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 12),
                  Text(
                    _format(_elapsedSeconds),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filled(
                        onPressed: _running ? null : _start,
                        icon: const Icon(Icons.play_arrow),
                      ),
                      IconButton.filled(
                        onPressed: _running ? _pause : null,
                        icon: const Icon(Icons.pause),
                      ),
                      IconButton.outlined(
                        onPressed: _reset,
                        icon: const Icon(Icons.stop),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _elapsedSeconds == 0
                        ? null
                        : () => _saveCurrentSession(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer la séance'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Historique des séances',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const Text(
              'Aucune séance enregistrée pour le moment.',
            )
          else
            ...sessions.map(
              (s) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(
                    '${s.date.day.toString().padLeft(2, '0')}/'
                    '${s.date.month.toString().padLeft(2, '0')} '
                    '${s.date.hour.toString().padLeft(2, '0')}:'
                    '${s.date.minute.toString().padLeft(2, '0')}',
                  ),
                  subtitle: Text(
                    'Durée: ${_format(s.durationSeconds)}'
                    '${s.notes.isNotEmpty ? '\nNotes: ${s.notes}' : ''}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentSession(BuildContext context) async {
    final notesController = TextEditingController();
    final controller = context.read<TrainingController>();

    await showDialog<void>(
      context: context,
      builder: (context) {
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
              onPressed: () => Navigator.of(context).pop(),
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
                await controller.saveSession(session);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                _reset();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}

