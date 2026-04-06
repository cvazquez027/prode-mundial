import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionModel {
  final String id;
  final String userId;
  final String matchId;
  final int homeScore;
  final int awayScore;
  final int? pointsEarned;
  final DateTime submittedAt;

  PredictionModel({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    this.pointsEarned,
    required this.submittedAt,
  });

  factory PredictionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PredictionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      matchId: data['matchId'] ?? '',
      homeScore: data['homeScore'] ?? 0,
      awayScore: data['awayScore'] ?? 0,
      pointsEarned: data['pointsEarned'],
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'matchId': matchId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'pointsEarned': pointsEarned,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  // Lógica de puntuación 1+1+1
  static int calculatePoints({
    required int predictedHome,
    required int predictedAway,
    required int realHome,
    required int realAway,
  }) {
    int points = 0;

    final predictedWinner = predictedHome.compareTo(predictedAway);
    final realWinner = realHome.compareTo(realAway);

    // 1 punto por acertar ganador o empate
    if (predictedWinner == realWinner) {
      points += 1;

      // 1 punto adicional por acertar diferencia de goles
      if ((predictedHome - predictedAway) == (realHome - realAway)) {
        points += 1;

        // 1 punto adicional por resultado exacto
        if (predictedHome == realHome && predictedAway == realAway) {
          points += 1;
        }
      }
    }

    return points;
  }
}
