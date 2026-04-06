import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ranking_model.dart';
import '../../data/repositories/ranking_repository.dart';

final rankingProvider = StreamProvider<List<RankingModel>>((ref) {
  return ref.watch(rankingRepositoryProvider).watchRanking();
});
