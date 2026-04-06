import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Conectar a emuladores locales
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);

  runApp(
    const ProviderScope(
      child: ProdeApp(),
    ),
  );
}
