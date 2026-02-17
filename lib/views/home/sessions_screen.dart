// sessions_screen.dart - Écran des séances
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
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final sessions = controller.sessions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTimerCard(context),
          const SizedBox(height: 24),
          const Text(
            'Historique des séances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Container(
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
                  'Aucune séance enregistrée',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...sessions.map(_buildSessionCard),
        ],
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Chronomètre',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _formatDuration(_elapsedSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                fontFamily: 'monospace',
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimerButton(
                  icon: Icons.play_arrow,
                  onPressed: _isRunning ? null : _startTimer,
                  color: const Color(0xFF059669),
                ),
                const SizedBox(width: 16),
                _buildTimerButton(
                  icon: Icons.pause,
                  onPressed: _isRunning ? _pauseTimer : null,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(width: 16),
                _buildTimerButton(
                  icon: Icons.stop,
                  onPressed: _resetTimer,
                  color: const Color(0xFFDC2626),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _elapsedSeconds == 0 ? null : () => _saveSession(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Enregistrer la séance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed == null ? const Color(0xFFE2E8F0) : color,
      ),
      child: IconButton(
        icon: Icon(icon, color: onPressed == null ? const Color(0xFF94A3B8) : Colors.white),
        onPressed: onPressed,
        iconSize: 28,
      ),
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    final formattedDate =
        '${session.date.day.toString().padLeft(2, '0')}/${session.date.month.toString().padLeft(2, '0')} '
        '${session.date.hour.toString().padLeft(2, '0')}:${session.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          child: const Icon(Icons.timer, color: Color(0xFF1E293B)),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Durée : ${_formatDuration(session.durationSeconds)}'
            '${session.notes.isNotEmpty ? '\n${session.notes}' : ''}',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSession(BuildContext context) async {
    final notesController = TextEditingController();
    final controller = context.read<TrainingController>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Valider la séance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (facultatif)',
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
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

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Séance enregistrée' : controller.error ?? 'Erreur'),
                              backgroundColor: const Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          if (ok) _resetTimer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    notesController.dispose();
  }
}