import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchPhase {
  groups,
  roundOf32,
  quarterFinals,
  semiFinals,
  final_,
}

enum MatchStatus {
  upcoming,
  live,
  finished,
}

class MatchModel {
  final String id;
  final MatchPhase phase;
  final String? group;
  final String homeTeam;
  final String awayTeam;
  final int? homeScore;
  final int? awayScore;
  final DateTime startTime;
  final DateTime predictionDeadline;
  final MatchStatus status;
  final String? externalId;

  MatchModel({
    required this.id,
    required this.phase,
    this.group,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.startTime,
    required this.predictionDeadline,
    required this.status,
    this.externalId,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      phase: MatchPhase.values.firstWhere(
        (e) => e.name == data['phase'],
        orElse: () => MatchPhase.groups,
      ),
      group: data['group'],
      homeTeam: data['homeTeam'] ?? '',
      awayTeam: data['awayTeam'] ?? '',
      homeScore: data['homeScore'],
      awayScore: data['awayScore'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      predictionDeadline: (data['predictionDeadline'] as Timestamp).toDate(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MatchStatus.upcoming,
      ),
      externalId: data['externalId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phase': phase.name,
      'group': group,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'startTime': Timestamp.fromDate(startTime),
      'predictionDeadline': Timestamp.fromDate(predictionDeadline),
      'status': status.name,
      'externalId': externalId,
    };
  }

  bool get isPredictionOpen =>
      DateTime.now().isBefore(predictionDeadline) &&
      status == MatchStatus.upcoming;

  String get phaseLabel {
    switch (phase) {
      case MatchPhase.groups:
        return 'Fase de Grupos';
      case MatchPhase.roundOf32:
        return 'Ronda de 32';
      case MatchPhase.quarterFinals:
        return 'Cuartos de Final';
      case MatchPhase.semiFinals:
        return 'Semifinales';
      case MatchPhase.final_:
        return 'Final';
    }
  }
}
