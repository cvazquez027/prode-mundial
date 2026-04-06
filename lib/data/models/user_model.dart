import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final bool isPaid;
  final String? paymentId;
  final int totalPoints;
  final int rankPosition;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    this.isPaid = false,
    this.paymentId,
    this.totalPoints = 0,
    this.rankPosition = 0,
    required this.createdAt,
  });

  // Convertir Firestore → UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
      isPaid: data['isPaid'] ?? false,
      paymentId: data['paymentId'],
      totalPoints: data['totalPoints'] ?? 0,
      rankPosition: data['rankPosition'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir UserModel → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'isPaid': isPaid,
      'paymentId': paymentId,
      'totalPoints': totalPoints,
      'rankPosition': rankPosition,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
