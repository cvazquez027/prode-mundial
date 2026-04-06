class RankingModel {
  final String userId;
  final String displayName;
  final String photoURL;
  final int totalPoints;
  final int position;
  final int correctResults;
  final int exactScores;

  RankingModel({
    required this.userId,
    required this.displayName,
    required this.photoURL,
    required this.totalPoints,
    required this.position,
    required this.correctResults,
    required this.exactScores,
  });

  factory RankingModel.fromFirestore(Map<String, dynamic> data) {
    return RankingModel(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      totalPoints: data['totalPoints'] ?? 0,
      position: data['position'] ?? 0,
      correctResults: data['correctResults'] ?? 0,
      exactScores: data['exactScores'] ?? 0,
    );
  }
}
