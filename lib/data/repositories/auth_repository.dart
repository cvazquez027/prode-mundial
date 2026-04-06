import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final credential = await _auth.signInWithPopup(googleProvider);

      // Guardar usuario en Firestore si es la primera vez
      await _saveUserToFirestore(credential.user!);

      return credential;
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    // Solo crear si no existe
    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? 'Usuario',
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        createdAt: DateTime.now(),
      );
      await docRef.set(newUser.toFirestore());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
