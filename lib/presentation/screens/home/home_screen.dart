import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../providers/matches_provider.dart';
import '../predictions/match_prediction_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPhase = ref.watch(selectedPhaseProvider);
    final matchesAsync = ref.watch(matchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prode Mundial 2026'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de fases
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: MatchPhase.values.map((phase) {
                final isSelected = phase == selectedPhase;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: ChoiceChip(
                    label: Text(
                      _phaseLabel(phase),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(selectedPhaseProvider.notifier).state = phase,
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(8),
          // Lista de partidos
          Expanded(
            child: matchesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (matches) {
                if (matches.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                        Gap(16),
                        Text(
                          'No hay partidos disponibles\npara esta fase todavía',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return _MatchCard(match: match);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _phaseLabel(MatchPhase phase) {
    switch (phase) {
      case MatchPhase.groups:
        return 'Grupos';
      case MatchPhase.roundOf32:
        return 'Ronda 32';
      case MatchPhase.quarterFinals:
        return 'Cuartos';
      case MatchPhase.semiFinals:
        return 'Semis';
      case MatchPhase.final_:
        return 'Final';
    }
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchPredictionScreen(match: match),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (match.group != null)
                Text(
                  'Grupo ${match.group}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.homeTeam,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      match.status == MatchStatus.finished
                          ? '${match.homeScore} - ${match.awayScore}'
                          : 'VS',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.awayTeam,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Text(
                match.isPredictionOpen
                    ? '⏰ Predicción abierta'
                    : match.status == MatchStatus.finished
                        ? '✅ Finalizado'
                        : '🔒 Predicción cerrada',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
