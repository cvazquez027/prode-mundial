import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InscriptionScreen extends ConsumerWidget {
  const InscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Color(0xFFFFD700),
              ),
              const Gap(24),
              Text(
                'Prode Mundial 2026',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Inscribite y competí por los premios',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              // Card de premios
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '🏆 Premios',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Gap(16),
                      _PrizeRow(
                          position: '🥇 1° puesto', prize: '50% del pozo'),
                      const Gap(8),
                      _PrizeRow(
                          position: '🥈 2° puesto', prize: '25% del pozo'),
                      const Gap(8),
                      _PrizeRow(
                          position: '🥉 3° puesto',
                          prize: 'Recupera inscripción'),
                    ],
                  ),
                ),
              ),
              const Gap(24),
              // Card de inscripción
              Card(
                color: const Color(0xFF1A237E),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Inscripción',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const Gap(8),
                      Text(
                        '\$50.000',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'pesos argentinos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final user = ref.read(authStateProvider).valueOrNull;
                    if (user == null) return;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'isPaid': true});
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pagar con MercadoPago'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF009EE3),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const Gap(16),
              TextButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrizeRow extends StatelessWidget {
  final String position;
  final String prize;

  const _PrizeRow({required this.position, required this.prize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(position),
        Text(
          prize,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
