import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/match_model.dart';
import '../../data/repositories/match_repository.dart';

final selectedPhaseProvider = StateProvider<MatchPhase>((ref) {
  return MatchPhase.groups;
});

final matchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final phase = ref.watch(selectedPhaseProvider);
  return ref.watch(matchRepositoryProvider).watchMatchesByPhase(phase);
});
