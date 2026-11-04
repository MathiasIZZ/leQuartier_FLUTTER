import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../domain/models/panneau.dart';
import '../../data/repositories/panneau_repository_impl.dart';
import '../providers/panneaux_provider.dart';
import '../providers/panneau_filter_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import 'create_panneau_wizard_screen.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  void _showPanneauBottomSheet(BuildContext context, WidgetRef ref, Panneau panneau) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
    final theme = Theme.of(context);
    final currentUserId = ref.read(authProvider).user?.id ?? '';

    final hasUpvoted = panneau.upvoters.contains(currentUserId);
    final hasDownvoted = panneau.downvoters.contains(currentUserId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          panneau.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          panneau.category.label,
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (panneau.verifiedOnSite)
                    Chip(
                      avatar: const Icon(Icons.verified, size: 16, color: Colors.green),
                      label: const Text('Certifié vu sur place', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.green.shade50,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(panneau.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(panneau.address, style: const TextStyle(color: Colors.grey))),
                ],
              ),
              if (panneau.locationHint.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(panneau.locationHint, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
                  ],
                ),
              ],
              if (panneau.creatorPseudo != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Créé par @${panneau.creatorPseudo} (Aura : ⚡ ${panneau.creatorAura ?? 100})',
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Du ${dateFormat.format(panneau.startsAt)} au ${dateFormat.format(panneau.endsAt)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Divider(height: 24),
              // Voting section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: hasUpvoted ? Colors.green.shade50 : null,
                      side: BorderSide(color: hasUpvoted ? Colors.green : Colors.grey.shade300),
                    ),
                    onPressed: () async {
                      await _vote(context, ref, panneau.id, true);
                    },
                    icon: Icon(Icons.thumb_up, color: hasUpvoted ? Colors.green : Colors.grey),
                    label: Text('${panneau.upvoters.length}', style: TextStyle(color: hasUpvoted ? Colors.green : null)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Score: ${panneau.score}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: hasDownvoted ? Colors.red.shade50 : null,
                      side: BorderSide(color: hasDownvoted ? Colors.red : Colors.grey.shade300),
                    ),
                    onPressed: () async {
                      await _vote(context, ref, panneau.id, false);
                    },
                    icon: Icon(Icons.thumb_down, color: hasDownvoted ? Colors.red : Colors.grey),
                    label: Text('${panneau.downvoters.length}', style: TextStyle(color: hasDownvoted ? Colors.red : null)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _vote(BuildContext context, WidgetRef ref, String panneauId, bool isUpvote) async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour voter.')),
      );
      return;
    }

    try {
      await ref.read(panneauRepositoryProvider).votePanneau(
            panneauId: panneauId,
            isUpvote: isUpvote,
            userId: user.id,
          );
      ref.invalidate(panneauxProvider);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vote pris en compte !')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du vote : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPanneauxAsync = ref.watch(filteredPanneauxProvider);
    final filterState = ref.watch(panneauFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte du Quartier'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: () => ref.refresh(panneauxProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          if (filterState.hasActiveFilter)
            Container(
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filtres actifs sur la recherche',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(panneauFilterProvider.notifier).clearFilters();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Effacer'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredPanneauxAsync.when(
              data: (panneaux) {
                if (panneaux.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('Aucun panneau ne correspond à vos filtres.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.read(panneauFilterProvider.notifier).clearFilters(),
                          child: const Text('Réinitialiser les filtres'),
                        ),
                      ],
                    ),
                  );
                }

                return FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(47.3900, 0.6900), // Tours center
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.le_quartier',
                    ),
                    MarkerLayer(
                      markers: panneaux.map((panneau) {
                        return Marker(
                          point: LatLng(panneau.lat, panneau.lng),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showPanneauBottomSheet(context, ref, panneau),
                            child: Container(
                              decoration: BoxDecoration(
                                color: panneau.verifiedOnSite ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const AppLoadingView(),
              error: (err, stack) => Center(child: Text('Erreur de chargement de la carte : $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePanneauWizardScreen(),
            ),
          );
          ref.invalidate(panneauxProvider);
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Poser un panneau'),
      ),
    );
  }
}
