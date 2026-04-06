import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prediction_model.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return PredictionRepository();
});

class PredictionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> savePrediction({
    required String userId,
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    final id = '${userId}_$matchId';
    await _firestore.collection('predictions').doc(id).set({
      'userId': userId,
      'matchId': matchId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'pointsEarned': null,
      'submittedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<PredictionModel?> watchPrediction({
    required String userId,
    required String matchId,
  }) {
    final id = '${userId}_$matchId';
    return _firestore
        .collection('predictions')
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? PredictionModel.fromFirestore(doc) : null);
  }
}
