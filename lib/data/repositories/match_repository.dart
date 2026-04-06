import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

class MatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MatchModel>> watchMatchesByPhase(MatchPhase phase) {
    return _firestore
        .collection('matches')
        .where('phase', isEqualTo: phase.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }

  Stream<List<MatchModel>> watchAllMatches() {
    return _firestore
        .collection('matches')
        .orderBy('startTime')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }
}
