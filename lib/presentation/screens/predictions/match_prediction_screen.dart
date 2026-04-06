import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../data/models/match_model.dart';
import '../../../data/models/prediction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/prediction_repository.dart';

class MatchPredictionScreen extends ConsumerStatefulWidget {
  final MatchModel match;

  const MatchPredictionScreen({super.key, required this.match});

  @override
  ConsumerState<MatchPredictionScreen> createState() =>
      _MatchPredictionScreenState();
}

class _MatchPredictionScreenState extends ConsumerState<MatchPredictionScreen> {
  int _homeScore = 0;
  int _awayScore = 0;
  bool _isLoading = false;
  PredictionModel? _existingPrediction;

  @override
  void initState() {
    super.initState();
    _loadExistingPrediction();
  }

  Future<void> _loadExistingPrediction() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    ref
        .read(predictionRepositoryProvider)
        .watchPrediction(userId: user.uid, matchId: widget.match.id)
        .listen((prediction) {
      if (prediction != null && mounted) {
        setState(() {
          _existingPrediction = prediction;
          _homeScore = prediction.homeScore;
          _awayScore = prediction.awayScore;
        });
      }
    });
  }

  Future<void> _savePrediction() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(predictionRepositoryProvider).savePrediction(
            userId: user.uid,
            matchId: widget.match.id,
            homeScore: _homeScore,
            awayScore: _awayScore,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Predicción guardada'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = widget.match.isPredictionOpen;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.phaseLabel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.match.group != null)
              Text(
                'Grupo ${widget.match.group}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            const Gap(24),
            // Equipos y scores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Local
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.match.homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Gap(16),
                      _ScoreSelector(
                        value: _homeScore,
                        onChanged: isOpen
                            ? (v) => setState(() => _homeScore = v)
                            : null,
                      ),
                    ],
                  ),
                ),
                const Text(
                  'VS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Visitante
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.match.awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Gap(16),
                      _ScoreSelector(
                        value: _awayScore,
                        onChanged: isOpen
                            ? (v) => setState(() => _awayScore = v)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(32),
            // Estado
            if (!isOpen)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🔒 Las predicciones están cerradas para este partido',
                  textAlign: TextAlign.center,
                ),
              ),
            if (_existingPrediction != null && isOpen)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✅ Ya tenés una predicción: ${_existingPrediction!.homeScore} - ${_existingPrediction!.awayScore}',
                  textAlign: TextAlign.center,
                ),
              ),
            const Gap(24),
            if (isOpen)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePrediction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _existingPrediction != null
                              ? 'Actualizar predicción'
                              : 'Guardar predicción',
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _ScoreSelector({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onChanged != null && value > 0
              ? () => onChanged!(value - 1)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: onChanged != null ? () => onChanged!(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
