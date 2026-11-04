import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:le_quartier/features/panneau/presentation/providers/user_panneaux_provider.dart';
import 'package:le_quartier/features/panneau/domain/models/panneau.dart';
import 'phone_login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userPanneauxAsync = ref.watch(userPanneauxProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: authState.status == AuthStatus.authenticated && authState.user != null
          ? RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userPanneauxProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⚡', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${authState.user!.auraScore}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.user!.fullName.isNotEmpty
                          ? authState.user!.fullName
                          : 'Utilisateur',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (authState.user!.pseudo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '@${authState.user!.pseudo}',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Stats Cards (Total created, Active, Aura)
                    userPanneauxAsync.when(
                      data: (panneaux) {
                        final activeCount = panneaux.where((p) => p.status == PanneauStatus.actif).length;
                        final totalCount = panneaux.length;

                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Total créés',
                                totalCount.toString(),
                                Icons.add_chart,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Actifs',
                                activeCount.toString(),
                                Icons.location_on,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Aura',
                                '${authState.user!.auraScore}',
                                Icons.flash_on,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: LinearProgressIndicator()),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Numéro de téléphone'),
                              subtitle: Text(authState.user!.phoneNumber),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.verified_user),
                              title: const Text('Statut du compte'),
                              subtitle: const Text('Citoyen vérifié'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Mes panneaux actifs',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    userPanneauxAsync.when(
                      data: (panneaux) {
                        final activePanneaux = panneaux.where((p) => p.status == PanneauStatus.actif).toList();
                        if (activePanneaux.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Vous n’avez pas encore créé de panneau actif.',
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activePanneaux.length,
                          itemBuilder: (context, index) {
                            final p = activePanneaux[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${p.address}\nScore : ${p.score} (${p.upvoters.length} 👍 / ${p.downvoters.length} 👎)', maxLines: 2),
                                isThreeLine: true,
                                trailing: p.verifiedOnSite
                                    ? Chip(
                                        label: const Text('Certifié', style: TextStyle(fontSize: 10, color: Colors.green)),
                                        backgroundColor: Colors.green.shade50,
                                        padding: EdgeInsets.zero,
                                      )
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Erreur : $err'),
                    ),
                    const SizedBox(height: 32),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        ref.read(authProvider.notifier).signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vous êtes déconnecté.')),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    'Rejoignez la communauté !',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous par SMS pour poser des panneaux, participer à la vie de votre quartier et interagir.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text(
                      'Se connecter / S’inscrire',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
