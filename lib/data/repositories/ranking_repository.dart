import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_model.dart';

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return RankingRepository();
});

class RankingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RankingModel>> watchRanking() {
    return _firestore
        .collection('users')
        .where('isPaid', isEqualTo: true)
        .orderBy('totalPoints', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.asMap().entries.map((entry) {
        final data = entry.value.data();
        return RankingModel.fromFirestore({
          ...data,
          'userId': entry.value.id,
          'position': entry.key + 1,
        });
      }).toList();
    });
  }
}
